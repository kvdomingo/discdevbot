FROM python:3.12-alpine AS base

ENV UV_VERSION=0.8.4
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PATH="/root/.local/bin:${PATH}"

FROM base AS build

WORKDIR /tmp

SHELL [ "/bin/ash", "-euxo", "pipefail", "-c" ]
RUN apk add --no-cache curl

ADD https://astral.sh/uv/${UV_VERSION}/install.sh install-uv.sh

COPY pyproject.toml uv.lock ./

RUN chmod +x /tmp/install-uv.sh && \
    /tmp/install-uv.sh && \
    uv export --format requirements.txt --no-dev --no-hashes --no-header --no-annotate --output-file /tmp/requirements.txt

WORKDIR /app

RUN python -m venv .venv && \
    ./.venv/bin/pip install -r /tmp/requirements.txt

FROM base AS prod

WORKDIR /app

COPY --from=build /tmp/requirements.txt requirements.txt

SHELL [ "/bin/ash", "-euxo", "pipefail", "-c" ]

RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /app

SHELL [ "/bin/ash", "-euxo", "pipefail", "-c" ]

COPY ./discdevbot ./discdevbot
COPY --from=build /app/.venv ./.venv/

CMD [ "/app/.venv/bin/python", "-m", "discdevbot" ]
