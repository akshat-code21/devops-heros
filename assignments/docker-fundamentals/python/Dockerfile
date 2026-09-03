FROM python:3.12-slim AS builder

COPY --from=astral/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY ./pyproject.toml ./pyproject.toml
COPY ./uv.lock ./uv.lock

RUN uv sync --frozen --no-cache --no-install-project


FROM python:3.12-slim AS production

WORKDIR /app

COPY --from=builder /app/.venv /app/.venv

COPY app /app/app

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONBUFFERED=1

EXPOSE 8000

CMD [ "fastapi" , "run" , "app/main.py" , "--host", "0.0.0.0", "--port" , "8000" ]
