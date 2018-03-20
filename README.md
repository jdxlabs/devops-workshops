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


## Worshop2 : Ansible-Terraform

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
# should access to the server

ansible-playbook plays/apply_basics.yml
ansible-playbook plays/apply_nodejs.yml
ansible-playbook plays/apply_nodejs_servers.yml

ansible-playbook plays/destroy.yml -e layer_name=main
```


## Worshop3 : Bastion

### Commands
```
cd ./Workshop3-Bastion
ansible-playbook plays/build.yml -e layer_name=main

ssh -F env-ssh.cfg admin@nodejs-server-0
# should access to the server

ansible-playbook plays/destroy.yml -e layer_name=main
```


## Worshop4 : ElasticSearch

### Commands
```
cd ./Workshop4-ElasticSearch
ansible-playbook plays/build.yml -e layer_name=main
ansible-playbook plays/apply_es.yml

ssh -F env-ssh.cfg admin@es-master-0
curl http://localhost/_cluster/health
# should work

ansible-playbook plays/destroy.yml -e layer_name=main
```
