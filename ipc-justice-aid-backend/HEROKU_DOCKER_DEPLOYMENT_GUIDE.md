# Heroku Docker Deployment Guide (Alternative)

If you prefer to use Docker for Heroku deployment, follow this guide instead.

## Prerequisites

1. **Docker installed locally**
2. **Heroku CLI with Container Registry plugin**

## Step 1: Install Heroku Container Registry

```bash
heroku plugins:install heroku-container-registry
heroku container:login
```

## Step 2: Create Dockerfile for Heroku

Create a `Dockerfile.heroku` optimized for production:

```dockerfile
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . /app/

# Collect static files
RUN python manage.py collectstatic --noinput

# Create a non-root user
RUN useradd --create-home --shell /bin/bash app
RUN chown -R app:app /app
USER app

# Expose port
EXPOSE $PORT

# Command to run the application
CMD gunicorn ipc_justice_aid_backend.wsgi:application --bind 0.0.0.0:$PORT
```

## Step 3: Create docker-compose for Heroku (optional)

```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.heroku
    ports:
      - "8000:8000"
    environment:
      - PORT=8000
      - ANALYSIS_ENVIRONMENT=huggingface
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - HUGGINGFACE_API_TOKEN=${HUGGINGFACE_API_TOKEN}
```

## Step 4: Deploy with Docker

```bash
# Create Heroku app
heroku create your-app-name

# Add addons
heroku addons:create heroku-postgresql:essential-0
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set ANALYSIS_ENVIRONMENT=huggingface
heroku config:set HUGGINGFACE_API_TOKEN="your-token-here"
heroku config:set HUGGINGFACE_MODEL_ID="mistralai/Mistral-7B-Instruct-v0.1"

# Build and push Docker image
heroku container:push web

# Release the image
heroku container:release web

# Run migrations
heroku run python manage.py migrate

# Open the app
heroku open
```

## Step 5: View logs

```bash
heroku logs --tail
```

## Comparison: Docker vs Native

### Docker Deployment
- ✅ Consistent environment
- ✅ Local/production parity
- ❌ Slower deployments
- ❌ More memory usage
- ❌ More complex setup

### Native Python Deployment (Recommended)
- ✅ Faster deployments
- ✅ Less memory usage
- ✅ Heroku optimized
- ✅ Simpler setup
- ❌ Less environment control
