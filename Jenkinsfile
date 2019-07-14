node('master') {
	try{
		
		/* App checkout from Git */
			
		stage('Checkout ') {
		 	git 'https://github.com/argaurava/DevOps-Demo-Project.git'
		}

		/* Maven call to Build and Clean Application */
		
		stage('Build Automation') {    
			sh 'mvn clean package'
		}
		
		/* Terraform call to buid Infra on AWS cloud */
		
		dir('/root/DevOpsProject/Terr/Terraform') {
			stage('Infa Creation'){
				sh "/usr/local/bin/terraform apply -auto-approve -var-file=../modulone.tfvars"
				sh "/usr/local/bin/terraform output aws_instance_public_dns > /root/DevOpsProject/Ansible/aws_dns_name.txt"
				sh "terraform output password > /home/arun_gaurav1989/password.txt && chmod 755 /home/arun_gaurav1989/password.txt"
			}
		}
		
		/* Ansible call to configure aws instanse for webserver */
		
		dir('/root/DevOpsProject/Ansible') {
			stage('Ansible Configuration'){
				sh "/root/DevOpsProject/Ansible/create_inv.sh"
				sh "/usr/bin/ansible-playbook -i invertory.ini site.yml"
			}
		}
	}
	catch(err) {
		notify("Error ${err}")
		currentBuild.result='FAILURE'
	}

}
