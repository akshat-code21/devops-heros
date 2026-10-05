# ============================================
# Dockerfile for Calculator Application
# Used in the CD (Continuous Delivery) pipeline
# ============================================

# Stage 1: Base image
FROM python:3.12-slim AS base

# Set working directory
WORKDIR /app

# Copy dependency file and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY app/ ./app/
COPY tests/ ./tests/

# Stage 2: Test runner (used in CI to run tests inside container)
FROM base AS test
RUN pytest -v

# Stage 3: Production image
FROM python:3.12-slim AS production

WORKDIR /app

COPY app/ ./app/

# Set non-root user for security
RUN useradd --create-home appuser
USER appuser

# Default command
CMD ["python", "app/calculator.py"]
