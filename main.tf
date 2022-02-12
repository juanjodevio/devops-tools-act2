terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

# Seteamos las credenciales de aws
provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# despliegue de la instancia de mongodb
resource "aws_instance" "mongodb" {
  ami           = var.mongo_ami
  instance_type = "t2.micro"

  vpc_security_group_ids = var.mongo_sg
  subnet_id              = var.mongo_subnet
  private_ip             = var.mongo_priv_ip
  tags = {
    Name = "MongoDB"
  }
}

# despliegue de la aplicacion nodejs
resource "aws_instance" "app_server" {
  ami                    = var.app_ami
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = var.app_subnet
  private_ip             = var.app_priv_ip
  vpc_security_group_ids = var.app_sg
  tags = {
    Name = "ExampleAppServerInstance"
  }

  # Crea el archivo hello.js pasando como parametro la ip privada de la instancia de mongodb recien creada
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

  # copia el archivo app_setup.sh a la instancia desplegada
  # app_setup tiene los comandos bash necesarios para configurar y desplegar la aplicacion
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

  # copia el archivo node con la configracion de nginx
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
  
  # modifica los privilegios de app_setup.sh y lo ejecuta
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
