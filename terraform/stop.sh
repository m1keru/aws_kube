#!/bin/bash
terraform destroy -auto-approve -var-file=vars/dev.tfvars
