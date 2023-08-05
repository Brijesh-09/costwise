#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker

# Run WordPress container using Docker
sudo docker run -d -p 80:80 --name wordpress-container -e WORDPRESS_DB_HOST=${rds_endpoint} -e WORDPRESS_DB_USER=mywpdb -e WORDPRESS_DB_PASSWORD=mydbwppassword -e WORDPRESS_DB_NAME=mywpdb wordpress:php8.0-fpm
