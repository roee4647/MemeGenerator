#! bin/bash
pwd
cd home/ec2-user
#Install git and clone files to the Web Server 
sudo yum update -y   # For Amazon Linux or CentOS
sudo yum install -y git
cd 
mkdir App
cd App

git clone https://github.com/roee4647/MemeGenerator

cd ..


export GEMINI_API_KEY=$HOST_GEMINI_API_KEY


echo $GEMINI_API_KEY

#Gemini_key=$GEMINI_API_KEY



echo "export GEMINI_API_KEY='$GEMINI_API_KEY'" >> /home/ec2-user/.bash_profile
source /home/ec2-user/.bash_profile



sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo > /dev/null <<EOF
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOF

sudo yum install -y mongodb-org
#sudo systemctl start mongod

# Configure MongoDB to bind to 0.0.0.0
sudo sed -i 's/127\.0\.0\.1/0.0.0.0/g' /etc/mongod.conf
#sudo systemctl stop mongod
sudo systemctl start mongod


cd home/ec2-user

 # Create the .env file in the target directory
cat <<EOF > /home/ec2-user/App/MemeGenerator/MongoDbMemes/.env
    ${file("${path.module}/.env")}
EOF

#set and install docker 
sudo yum install docker -y
sudo service docker start


cd /home/ec2-user/App/MemeGenerator/GeminiApiApp
sudo docker build -t gemini-api-app .
sudo docker run -e GEMINI_API_KEY="$GEMINI_API_KEY" -p 5000:5000 gemini-api-app

cd /home/ec2-user/App/MemeGenerator/MongoDbMemes
sudo docker build -t meme-mongo-app .
sudo docker run -p 80:5001 -e GEMINI_API_KEY="AIzaSyBab5VArMDK59FsdW9hNgR3_5ASaV_tpJU" meme-mongo-app
