## Pre-requisite

### Terraform Installation
- Terraform needs to be installed on the machine where you plan to run the script. You can download Terraform from the official website: Terraform Downloads. Ensure that the Terraform binary is added to your system's PATH 
  so that you can run it from any directory.
  
AWS CLI Installation and Configuration
- Install the AWS Command Line Interface (CLI) on your machine. You can download and install it from the official AWS website or use package managers like pip (for Python) or Homebrew (for macOS).
- After installation, configure the AWS CLI with your AWS access key, secret key, default region, etc. You can do this by running the aws configure command and providing the required information.
  
AWS Account and IAM User
- You need to have an AWS account to provision resources using Terraform.
- Create an IAM user with appropriate permissions (e.g., full access to EC2, VPC, RDS, S3) and generate access key and secret key credentials for that user.
- Use these IAM user credentials to configure the AWS CLI on your machine and terraform will run the terraform script with user's credentials configured in this AWS CLI configuration automatically. Or you can run 
  terraform with other methods of authentication.

Setting up the Terraform configs

Setting your credentials for use by Terraform can be done in a number of ways, but here are the recommended approaches:

  * The default credentials file
  
    Set credentials in the AWS credentials profile file on your local system, located at:

    `~/.aws/credentials` on Linux, macOS, or Unix

    `C:\Users\USERNAME\.aws\credentials` on Windows

    This file should contain lines in the following format:

    ```bash
    [default]
    aws_access_key_id = <your_access_key_id>
    aws_secret_access_key = <your_secret_access_key>
    ```
    Substitute your own AWS credentials values for the values `<your_access_key_id>` and `<your_secret_access_key>`.

  * Environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
  
    Set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

    To set these variables on Linux, macOS, or Unix, use `export`:

    ```bash
    export AWS_ACCESS_KEY_ID=<your_access_key_id>
    export AWS_SECRET_ACCESS_KEY=<your_secret_access_key>
    ```

    To set these variables on Windows, use `set`:

    ```bash
    set AWS_ACCESS_KEY_ID=<your_access_key_id>
    set AWS_SECRET_ACCESS_KEY=<your_secret_access_key>


## Automate the infrastructure provisioning with Terraform

### Network Infrastructure Creation
- Create VPC with two public subnets and one private subnet, where public subnet will be used by our tools instance and private subnet will be used by our k8 cluster.
- Create security group with appropriate permissions.
- Create internet gateway, nat gateway, route tables and routes and associate them with respective subnetes.

### VM creation
- Create ec2 instance for kubernetes master node in private subnet with appropriate security group, keypair and instance type as "t2.medium or higher" as it requires atleast t2.medium to initiate the kubeadm for cluster creation.
- Create ec2 instance for kubernetes master node in private subnet with appropriate security group, keypair and instance type. You can use instance type as "t2.micro" as well as for slave node, we don't have to initialize the cluster here.
- Create tools instance where we will be configuring our tools other than cluster components like jenkins, sonarqube, trivy, promtheus, grafana, loki, etc.
- Create tools instance in public subnet with security group, keypair and instance type that good for running all the tools.

### Ansible Dynamic host file creation
- Dynamically create the host file for ansible using terraform template_file which will automatically fetch the ip address of the instances created and will write it in a hostfile for ansible. Otherwise we have to wait for the instance creation to complete, then manually copy the ip address of the instance to the ansible host file.

### Load Balancer Creation
- Create loadbalance of type "application" for our actual application which will be running on the kubernetes cluster.
- Use two public subnets for the elb as minimum of two public subnets are requried for loadbalancer creation.
- Add listener
- Add target group with targets as two slave nodes.


## Tools Instance configuration with Ansible
- Create ansible roles
- Create task of installing necessary softwares on the instance.
- Install the softwares using bash scripts.
- Create a playbook with roles.
- Execute the playbook

Note: You can find the installation commands for all the tools inside the Ansible/Installs folder.


