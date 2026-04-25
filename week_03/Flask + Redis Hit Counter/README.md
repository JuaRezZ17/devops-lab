# Flask + Redis Hit Counter

## Overview
This project demonstrates a complete DevOps workflow by integrating Linux, Python, and Docker skills in a real-world scenario. As a DevOps Engineer, you'll receive code from a developer and containerize it for production deployment.

**Note:** For detailed step-by-step instructions on implementing this project, refer to the [WALKTHROUGH.md](WALKTHROUGH.md) file.

## Objective
Apply everything learned over three weeks (Linux, Python, Docker) by simulating a real-world scenario where a DevOps Engineer receives code from a developer and prepares it for deployment.

## The Project: Flask + Redis Hit Counter
### The Code (Developer)
A simple Python Flask application that connects to Redis and increments a counter each time the page is visited.

**Key Features:**
- Environment variable-driven configuration (no hardcoded values)
- Atomic Redis operations for thread-safe counter increments
- Clean separation of concerns

### The Dockerfile (DevOps)
A multistage Dockerfile that:
- Compiles dependencies in a "builder" stage
- Uses a lightweight "runner" stage based on `python:3.11-slim`
- Implements security best practices with a non-root user

### Infrastructure (Docker Compose)
A complete containerized environment featuring:
- Redis service using the official Alpine image
- Flask application built from source
- Environment variable injection for Redis connection
- Data persistence through Docker volumes

## Project Structure
```
src/
├── app.py              # Flask application
├── requirements.txt    # Python dependencies
├── Dockerfile          # Multistage container definition
└── docker-compose.yaml # Container orchestration
```

## Prerequisites
- Docker and Docker Compose installed
- Basic understanding of Python, Flask, and Redis
- Familiarity with containerization concepts

## Setup and Installation
1. **Clone or navigate to the project directory:**
   ```bash
   cd week_03/saturday_25-04/src
   ```

2. **Build and start the services:**
   ```bash
   docker-compose up --build
   ```

3. **Verify the application is running:**
   - Open your browser to `http://localhost:5000`
   - Or use curl: `curl http://localhost:5000`

## Usage
The application provides a simple web interface that displays the number of visits. Each page load increments the counter, which is stored in Redis.

**API Endpoint:**
- `GET /` - Returns the visit count

**Example Response:**
```
Hello! This page has been viewed 42 times.
```

## Testing
### Basic Functionality Test
1. Start the services: `docker-compose up --build`
2. Visit `http://localhost:5000` multiple times
3. Observe the counter incrementing

### Persistence Test
1. Stop the services: `docker-compose down`
2. Restart the services: `docker-compose up`
3. Visit the application again
4. Verify the counter continues from where it left off (data persists in Redis volume)

### Connection Test
- Ensure Redis connectivity by checking the application logs: `docker-compose logs web`
- Verify no connection errors appear

## Key Concepts and Learning Objectives
### Multistage Docker Builds
- **Builder Stage:** Compiles dependencies and creates virtual environment
- **Runner Stage:** Lightweight production image with only necessary runtime components
- Benefits: Smaller image size, improved security, faster deployments

### Security Best Practices
- Non-root user execution
- Minimal attack surface in production containers
- Proper file permissions

### Environment-Driven Configuration
- No hardcoded values in application code
- Docker Compose injects configuration via environment variables
- Enables different configurations for dev/staging/production

### Container Orchestration
- Service dependencies and startup order
- Internal networking between containers
- Data persistence with Docker volumes

### Redis Integration
- Atomic operations for data consistency
- In-memory data store with optional persistence
- Scalable caching and session management

## Troubleshooting
### Common Issues
1. **Port already in use:** Ensure ports 5000 and 6379 are available
2. **Redis connection failed:** Check Docker network connectivity
3. **Build failures:** Verify all files are present and correctly formatted

### Logs
- View application logs: `docker-compose logs web`
- View Redis logs: `docker-compose logs redis`
- View all logs: `docker-compose logs`

## Cleanup
To stop and remove all containers and volumes:
```bash
docker-compose down -v
```

## Next Steps
This lab demonstrates fundamental DevOps practices. Consider extending it with:
- Health checks
- Logging aggregation
- CI/CD pipeline integration
- Kubernetes deployment
- Monitoring and alerting