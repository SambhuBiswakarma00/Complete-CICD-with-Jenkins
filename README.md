# Complete CI-CD Pipeline 

## Overview
This project involves deploying a web application using a robust CI/CD pipeline. The pipeline integrates various tools for code quality, vulnerability scanning, containerization, and monitoring to ensure a reliable 
and secure deployment process.

## CI/CD Pipeline
The CI/CD pipeline automates the process of building, testing, and deploying the application. It ensures code quality, security, and reliability throughout the development lifecycle.

## Pipeline Architecture
![pipeline](https://github.com/SambhuBiswakarma00/Complete-CICD-with-Jenkins/assets/142966523/4662980b-8c83-4f82-b72b-708298720e9b)


## AWS Setup
![complete cicd aws architecture drawio (2)](https://github.com/SambhuBiswakarma00/Complete-CICD-with-Jenkins/assets/142966523/b1ee87ac-b10f-4dd8-b18f-12c22d249946)


## Tools and Technologies
- IaC: Terraform
- CM: Ansible
- Version Control: GitHub
- CI/CD: Jenkins
- Code Quality: SonarQube
- Vulnerability Scanning: Trivy
- Containerization: Docker
- Container Registry: DockerHub
- Orchestration: Kubernetes
- Cluster Security: Kubeaudit
- Monitoring and Logging: Prometheus, Loki, Grafana

## Pipeline Flow
1. Git checkout
Tool: git
Description: Get the codes from github.

2. Code Quality Analysis
Tool: SonarQube
Description: Analyzes the source code for potential bugs, vulnerabilities, and code smells.

3. Docker Build, Scan and push
Tool: Docker, Trivy
Description:
 - Build: Creates a Docker image of the application.
 - Scan: Trivy scans the Docker image for vulnerabilities.
 - After scan, push it to CR.
4. Deployment
Tool: Kubernetes
Description: Deploys the Dockerized application to the Kubernetes cluster.

5. Email Notification
Tool: smtp notification
Description: send the trivy report as email notification.

7. Monitoring
Tools: Prometheus, Loki, Grafana
Description:
  - Prometheus: Collects and stores metrics.
  - Loki: Aggregates and stores logs.
  - Grafana: Provides a unified dashboard for visualizing metrics and logs.

## Setup Instructions
### Prerequisites
- Terraform
- Ansible
- Docker
- Kubernetes
- Jenkins
- SonarQube
- Trivy
- Kubeaudit
- Prometheus, Loki, Grafana Stack

### Steps
- Infrastructure creation with Terraform
- Configuring necessary softwares using Ansible
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
  - Push the docker image to CR.
- Kubernetes Cluster
  - Set up a Kubernetes cluster.
  - Use kubeaudit to scan the cluster for security issues.
- Deploy to Kubernetes
  - Deploy the Docker image to the Kubernetes cluster using kubectl.
- Send the trivy scan report through email notification.
- Set Up Monitoring
  - Deploy Prometheus, Loki, and Grafana to the Kubernetes cluster.
  - Configure Grafana dashboards for monitoring application performance and logs.

## Conclusion
This project demonstrates a comprehensive approach to modern application deployment and management through an automated CI/CD pipeline. By integrating tools like Jenkins, SonarQube, Trivy, Docker, Kubernetes, 
Prometheus, Loki, and Grafana, we ensure a high level of code quality, security, and observability. Following this structured pipeline will help maintain a reliable and secure production environment, making it 
easier to manage and scale the application. We welcome contributions and feedback to further enhance this project.
