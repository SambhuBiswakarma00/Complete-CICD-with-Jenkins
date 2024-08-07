# CICD pipeline with Jenkins

## Install required plugins in jenkins
4. **SonarQube Scanner**:
   - SonarQube is a code quality and security analysis tool.
   - This plugin integrates Jenkins with SonarQube by providing a scanner that analyzes code during builds.
   - You can install it from the Jenkins plugin manager as described above.

5. **Kubernetes CLI**:
   - This plugin allows Jenkins to interact with Kubernetes clusters using the Kubernetes command-line tool (`kubectl`).
   - It's useful for tasks like deploying applications to Kubernetes from Jenkins jobs.
   - Install it through the plugin manager.

6. **Kubernetes**:
   - This plugin integrates Jenkins with Kubernetes by allowing Jenkins agents to run as pods within a Kubernetes cluster.
   - It provides dynamic scaling and resource optimization capabilities for Jenkins builds.
   - Install it from the Jenkins plugin manager.

7. **Docker**:
   - This plugin allows Jenkins to interact with Docker, enabling Docker builds and integration with Docker registries.
   - You can use it to build Docker images, run Docker containers, and push/pull images from Docker registries.
   - Install it from the plugin manager.

8. **Docker Pipeline Step**:
   - This plugin extends Jenkins Pipeline with steps to build, publish, and run Docker containers as part of your Pipeline scripts.
   - It provides a convenient way to manage Docker containers directly from Jenkins Pipelines.
   - Install it through the plugin manager like the others.

After installing these plugins, you may need to configure them according to your specific environment and requirements. This typically involves setting up credentials, configuring paths, and specifying options in Jenkins global configuration or individual job configurations. Each plugin usually comes with its own set of documentation to guide you through the configuration process.

## Adding Credentials and Configuring

You can add credentials from Manage Jenkins>Credentials page
- click on global for global scope of the credentials
- add credentials
- provide the credentials
- provide the credential ID
- and save the credentials.
Now you can use these credentials in your pipelines.

### Adding github credentials if you are using private repos. If you are using public repo, then you don't need to add the github credentials
- Select the kind as username with password
- You can either add github username and password or you can add github username and token.
- Generate token in github and copy it and add it in jenkins credentials.

### Adding sonarqube credentials and configuring the sonarqube server in jenkins
- select kind as secret text
- Go to sonarqube server>Administration>security>users>tokens
- Generate a token
- Copy and paste the token in secret in jenkins and provide credential id.
- Once credential is created, goto Manage Jenkins> system
- Scroll down to sonarqube server> add sonarqube
- Provde name(i have given as sonar), server url(public_ip:9000) and for server authentication token user the credential created above.
- Now you can just use this name in your sonarqube block in your pipeline.

