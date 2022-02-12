# Credentials
variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "key_name" {
  type    = string
  default = "xubuntu"
}

# Mongo variables

variable "mongo_ami" {
  type    = string
  default = "ami-0019f1e85386a77e1"
}

variable "mongo_sg" {
  type    = list(string)
  default = ["sg-0f0e97945c754d7e7"]
}
variable "mongo_subnet" {
  type    = string
  default = "subnet-028ee84ffdc16acb7"
}

variable "mongo_priv_ip" {
  type    = string
  default = "172.31.100.27"
}



# Application variables
variable "app_priv_ip" {
  type    = string
  default = "172.31.101.10"
}

variable "app_ami" {
  type    = string
  default = "ami-08d32d917d2fb11a2"
}

variable "app_sg" {
  type    = list(string)
  default = ["sg-0e02eba496c99d615"]
}
variable "app_subnet" {
  type    = string
  default = "subnet-03b51fa22c07c43de"
}
