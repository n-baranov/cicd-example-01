This is an example of a CI/CD deployment of a web server using:

GitHub, Jenkins, Terraform, Docker, Kubernetes (K8s), AWS, Laravel PHP.
In the beginning we have:
- a host machine;
- Developers' Git repository;
- CI/CD Git repository.

The host-machine with Jenkins (an Amazon EC2 instance created manually with a bootstrap file) is always running and listening for a webhook from Developers' GitHub. The webhook event (means that a "push" command were executed in Developers' Git repository) starts a jenkins pipeline from a Jenkinsfile in CI/CD Git repository.

The Jenkins pipeline:
- creates (if it doean't exist yet) an AWS S3 Bucket for our Terraform .tfstate file;
- pulls project from CI/CD GitHub;
- runs a Terraform project;
- creates a K8s deployment of 2 pods from AWS ECR-stored image;
- creates K8s HorizontalPodAutoscaler & LoadBalancer services;
- runs a simple HTTP health check;
- waits for 2 minutes;
- runs a Terraform destroy i.e. destroys everything.

The Terraform project:
- stores .tfstate file in AWS S3 Bucket;
- creates docker image from Dockerfile in CI/CD  Git repository;
- pushes the docker image into AWS ECR;
- creates in AWS: VPC, IAM roles, EKS Cluster with 1 node;
- destroy everything he created when asked.

I've been deliberately avoiding using existing Terraform modules in this one. Just because.

The sequence of creating and configuring your Jenkins host-machine/GitHub:
- launch an Ubuntu Server 20.04 LTS with a user data from /aws-ubuntu-bootstrap/script.sh;
- run <jenkins_ip>:8080 and a console simultaneously;
- unlock your Jenkins GUI with the console token ($ sudo cat /var/lib/jenkins/secrets/initialAdminPassword);
- configure Jenkins with default plugins;
- install CloudBees AWS Credential plugin;
- create "jenkins-AWS" & "jenkins-git" Global credentials in your Jenkins GUI;
- $ ssh-keygen;
- copy id_rsa.pub token into "SSH and GPG keys" in your GitHub GUI;
- copy id_rsa token into your "jenkins-git" credentials (type=SSH Username with private key);
- $ sudo usermod -aG docker jenkins (for some reason this command has no effect during bootstraping);
- $ sudo service jenkins restart;
- in Jenkins GUI: "Build new item" -> "Pipeline" -> check "GitHub project", git@github.com:<your_id>/<your_project>.git/ -> check "GitHub hook trigger for GITScm polling" -> Pipeline script from SCM -> Git -> git@github.com:<your_id>/<your_project>.git -> add "jenkins-git" credentials -> branch: */main -> Script Path: jenkins/jenkinsfile;
- add webhook in your GitHub GUI -> Project Settings -> Webhooks -> http://<ip>:8080/github-webhook/ -> application/json;

Made by Nikita Baranov (nikita.baranov.devops@gmail.com)
