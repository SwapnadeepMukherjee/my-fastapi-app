# STAGE 1: The Builder
# We use a specific version (3.11) and 'slim' to minimize attack surface.
# 'bookworm' is the Debian version (stable and predictable).
FROM python:3.11-slim-bookworm as builder

# Set environment variables to avoid python generating .pyc files
# and to ensure logs are sent straight to terminal (no buffering)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies required for building Python packages
# (e.g., if you use Pandas/Numpy or crypto libs, you often need gcc)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first! 
# Docker caches layers. If you change code but not requirements, 
# this step (and the slow pip install) is skipped.
COPY requirements.txt .

# Create a python virtual environment
# We install into /opt/venv so it's easy to copy later
RUN python -m venv /opt/venv
# Enable the venv for the following commands
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# STAGE 2: The Production Runtime
FROM python:3.11-slim-bookworm

# Security: Create a non-root user. 
# If a hacker breaks into the container, they won't have root access.
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy the virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Enable the venv in the path
ENV PATH="/opt/venv/bin:$PATH"

# Copy the actual application code
COPY app/ ./app/

# Switch to the non-root user
USER appuser

# Feedback Point: "Understand CMD vs ENTRYPOINT"
# ENTRYPOINT: The executable that ALWAYS runs
# CMD: The default arguments (can be overridden)
ENTRYPOINT ["uvicorn"]
CMD ["app.main:app", "--host", "0.0.0.0", "--port", "8000"]