### Quality gate configuration
- Goto sonarqube server>Administration>configuration> webhooks
- Create a webhook
- provide webhook name and url(jenkins_public_ip:8080/sonarqube-webhook/
- Leave the secret box blank and create the webhook

### Docker configuration
- provide dockerhub username and password and create the credential

### Configuring K8 cluster authentication in Jenkins using api token
- Create secret.yaml as shown below
- ![image](https://github.com/user-attachments/assets/290b87ea-955a-495e-93ad-a6149ae732b0)
- Now change the service account name and run this secret.yaml file with ```kubectl apply -f secret.yaml -n mynamespace```
- Now run ```kubectl describe secret my_secret_name -n mynamespace```
- Now copy the token from the output
- Now goto credentails, add credential with kind as secret text and provide the token for secret and provide credentail id.

### Configuring the smtp server in Jenkins for email notification
- Login to your email(example; gmail)>manage your google account>security>two step verification
- Goto App passwords
- Provide the app name(any name) and generate the app password.
- Now goto Jenkins>Manage Jenkins> system
- Now goto email notification(Basic features) or extended email notification(More features).
- For Extended Email Notification
   - Provide SMTP server(for gmail its smtp.gmail.com)
   - SMTP port 465
   - Add credentials
        - username:you gmail username
        - password:app password generated above
   - select the credential created
   - check ssl
- For Email Notification
   - Provide SMTP server as above
   - click on advance
   - check "use smtp authentication" and provide gmail username and app password created earlier.
   - check ssl
   - Now save the configuration.
You can check if the configuration is saved properly or not by send test email using the "Test configuration by sending e-mail" block below.

Note: If you don't know how to write the command, you can use pipeline syntax to generate the commands

## Pipeline Code
```groovy
pipeline {
    agent any
    environment {
        // Define any environment variables here
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKER_IMAGE = 'myapp:latest'
    }
    stages {
        // This stage is to get the source codes for our project from github
        stage('Git Checkout') {
            steps {
                // if we don't specify the dir() directive, then all the contents of website repo will be directly copied to jenkins job dir root dir 
                // '$JENKINS_HOME/workspace/Job/'. so, here we create separate folders for eache repo we want to copy. Here, it will create two folders website and cicd

                dir('website') {
                        git 'https://github.com/SambhuBiswakarma00/website.git'
                    }
                    
                    dir('cicd') {
                        git branch: 'main', url: 'https://github.com/SambhuBiswakarma00/Complete-CICD-with-Jenkins.git'
                    }
            }
        }

        stage('SonarQube Analsyis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=myApp -Dsonar.projectKey=myApp \
                            -Dsonar.sources=website 
                    '''
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                script {
                  waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            }
        }
        
        
        
        stage('Build & Tag Docker Image') {
            steps {
               script {
                   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                            sh "docker build -t sambhubiswakarma00/myApp:latest website"
                    }
               }
            }
        }
        
        stage('Docker Image Scan') {
            steps {
                sh "trivy image --format table -o trivy-myApp-image-report.html sambhubiswakarma00/myApp:latest "
            }
        }
        
        stage('Push Docker Image') {
            steps {
               script {
                   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                            sh "docker push sambhubiswakarma00/myApp:latest"
                    }
               }
            }
        }
        stage('Deploy To Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8-cred', namespace: 'myApp', restrictKubeConfigAccess: false, serverUrl: 'https://172.31.8.146:6443') {
                            sh "kubectl apply -f cicd/kubernetes/deployment.yaml"
                            sh "kubectl apply -f cicd/kubernetes/service.yaml"
                }
            }
        }
        
        stage('Verify the Deployment') {
            steps {
               #You can find the cluster details like name, server url, etc in ~/.kube/config
               withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8-cred', namespace: 'myApp', restrictKubeConfigAccess: false, serverUrl: 'https://172.31.8.146:6443') {
                        sh "kubectl get pods -n myApp"
                        sh "kubectl get svc -n myApp"
                }
            }
        }
        
        
    }
    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

                def body = """
                    <html>
                    <body>
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                    <h2>${jobName} - Build ${buildNumber}</h2>
                    <div style="background-color: ${bannerColor}; padding: 10px;">
                    <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                    </div>
                    <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                    </div>
                    </body>
                    </html>
                """

                emailext (
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: 'B170026@nitsikkim.ac.in',
                    from: 'biswakarmasambhu@gmail.com',
                    replyTo: 'biswakarmasambhu@gmail.com'',
                    mimeType: 'text/html',
                    attachmentsPattern: 'trivy-myApp-image-report.html'
                )
            }
        }
    }
}
```


## Pipeline Definition
- agent any: Runs the pipeline on any available Jenkins agent.
- environment: Defines environment variables SCANNER_HOME and DOCKER_IMAGE.

## Stages
Git Checkout
- Purpose: To check out the source code from GitHub.
  
Steps:
- Create a directory named website and check out the website repository.
- Create a directory named cicd and check out the Complete-CICD-with-Jenkins repository from the main branch.
  
SonarQube Analysis
- Purpose: To perform static code analysis using SonarQube.
  
Steps:
- Use the SonarQube environment to run the scanner on the website source code.
  
Quality Gate
- Purpose: To ensure the code meets the quality standards defined in SonarQube.
  
Steps:
- Wait for the quality gate results from SonarQube and decide whether to proceed.
  
Build & Tag Docker Image
- Purpose: To build a Docker image from the source code and tag it.
  
Steps:
- Build the Docker image using the Dockerfile in the website directory and tag it as sambhubiswakarma00/myApp:latest.
  
Docker Image Scan
- Purpose: To scan the Docker image for vulnerabilities.
  
Steps:
- Use Trivy to scan the Docker image and output the report to trivy-myApp-image-report.html.
  
Push Docker Image
- Purpose: To push the built Docker image to a Docker registry.
  
Steps:
- Push the tagged Docker image sambhubiswakarma00/myApp:latest to the Docker registry.
  
Deploy To Kubernetes
- Purpose: To deploy the Docker image to a Kubernetes cluster.
  
Steps:
- Apply the Kubernetes deployment and service configurations from the cicd/kubernetes directory.
  
Verify the Deployment
- Purpose: To verify the deployment status in Kubernetes.
  
Steps:
- Get the list of pods and services in the myApp namespace to ensure the deployment is successful.
  
## Post Actions

always
- Purpose: To send a notification email with the pipeline status.
  
Steps:
- Generate an HTML email body with the job name, build number, and pipeline status.
- Send an email with the generated body and the Trivy scan report attached.
  
This pipeline automates the entire process from code checkout to deployment and verification, ensuring code quality and security checks are performed along the way.


Once the pipeline is configured and executed properly, you can access the application using ```any_slave_nodes_ip:host_port```. If you are using service type as "nodeport" you can access the application using slave_nodes_ip:host_port and if you are using service type as "load balancer" in managed kubernetes clusters like eks, aks, etc. then you will be provided external ip address and you can use that external_ip:host_port for accessing your application.
