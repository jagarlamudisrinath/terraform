### Aws ##
provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region = var.AWS_REGION
}

##instance #



resource "aws_instance" "vault" {
  ami = "ami-099e632efca6304a4"
  instance_type = "t2.micro"
  key_name      = "myfirstkeypair"
  tags = {
    Name = "hcl-vault-server"
  }
  iam_instance_profile = "vault"
}

resource "aws_instance" "agent" {
  ami = "ami-088849be53e68a08a"
  instance_type = "t2.micro"
  key_name      = "myfirstkeypair"
  tags = {
    Name = "hcl-agent-server"
  }
  iam_instance_profile = "vault"
  root_block_device {
    volume_size = "20"
  }
}


output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.vault.*.public_ip
}
