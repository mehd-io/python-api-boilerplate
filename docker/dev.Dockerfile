ARG BASE_LAYER_VERSION=$BASE_LAYER_VERSION
FROM python-api-boilerplate.local:${BASE_LAYER_VERSION}

WORKDIR /app

# Install python packages
COPY pyproject.toml poetry.lock /app/
RUN poetry install \
    && rm /app/pyproject.toml \
    && rm /app/poetry.lock

# Gcloud SDK
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH="$PATH:/root/google-cloud-sdk/bin"

# Docker from docker for building Docker img within docker image
ARG ENABLE_NONROOT_DOCKER="true"
ARG USE_MOBY="true"
ARG CLI_VERSION="latest"
ENV DOCKER_BUILDKIT=0
ARG MS_VSCODE_SCRIPTS_TAG=v0.202.1
ARG USERNAME=automatic
RUN curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/${MS_VSCODE_SCRIPTS_TAG}/script-library/docker-debian.sh" | bash -s "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" "${USE_MOBY}" "${CLI_VERSION}" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install OhMyZsh
RUN apt-get update \ 
    && apt-get -y install --no-install-recommends zsh \
    && apt-get autoremove -y \
    && apt-get clean -y 
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

