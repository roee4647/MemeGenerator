#!/bin/bash

#start terraform file
terraform apply 

#Ask for the Api key 
read -p "Enter your Gemini API key: " GEMINI_API_KEY
#export GEMINI_API_KEY as an environment variable
export GEMINI_API_KEY

#store the instance public ip value that stored in the parameter store to EC2_PUBLIC_IP
EC2_PUBLIC_IP=$(aws ssm get-parameter --name "/ec2/public_ip" --with-decryption --query "Parameter.Value" --output text)
#export EC2_PUBLIC_IP as an environment variable
export EC2_PUBLIC_IP
#print EC2_PUBLIC_IP 
echo "EC2_PUBLIC_IP = $EC2_PUBLIC_IP"

#start run ansible play book on the instance 
ansible-playbook -i $EC2_PUBLIC_IP, --private-key "/home/roei/keyfiles/labsuser.pem" -u ec2-user ec2_setup.yaml