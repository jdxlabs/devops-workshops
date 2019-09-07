# Workshop03 : Bastion

## Commands
```
cd ./Workshop03-Bastion
ansible-playbook plays/build.yml -e layer_name=main

ssh -F env-ssh.cfg admin@nodejs-server-0
# should access to the server

ansible-playbook plays/destroy.yml -e layer_name=main
```
