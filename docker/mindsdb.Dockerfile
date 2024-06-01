# Start with the base image that has Python 3.10
FROM python:3.10-slim AS build
WORKDIR /mindsdb

# Install the "mindsdb" package from the current directory
# The --mount option is used to cache pip packages to speed up subsequent builds
RUN --mount=type=cache,target=/root/.cache/pip pip install "."

# Create a new stage for development with additional dependencies
FROM build AS dev
WORKDIR /mindsdb

# Prevent Docker from removing cached packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Update package lists and upgrade installed packages
# Install additional libraries needed by mindsdb
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt update && apt-get upgrade -y && \
    apt-get install -y libmagic1 libpq5 freetds-bin

# Install development dependencies listed in requirements-dev.txt
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements/requirements-dev.txt

# Copy the release configuration file for mindsdb
COPY docker/mindsdb_config.release.json /root/mindsdb_config.json

# Set environment variables for Python and mindsdb
ENV PYTHONUNBUFFERED=1
ENV MINDSDB_DOCKER_ENV=1

# Expose ports for different services (HTTP, MySQL, MongoDB)
EXPOSE 47334/tcp
EXPOSE 47335/tcp
EXPOSE 47336/tcp

# Define the command to run when the container starts
ENTRYPOINT ["sh", "-c", "python -m mindsdb --config=/root/mindsdb_config.json --api=http,mysql,mongodb"]

# Create the final image for production use
FROM python:3.10-slim
WORKDIR /mindsdb

# Prevent Docker from removing cached packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Update package lists and upgrade installed packages
# Install additional libraries needed by mindsdb
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt update && apt-get upgrade -y && \
    apt-get install -y libmagic1 libpq5 freetds-bin

# Copy installed Python packages from the build stage
COPY --link --from=build /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# Copy the release configuration file for mindsdb
COPY docker/mindsdb_config.release.json /root/mindsdb_config.json

# Set environment variables for Python and mindsdb
ENV PYTHONUNBUFFERED=1
ENV MINDSDB_DOCKER_ENV=1

# Expose ports for different services (HTTP, MySQL, MongoDB)
EXPOSE 47334/tcp
EXPOSE 47335/tcp
EXPOSE 47336/tcp

# Define the command to run when the container starts
ENTRYPOINT ["sh", "-c", "python -m mindsdb --config=/root/mindsdb_config.json --api=http,mysql,mongodb"]
