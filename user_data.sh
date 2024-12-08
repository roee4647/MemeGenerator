#!/bin/bash


#Install git and clone files to the Web Server 
sudo yum update -y   # For Amazon Linux or CentOS
sudo yum install -y git
cd 
mkdir App
sudo mkdir .aws
cd App
git clone https://github.com/roee4643/MemeGenerator

cd ..



sudo python3 -m ensurepip --upgrade
sudo /usr/bin/python3 -m pip install --upgrade pip


cd home/ec2-user



#set and install docker 
cd home/ec2-user/App/PokemonApi_MongoDB/PokemonFlask-api


sudo yum install docker -y
sudo service docker start

sudo docker build -t meme-api .
sudo docker run -p 5000:5000 meme-api










