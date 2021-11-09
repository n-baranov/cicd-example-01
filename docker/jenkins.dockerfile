FROM ubuntu:20.04

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install gnupg -y
RUN apt-get install wget -y
RUN wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
RUN sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get install openjdk-11-jdk -y
RUN apt-get update
RUN apt-get install jenkins -y
RUN apt-get install openssh-server -y
RUN apt-get install ufw -y
RUN ufw allow 8080
RUN ufw allow OpenSSH
RUN ufw enable

RUN apt-get install awscli -y

RUN apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update -y
RUN apt-get install docker-ce docker-ce-cli containerd.io -y
RUN usermod -aG docker jenkins

RUN apt-get install unzip
RUN wget https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip
RUN unzip terraform_1.0.9_linux_amd64.zip
RUN rm terraform_1.0.9_linux_amd64.zip
RUN mv terraform /bin/

RUN echo 'jenkins    ALL=(ALL:ALL) ALL' >> /etc/sudoers

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
