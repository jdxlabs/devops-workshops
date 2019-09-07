# Workshop02 : Ansible-Terraform

## Commands
```
cd ./Workshop02-Ansible-Terraform
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
