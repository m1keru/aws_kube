provider "aws" {
  version = "~> 2.0"
  region  = "eu-central-1"
}

data "tls_public_key" "ssh" {
  private_key_pem = "${file("~/.ssh/id_rsa")}"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}


resource "aws_key_pair" "kube" {
  key_name   = "kube"
  public_key = data.tls_public_key.ssh.public_key_openssh
}

# output "ssh" {
#  value = data.tls_public_key.ssh.private_key_pem
# }

output "EIP" {
  value = aws_eip.master[0].public_ip
}
