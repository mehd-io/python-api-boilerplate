ARG PYTHON_VERSION="3.9"
FROM python:${PYTHON_VERSION}-slim as python-api-boilerplate

RUN apt-get update \
    && apt-get -y install --no-install-recommends wget zip unzip curl build-essential jq git ssh-client

# Poetry for py packages
RUN pip install poetry==1.1.8 --no-cache-dir \
    && poetry config virtualenvs.create false 