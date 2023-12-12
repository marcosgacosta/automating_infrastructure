# Intro
This project is part of MundosE's DevOps certification, and the task asked is to _use GitHub Actions to deploy an Apache
on an EC2 using Terraform._

The goal of this Integrative Project is to integrate the following technologies into a project:
1. GitHub Actions
2. Apache
3. Amazon Web Services
    - EC2
    - S3
5. Terraform

This is project is for didactic purposes ony so it is important to recognize that many improvements could be made to this implementation but are beyond the scope.

# First Step: Create the Terraform Files
The following diagram shows the expected output of our Terraform implementation (main.tf):

![Output of _main.tf_.](/assets/diagrams/MainTFDiagram.png)

Moreover, it is required to create and implement a route table and a security group to allow Internet access to our server limited to the services we need.

So, we need a Terraform File that deploys:
1. EC2 Instance (webserver_apache)
2. VPC (custom_vpc)
3. Subnet (public_subnet)
4. Internet Gateway (internet_gateway)
5. Route Table (route_table)
6. Security Group (apache_security)


## EC2 Instance (webserver_-_apache)

Next, let us create the EC2 Instance with the assigned name, using the AMI Amazon Linux 2023, and create it inside our subnet, our security group and commanding it to run the script that will run Apache Webserver.
```
resource "aws_instance" "webserver_apache" {
  ami           = "ami-0230bd60aa48260c6" # AMI Amazon Linux 2023
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.apache_security.id]
  subnet_id                   = aws_subnet.public_subnet.id
  user_data                   = "${file("create_apache.sh")}"
}
```

## VPC (custom_vpc)
The following block creates a VPC using the range 192.168.0.0/16:
```
resource "aws_vpc" "custom_vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "apache_vpc"
  }
}
```

## Subnet (public_subnet)
The following block creates _public_subnet_ inside _custom_vpc_, using the range 192.168.10.0/24

```
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "192.168.10.0/24"
  availability_zone = "us-east-1a"

}
```
## Internet Gateway (internet_gateway)
The following block creates the Internet Gateway (internet_gateway) so our VPC, hence our Apache Server, can access the Internet:

```
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.custom_vpc.id

}
```
## Route Table (route_table)
The following block creates a route table and attaches it to custom_vpc, and it also creates the default route to the _internet_gateway_.
```
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
```
  
We need to associate our new Route Table to our Public Subnet:
```
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}
```

## Security Group (apache_security)
Now we need to create a Security Group for our Apache Webserver that allows Web and SSH traffic.
```
resource "aws_security_group" "apache_security" {
  name        = "apache_security"
  description = "Allow Web and SSH traffic."
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allows SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
 ingress {
    description      = "Allows HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
```

## Region and Provider
To allow our Terraform to work, we need to use all this code and specify our region and our provider:
```
provider "aws" {
  region = "us-east-1"
}
```

## Output EC2 Instance Public IP
We want to check if the instance is working, so to do that we are going to ask Terraform to provide us the public IP of the Instance:
```
output "WebServer_Apache_IP" {
  value = aws_instance.webserver_apache.public_ip
}
```

## Results
All this is what we can see in main.tf. If we run it. It gives us a fully functioning EC2 Instance running Apache.

If we run *terraform apply --auto-approve* we have the following output:

![terraform apply Output.](/assets/diagrams/terraform_output.png)

If we write that IP in our web browser we can see our Apache Server fully functioning:

![terraform apply Output.](/assets/diagrams/apache_output.png)



# Terraform Backend
To ensure that our Terraform Statefile is secure and have consistency, we are going to set up a remote backend. For this we need to create an S3 Bucket. We create the bucket using the GUI and we call it *mundose-pin-test1337*.

![S3 Bucket created.](/assets/diagrams/s3bucket.png)

There is a possibility to lock the statefile using DynamoDB if we are part of the team. Since it is not our case today, we will not implement it but it is strongly recommended. So we create backend.tf with the following code.: 
```
terraform {
  backend "s3"{
    bucket = "mundose-pin-test1337"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}
```
Now, everytime we update our infrastructure the Terraform statefile will be stored in the S3 bucket.

# GitHub Actions
The following step is to setup GitHub Actions so we can automate the deployment of our infrastructure. To do this we use the Template provided by GitHub Actions with some modifications.
By default, the Terraform template from GitHub Actions includes the following line:
```
if: github.ref == 'refs/heads/"main"' && github.event_name == 'push'
```
If we want to automate it so changes in our files update our infrastructure, we can use that. But since we are just testing, we are going to comment that line.

## Secret Keys
To be able to execute commands in Terraform and in AWS we need to add the following line when we run Terraform init or Apply.
```
 env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

To be able to install Terraform on the GitHub Actions enviromnent we also need to set up the secret key *TF_API_TOKEN*.

So these are the three secret keys we need to configure in our repository:
1. AWS_ACCESS_KEY_ID
2. WS_SECRET_ACCESS_KEY
3. TF_API_TOKEN

After setting up those variables, we can run our Action and we can see the result:

![Actions output.](/assets/diagrams/actions1.png)

![Actions output.](/assets/diagrams/actions2.png)

Inside the step Terraform Apply we can find our Webserver IP Address and if we paste it on our Web Browser we have the following:

![Webserver running after GitHub Action.](/assets/diagrams/apache_output2.png)

## Terraform Destroy
Since we are practicing, we want to be able to remove our infrastructure. For this we create the following *terraform_destroy.yml* where we set it up to run manually when we want (workflow_dispatch):
```
name: Terraform Destroy
on:
 workflow_dispatch:

jobs:
 terraform-destroy:
   runs-on: ubuntu-latest
   env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_REGION: 'us-east-1'
   steps:
     - name: Terraform destroy
       id: destroy
       run: terraform destroy -auto-approved
```       

## Conclusion
So now we have automated our infrastructure. We can make changes in our Terraform files, commit them and GitHub Actions will automatically update our infrastructure to match our new file.

