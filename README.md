# Complete CI-CD Pipeline 

## Overview
This project involves deploying a web application using a robust CI/CD pipeline. The pipeline integrates various tools for code quality, vulnerability scanning, containerization, and monitoring to ensure a reliable 
and secure deployment process.

## CI/CD Pipeline
The CI/CD pipeline automates the process of building, testing, and deploying the application. It ensures code quality, security, and reliability throughout the development lifecycle.

## AWS Setup
![complete cicd aws architecture drawio](https://github.com/SambhuBiswakarma00/Complete-CICD-with-Jenkins/assets/142966523/d6f43b1e-adb2-4477-83e4-9ff2b146e799)

## Pipeline Architecture
![cicd architecture drawio (1)](https://github.com/SambhuBiswakarma00/Complete-CICD-with-Jenkins/assets/142966523/90b26b70-084a-487b-a051-67fe48914665)

## Tools and Technologies
- Version Control: GitHub
- CI/CD: Jenkins
- Code Quality: SonarQube
- Vulnerability Scanning: Trivy
- Containerization: Docker
- Container Registry: DockerHub
- Orchestration: Kubernetes
- Cluster Security: Kubeaudit
- Monitoring and Logging: Prometheus, Loki, Grafana

## Pipeline Stages
1. Code Quality Analysis
Tool: SonarQube
Description: Analyzes the source code for potential bugs, vulnerabilities, and code smells.
2. Vulnerability Scanning
Tool: Trivy
Description: Scans the codebase for known vulnerabilities before containerization.
3. Docker Build and Scan
Tool: Docker, Trivy
Description:
Build: Creates a Docker image of the application.
Scan: Trivy scans the Docker image for vulnerabilities.
4. Kubernetes Cluster Creation
Description:
Tool: Kubernetes
Process: Sets up a Kubernetes cluster for deploying the application.
5. Deployment
Description:
Tool: Kubernetes
Process: Deploys the Dockerized application to the Kubernetes cluster.
6. Monitoring
Tools: Prometheus, Loki, Grafana
Description:
Prometheus: Collects and stores metrics.
Loki: Aggregates and stores logs.
Grafana: Provides a unified dashboard for visualizing metrics and logs.

## Setup Instructions
### Prerequisites
- Docker
- Kubernetes
- Jenkins
- SonarQube
- Trivy
- Kubeaudit
- Prometheus, Loki, Grafana Stack

### Steps
- Clone the Repository
- Configure Jenkins
  - Set up Jenkins with the necessary plugins for GitHub, Docker, SonarQube, and Kubernetes.
  - Create a Jenkins pipeline using the provided Jenkinsfile.
- Configure SonarQube
  - Set up SonarQube server.
  - Create a new project in SonarQube and obtain the project key and token.
- Set Up Trivy
  - Install Trivy for vulnerability scanning.
- Build Docker Image
  - Create a Dockerfile for the application.
  - Use Jenkins to build and scan the Docker image with Trivy.
- Kubernetes Cluster
  - Set up a Kubernetes cluster.
  - Use kubeaudit to scan the cluster for security issues.
- Deploy to Kubernetes
  - Deploy the Docker image to the Kubernetes cluster using kubectl.
- Set Up Monitoring
  - Deploy Prometheus, Loki, and Grafana to the Kubernetes cluster.
  - Configure Grafana dashboards for monitoring application performance and logs.

## Conclusion
This project demonstrates a comprehensive approach to modern application deployment and management through an automated CI/CD pipeline. By integrating tools like Jenkins, SonarQube, Trivy, Docker, Kubernetes, 
Prometheus, Loki, and Grafana, we ensure a high level of code quality, security, and observability. Following this structured pipeline will help maintain a reliable and secure production environment, making it 
easier to manage and scale the application. We welcome contributions and feedback to further enhance this project.
