# devops-workshops
Worshops around the devops methodology


## Worshop1 : Terraform

### Terraform installation
* Get it here : https://www.terraform.io/downloads.html
* Copy it with the other executables.
* `terraform -version`

### Commands
```
cd ./Workshop1-Terraform
aws configure --profile sandbox-admin
# be sure to be connected to the AWS accout you want

ssh-keygen
# put the key you want to associate in ~/.ssh

export AWS_PROFILE=sandbox-admin

terraform init
terraform plan -var-file=env.tfvars
terraform apply -var-file=env.tfvars
terraform destroy -var-file=env.tfvars
```


## Worshop2 : Terraform

### Commands
```
cd ./Workshop2-Ansible-Terraform
ansible-playbook plays/build.yml -e layer_name=main

ansible -m ping all
# should return :
# nodejs-server-0 | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }

ssh -F env-ssh.cfg admin@nodejs-server-0
```
