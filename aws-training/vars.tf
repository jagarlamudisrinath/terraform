variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "us-east-1"
}

variable "ssh_key_private" {
  default = "/home/sjagarlamudi/.ssh/pemfiles/myfirstkeypair.pem"
}