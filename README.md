# my-fastapi-app

A production-ready FastAPI application with Docker containerization and automated AWS ECR deployment via GitHub Actions.

## Table of Contents

- [Overview](#overview)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running Locally](#running-locally)
- [Docker](#docker)
- [Deployment](#deployment)
- [Environment Variables](#environment-variables)
- [Contributing](#contributing)

## Overview

This is a FastAPI application designed for easy deployment to AWS using Docker and GitHub Actions. The project follows security best practices including multi-stage Docker builds, non-root user execution, and OIDC-based AWS authentication.

## Technology Stack

- **Framework**: [FastAPI](https://fastapi.tiangolo.com/) 0.109.0
- **ASGI Server**: [Uvicorn](https://www.uvicorn.org/) 0.27.0
- **Containerization**: Docker (Python 3.11-slim-bookworm)
- **CI/CD**: GitHub Actions
- **Registry**: Amazon ECR (Elastic Container Registry)
- **Cloud**: AWS (ap-south-1 region)

## Project Structure

```
my-fastapi-app/
├── app/
│   └── main.py              # FastAPI application entry point
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actions deployment workflow
├── Dockerfile               # Multi-stage Docker build configuration
├── .dockerignore            # Docker build exclusions
├── requirements.txt         # Python dependencies
├── deploy.yml               # Deployment configuration (legacy)
└── README.md                # This file
```

## Prerequisites

- Python 3.11+
- Docker & Docker CLI
- Git
- AWS Account (for deployment)
- GitHub Actions enabled on your repository

## Installation

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/SwapnadeepMukherjee/my-fastapi-app.git
   cd my-fastapi-app
   ```

2. **Create a Python virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

## Running Locally

Start the development server:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

- **API Documentation (Swagger UI)**: http://localhost:8000/docs
- **Alternative Documentation (ReDoc)**: http://localhost:8000/redoc

## Docker

### Building the Docker Image

The Dockerfile uses a **multi-stage build** for optimal image size and security:

**Stage 1: Builder**
- Installs system dependencies (gcc)
- Creates a Python virtual environment
- Installs Python dependencies

**Stage 2: Runtime**
- Uses a clean, minimal base image
- Copies the pre-built virtual environment
- Runs the application as a non-root user (`appuser`)
- Significantly smaller final image

**Build the image:**
```bash
docker build -t my-fastapi-app:latest .
```

### Running the Docker Container

```bash
docker run -p 8000:8000 my-fastapi-app:latest
```

The application will be accessible at `http://localhost:8000`

### Docker Best Practices Implemented

✅ **Multi-stage builds** - Reduces final image size  
✅ **Non-root user** - Improved security  
✅ **Slim base image** - Minimal attack surface  
✅ **Environment variables** - `PYTHONDONTWRITEBYTECODE` and `PYTHONUNBUFFERED`  
✅ **Layer caching optimization** - Dependencies copied before application code  

## Deployment

This project is configured for automated deployment to **Amazon ECR** using GitHub Actions.

### Deployment Workflow

The GitHub Actions workflow (`.github/workflows/deploy.yml`) automatically:

1. **Checks out** your code on every push to the `main` branch
2. **Authenticates** to AWS using OIDC (no stored credentials)
3. **Logs in** to Amazon ECR
4. **Builds** the Docker image with two tags:
   - Commit SHA (unique identifier)
   - `latest` (always points to the most recent deployment)
5. **Pushes** both tags to ECR

### Setup for AWS Deployment

1. **Create an AWS ECR Repository**
   ```bash
   aws ecr create-repository --repository-name my-fastapi-app --region ap-south-1
   ```

2. **Configure GitHub Secrets**
   - Add `AWS_ROLE_ARN`: Your AWS IAM role ARN for OIDC authentication

3. **Configure GitHub Variables**
   - Add `AWS_REGION`: Your target AWS region (e.g., `ap-south-1`)

4. **Enable OIDC in AWS**
   - Create an IAM OIDC identity provider for GitHub
   - Create an IAM role with ECR permissions
   - Reference: [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)

### Deployment Triggers

The workflow triggers automatically on:
- Push to the `main` branch

## Environment Variables

### Application

The application uses the following environment variables (set in Docker):

| Variable | Default | Purpose |
|----------|---------|---------|
| `PYTHONDONTWRITEBYTECODE` | `1` | Prevent Python from writing `.pyc` files |
| `PYTHONUNBUFFERED` | `1` | Ensure logs are sent to stdout immediately |

### Docker Runtime

- **Host**: `0.0.0.0` (accessible from outside the container)
- **Port**: `8000` (FastAPI server port)

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Create a feature branch from `main`
2. Make your changes and test thoroughly
3. Push to your branch
4. Create a Pull Request with a clear description

## License

This project is open source. See LICENSE file for details (if applicable).

## Support

For issues or questions:
- Open a GitHub Issue
- Check the [FastAPI documentation](https://fastapi.tiangolo.com/)
- Review the [Docker documentation](https://docs.docker.com/)
