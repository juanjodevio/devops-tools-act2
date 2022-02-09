terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_subnet" "app_subnet" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.10.0/24"
#   map_public_ip_on_launch =true
# }

# resource "aws_subnet" "mongo_subnet" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.11.0/24"
#   map_public_ip_on_launch =true
# }

# resource "aws_security_group" "allow_http" {
#   name        = "allow_http"
#   description = "Allow http traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description      = "HTTP from VPC"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "allow_http"
#   }
# }
# resource "aws_security_group" "allow_mongo" {
#   name        = "allow_mongo"
#   description = "Allow mongo traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description      = "MONGO from VPC"
#     from_port        = 27017
#     to_port          = 27017
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port        = 27017
#     to_port          = 27017
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "allow_http"
#   }
# }

resource "aws_instance" "app_server" {
  ami           = "ami-08d32d917d2fb11a2"
  instance_type = "t2.micro"
  key_name      = var.key_name
  # subnet_id=aws_subnet.app_subnet.id 
  # security_groups=["sg-0e02eba496c99d615"] 
  vpc_security_group_ids = ["sg-0e02eba496c99d615"]
  tags = {
    Name = "ExampleAppServerInstance"
  }



  provisioner "file" {
    content = <<-EOT
   const http = require('http');

const hostname = 'localhost';
const port = 8080;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end("Hello World!, Soy Juan Palomino Melo\nConnection string to MongoDb: mongodb://${aws_instance.mongodb.private_ip}:27017");
});

server.listen(port, hostname, () => {
  console.log("Server running at http://"+hostname+":"+port+"/");
}); 
  EOT 

    destination = "/tmp/hello.js"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/xubuntu.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "app/app_setup.sh"
    destination = "/tmp/app_setup.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/xubuntu.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "app/node"
    destination = "/tmp/node"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/xubuntu.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/app_setup.sh", "/tmp/app_setup.sh", ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/xubuntu.pem")
      host        = self.public_ip
    }
  }
}


resource "aws_instance" "mongodb" {
  ami           = "ami-0019f1e85386a77e1"
  instance_type = "t2.micro"
  # subnet_id=aws_subnet.app_subnet.id 
  # vpc_security_group_ids = [aws_security_group.allow_mongo.id]
  tags = {
    Name = "MongoDB"
  }
}

# data "template_file" "app_file" {
#   template = "${file("app/App.js.tpl")}"
#   # vars = {
#   #   consul_address = "${aws_instance.consul.private_ip}"
#   # }
# }

