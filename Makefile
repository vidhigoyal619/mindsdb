# Target to install MindsDB with development dependencies and set up pre-commit hooks
install_mindsdb:
	pip install -e .
	pip install -r requirements/requirements-dev.txt
	pre-commit install

# Target to install a specific handler, requiring the HANDLER_NAME environment variable
install_handler:
	@if [[ -n "$(HANDLER_NAME)" ]]; then\
		pip install -e .[$(HANDLER_NAME)];\
	else\
		echo 'Please set $$HANDLER_NAME to the handler to install.';\
	fi	

# Target to install and run pre-commit hooks
precommit:
	pre-commit install
	pre-commit run --files $$(git diff --cached --name-only)

# Target to run MindsDB
run_mindsdb:
	python -m mindsdb

# Target to run various checks (requirements, version, print statements)
check:
	python tests/scripts/check_requirements.py
	python tests/scripts/check_version.py
	python tests/scripts/check_print_statements.py

# Target to build the Docker image for MindsDB
build_docker:
	docker buildx build -t mdb --load -f docker/mindsdb.Dockerfile .

# Target to run the Docker container for MindsDB, building it first if necessary
run_docker: build_docker
	docker run -it -p 47334:47334 mdb

# Specify phony targets to avoid conflicts with files of the same name
.PHONY: install_mindsdb install_handler precommit run_mindsdb check build_docker run_docker
