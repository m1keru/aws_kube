#!/bin/bash

packer.io build -var-file=settings.json -var 'subnet_id=subnet-0c33df75dba310418' -force kube.json
