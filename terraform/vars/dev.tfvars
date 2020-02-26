region = "eu-central-1"

## Cluster Specification
kubernetes_version = "1.17.0"

kubernetes_ami = "ami-06bb94548c9ededad"

masters_count = 1

nodes_count = 2

bootstrap_token = "daquqe.t7p1523rkk89c4d6"

## Network Specification
vpc_cidr = "10.0.0.0/20"

private_subnet_cidr_list = ["10.0.4.0/22", "10.0.8.0/22","10.0.12.0/22","10.0.16.0/22"]

#public_subnet_cidr = "10.0.0.0/22"
