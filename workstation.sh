#!/bin/bash

USERID=$(id -u)
TIME_STAMP=$(date +%F-%H-%M-%S)

R="\e [31m"
G="\e [32m"
Y="\e [33m"
N="\e [0m"

ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

VALIDATE() {
    if [ $1 -ne 0 ] 
    then
        echo -e "$2 is ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 is ... $G SUCCESS $N"
    fi
}

CHECK_ROOT() {
    if [ $USERID -ne 0 ] 
    then
        echo  "Plaese run this script as root user"
        exit 1
    fi
}

CHECK_ROOT

# Install dockeryum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
VALIDATE $? "Docker installation"

#Install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.35.0/2026-01-29/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv kubectl /usr/local/bin/kubectl
VALIDATE $? "Kubectl installation"

#Install eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
mv /tmp/eksctl /usr/local/bin
eksctl version
VALIDATE $? "eksctl installation"

#Install kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
VALIDATE $? "kubens installation"

# Helm
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh
# VALIDATE $? "helm installation"

