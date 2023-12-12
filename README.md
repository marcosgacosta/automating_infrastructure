# Intro
This project is part of MundosE's DevOps certification, and the task asked is to _use GitHub Actions to deploy an Apache
on an EC2 using Terraform._

The goal of this Integrative Project is to integrate the following technologies into a project:
1. GitHub Actions
2. Apache
3. Amazon Web Services
    - DynamoDB
    - EC2
    - S3
5. Terraform

This is project is for didactic purposes ony so it is important to recognize that many improvements could be made to this implementation but are beyond the scope.

#First Step: Create the Terraform Files
The following diagram shows the expected output of our Terraform implementation (main.tf):

![Output of _main.tf_.](/assets/diagrams/MainTFDiagram.png)

Moreover, it is required to create and implement a route table and a security group to allow Internet access to our server limited to the services we need.

So, we need a Terraform File that deploys:
1. EC2 Instance (webserver-apache)
2. VPC (custom-vpc)
3. Subnet (public-subnet)
4. Internet Gateway (internet-gateway)
5. Route Table (route-table)
6. Security Group (apache-security)


##EC2 Instance (webserver-apache)

Next, let us create the EC2 Instance with the assigned name, using the AMI Amazon Linux 2023, and create it inside our subnet, our security group and commanding it to run the script that will run Apache Webserver.
```
resource "aws_instance" "webserver-apache" {
  ami           = "ami-0230bd60aa48260c6" # AMI Amazon Linux 2023
  instance_type = "t2.micro"
  key_name                    = webserver
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.apache-security.id]
  subnet_id                   = aws_subnet.public-subnet.id
  user_data                   = "${file("create_apache.sh")}"
}
```
##VPC (custom-vpc)

The VPC will use the range 192.168.0.0/16:
```
resource "aws_vpc" "custom-vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "apache-vpc"
  }
}
```


resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}



