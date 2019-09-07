# Workshop09 : Vault

## Commands
```
cd ./Workshop09-Vault
ansible-playbook plays/build.yml -e layer_name=main
ansible-playbook plays/apply_consul.yml
ansible-playbook plays/apply_vault.yml

ssh -F env-ssh.cfg admin@vault-server-0
consul members
vault status

vault init
vault unseal <key> (x3)
vault auth <token>
vault status

vault write secret/toto value=tata
vault read secret/toto

ansible-playbook plays/destroy.yml -e layer_name=main
```
