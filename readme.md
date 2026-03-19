# Trainee DevOps Engineer Task: Documentation - Java CI/CD Pipeline with AWS ECS Deployment
> This project demonstrates a complete **CI/CD pipeline** for a Java (Spring Boot) application using **GitHub Actions**, **Docker**, and **AWS ECS (Fargate)**, with infrastructure managed via **Terraform**.
---------------------------------------------
## 📌 Project Overview
---
The pipeline automates:
- Build and package Java application  
- Run tests and generate reports  
- Build and push Docker image to Docker Hub  
- Scan container for vulnerabilities  
- Deploy application to AWS ECS (Fargate)  
- Run performance testing  
- Send pipeline status alerts (Microsoft Teams)  
---
## Tech Stack
- Java 17 + Maven  
- GitHub Actions (CI/CD)  
- Docker & Docker Hub  
- AWS ECS (Fargate)  
- Terraform (Infrastructure as Code)  
- Trivy (Security Scanning)  
- Apache Bench (Performance Testing)  
---
## Prerequisites

Before running this project, ensure you have:

- Git installed  
- Docker installed  
- AWS account  
- Terraform installed (>= 1.0)  
- GitHub repository with Actions enabled  
---
## Required Secrets (GitHub)

Add the following secrets in your repository:
- DOCKER_USERNAME
- DOCKER_TOKEN
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_DEFAULT_REGION
- ECS_CLUSTER_NAME
- ECS_SERVICE_NAME
- TEAMS_WEBHOOK
---------------------------------------------
## Project Set Up:
---
### Initial Set Up:
1. Create a forked repository
2. Copy repository https
3. Open Ubuntu terminal and use command git clone "repository https"
4. cd into repository project then use command code ..

### Java Project Set Up:
1. Download JDK (Java Developement Kit) at: https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html
2. Run project locally using ./mvnw spring-boot: run
---------------------------------------------
## Dockerfile Overview
---
This project uses a **multi-stage Docker build** to efficiently build and run the Java application.

### Build Stage
- The first stage uses a Maven image with Java 17 to compile the application. 
- It copies the project files, installs required dependencies, and packages the application into a `.jar` file. 
- Tests are skipped to speed up the build process.

### Runtime Stage
- The second stage uses a lightweight Java runtime image. 
- It copies only the built `.jar` file from the build stage, reducing the final image size. 
- The container runs as a non-root user for improved security and includes a health check to ensure the application is running correctly.

### Commands
- Build image: docker build -t spring-petclinic .
- Run container: docker run -p 8080:8080 spring-petclinic
- Ensure application is running: http://localhost:8080

### Notes
- Multi-stage builds help reduce image size  
- Running as a non-root user improves security  
- Health checks are useful for monitoring in environments like AWS ECS  
---------------------------------------------
### Pipelines
---
#### Stages:
**Build:***
Compiles the Java application using Maven, caches dependencies for faster builds, and creates a JAR artifact for later stages.

- Checks out the repository code.
- Sets up Java 17 using Temurin.
- Compiles the application with Maven.
- Uploads the compiled JAR as an artifact for subsequent stages.

**Test:**
Runs unit tests with Maven, captures test logs, and uploads test reports as artifacts. Ensures that only passing code progresses.

- Checks out code and sets up Java again.
- Executes unit tests and logs results.
- Uploads test reports as artifacts.
- Always runs, even if build fails, to provide diagnostic logs

**Docker Build & Push:**
Builds a Docker image of the application using a multi-stage Dockerfile, tags the image with latest and commit SHA, and pushes it to DockerHub.

- Sets up Docker Buildx for building multi-platform images.
- Logs into DockerHub using secrets.
- Builds Docker image from the repository.
- Tags image with both latest and the commit SHA.
- Pushes the image to DockerHub for deployment.

**Container Scanning:**
Scans the Docker image for vulnerabilities using Trivy, generates a security report, and sets thresholds to prevent deployment if critical issues exist.

- Uses Trivy to scan the Docker image for vulnerabilities.
- Focuses on OS and library vulnerabilities with HIGH and CRITICAL severity.
- Generates a JSON security report and uploads it as an artifact.
- Ensures vulnerable images do not get deployed.

**Deploy to AWS ECS:**
Updates the ECS service with the new Docker image, forces a new deployment, and verifies the service status. Includes rollback to a stable image if deployment fails.

- Configures AWS credentials from GitHub Secrets.
- Forces ECS service update with the new Docker image.
- Verifies deployment status with describe-services.
- Performs rollback to a stable image if deployment fails.

**Performance Testing:**
Uses Apache Bench (ab) to test application performance and availability, waits for ECS service to be ready, and uploads performance results.

- Installs Apache Bench (ab) for load testing.
- Waits for the ECS service to become available.
- Runs load test with 100 requests and concurrency of 10.
- Saves and uploads performance results.

**Pipeline Alerts:**
Aggregates stage results, generates a success/failure summary, and sends a notification message to Microsoft Teams via webhook.

- Collects results from all previous stages.
- Determines overall pipeline success/failure.
- Sends a formatted summary message to Microsoft Teams.
- Includes stage-by-stage results, repository info, and actor details.
---------------------------------------------


