### Project Title
This project is to deploy maven project on AWS infrastructure.

#### AWS infrastructure details 
* VPC with CIDR block 11.0.0.0/16 
* Internet gateway attached to VPC
* Security Group with ingress port 22,80,81,82,83,84 and egress all.
* Two subnet in two different AZ
* Route table attached to VPC
* Application load balancer, listen on port 80, attached to instance.
* IAM user, having a policy to describe and stop the instance.
* Two instance in two different AZ.

##### Prerequisites

##### Required Software’s to install on controlling machine

* To integrate and run the build 
  - Jenkins 
* To create infra on AWS Cloud 
  - Terraform 
* To configure AWS instances created by terraform 
  - Ansible 
* To setup the encrypted password for IAM user 
  - Keybase 
* To create tomcat container on AWS  
  - Docker
* To perform all above action 
- AWS Account

### Step to Install the Applicaiton 
* below steps needs to be follow on controlling machine 
* Create directory as Anisble and Terraform and place the site.yml and main.tf
* Create directory in Terraform for your AWS secrete key, access key and perm file.
* Create a shell script in Ansible directory to create invertory.ini file from terraform output.
* Create pipeline job in Jenkins and copy the Jenkins file content in pipeline tab.

### Necessary changes in Jenkinsfile
* change the git repo path
* change the other path according to your setup. 

### Necessary changes for Terraform file
* Create a variable file for aws_access_key, aws_secret_key and private_key_path.
* Install keybase on controlling machine and provide keybase user in pgp_key in terraform file.

### Build Flow
* Applicaiton checkout from GIT repo.
* Build the application with maven.
* Create infrastructure on AWS as listed in main.tf file.
* Redirect aws_instance_public_dns to aws_dns_name.txt file.
* Redirect the password output to home directory of keybase user.
* Shell scripting call to generate invertory.ini file for hosts, mentioned in aws_dns_name.txt
* Ansible playbook call to configure hosts for Docker, Tocat Apache installation.
* Catch build FAILURE

### Author
Arun Gaurav - arun.gaurav1989@gmail.com
