ARG BASE_LAYER_VERSION=$BASE_LAYER_VERSION
FROM python-api-boilerplate.local:${BASE_LAYER_VERSION}

ENV PORT=8080
WORKDIR /app

COPY pyproject.toml poetry.lock python_api_boilerplate /app/
RUN poetry install --no-dev

EXPOSE ${PORT}

CMD exec uvicorn --host 0.0.0.0 --port ${PORT} api:app