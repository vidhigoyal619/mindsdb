# Use gitpod/workspace-postgres as the base image
FROM gitpod/workspace-postgres

# Set environment variables for Node.js and Python versions
ENV NODE_VERSION=18
ENV PYTHON_VERSION=3.8

# Install the specified version of Python using pyenv and set it as global
RUN pyenv install $PYTHON_VERSION -s \
    && pyenv global $PYTHON_VERSION

# Install the specified version of Node.js using nvm, set it as current and default
RUN bash -c 'source $HOME/.nvm/nvm.sh && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION && nvm alias default $NODE_VERSION'

# Ensure the default Node.js version is used in new shell sessions
RUN echo "nvm use default &>/dev/null" >> ~/.bashrc.d/51-nvm-fix
