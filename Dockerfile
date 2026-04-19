# ==============================================
# Stage 1: Builder (Compilation of dependencies)
# ==============================================
FROM python:3.11-slim AS builder

WORKDIR /app

# We create a virtual environment to install the dependencies cleanly
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# We copy only the requirements first to make use of the Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ==================================================
# Stage 2: Runner (Secure and Lightweight Execution)
# ==================================================
FROM python:3.11-slim AS runner

WORKDIR /app

# 1. We copy the already compiled virtual environment from the "builder" stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 2. We copy the application code
COPY app.py .

# 3. Security: We create a non-root user and grant them permissions for the folder
RUN useradd -m appuser && chown -R appuser:appuser /app

# 4. We switch to that user to run the app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]