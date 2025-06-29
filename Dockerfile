# Builder stage
FROM python:3.11-slim as builder

WORKDIR /app
COPY requirements.txt .

# Install security updates in builder stage
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Runtime stage
FROM python:3.11-slim

WORKDIR /app

# Install security updates and curl for health check
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user and group first
RUN addgroup --system appgroup && \
    adduser --system --no-create-home --disabled-login --ingroup appgroup appuser

# Copy installed packages to /usr/local instead of /root
COPY --from=builder /install /usr/local

# Copy application code with proper permissions
COPY --chown=appuser:appgroup app /app/app

# Harden filesystem permissions
RUN chmod -R 755 /app && \
    find /app -type f -exec chmod 644 {} \; && \
    chmod -R 750 /app/app

# Set environment variables
ENV PATH=/usr/local/bin:$PATH \
    PYTHONPATH=/app \
    PYTHONUNBUFFERED=1

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Switch to non-root user
USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]