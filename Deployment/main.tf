provider "aws" {
  region = "us-west-2"
}

resource "aws_secretsmanager_secret" "api_key" {
  name        = "my-api-key"
  description = "API Key for my application"
}

resource "aws_secretsmanager_secret_version" "api_key_version" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key
}
   
variable "api_key" {
  description = "API Key for Gemini API"
  type        = string
}


# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "roei_vpc"
  }
}

# Create Public Subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_subnet1"
  }
}

# Create Public Subnet 2 in another availability zone
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2a"  # Different AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_subnet2"
  }
}

# Create Private Subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "Private_subnet1"
  }
}

# Create Private Subnet 2 in another availability zone
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "Private_subnet2"
  }
}

# create s3 bucket

resource "aws_s3_bucket" "meme-storage4643" {

  bucket = "meme-storage4643"
  acl    = "public-read"  # You can adjust the ACL as needed, e.g., 'public-read' for public access.

   versioning {
    enabled = true  # Enable versioning if required
  }
  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion of the bucket
  }
}





# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Public_igw"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "Public_subnet_NAT_Gateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

# Associate Public Route Table with Public Subnet 1 and 2
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Private Route Table"
  }
}

# Associate Private Route Table with Private Subnet 2
resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create a Security Group
resource "aws_security_group" "web_server_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "web-server-security"
  description = "Allow HTTP and SSH inbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "10.0.0.0/24"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "10.0.0.0/24"]
  }
  
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "10.0.0.0/24"]
  }
  
  
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "10.0.0.0/24"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server"
  }
}

# Launch an EC2 instance
resource "aws_instance" "web_server_1" {
  ami                         = "ami-0d081196e3df05f4d"  # Amazon Linux 2 AMI
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet_2.id
  associate_public_ip_address = true
  key_name                    = "vockey"
  security_groups             = [aws_security_group.web_server_sg.id]  # Use security group ID instead of name
  
  #user_data = file("user_data.sh")
  
  tags = {
    Name = "Meme-generator-server"
    }
}

# Create a parameter in SSM with the public IP of the EC2 instance
resource "aws_ssm_parameter" "public_ip" {
  name        = "/Meme-generator-server/public_ip"
  description = "Public IP of the EC2 instance"
  type        = "String"
  value       = "$aws_instance.web_server_1.public_ip"  # Correct reference to the EC2 instance's public IP

  tags = {
    Name = "PublicIPParameter"
  }
}

# Output the parameter name
output "parameter_name" {
  value = aws_ssm_parameter.public_ip.name
}
