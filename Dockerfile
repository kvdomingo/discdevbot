FROM python:3.12-alpine AS base

FROM base AS build

ENV POETRY_VERSION=1.8.4
ENV POETRY_HOME=/opt/poetry
ENV PATH=${PATH}:${POETRY_HOME}/bin

WORKDIR /tmp

COPY pyproject.toml poetry.lock ./

SHELL [ "/bin/ash", "-euxo", "pipefail", "-c" ]

RUN apk add --no-cache curl && \
    curl -sSL https://install.python-poetry.org | python - && \
    poetry export -f requirements.txt --without-hashes --without dev -o requirements.txt

FROM base AS prod

WORKDIR /tmp

COPY --from=build /tmp/requirements.txt requirements.txt

SHELL [ "/bin/ash", "-euxo", "pipefail", "-c" ]

RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /app

COPY ./discdevbot ./discdevbot

CMD [ "python", "-m", "discdevbot" ]
