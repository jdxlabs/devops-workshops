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
curl -s http://10.0.110.249:9200/_cluster/health | python -mjson.tool
# {
#     "active_primary_shards": 0,
#     "active_shards": 0,
#     "active_shards_percent_as_number": 100.0,
#     "cluster_name": "sandbox",
#     "delayed_unassigned_shards": 0,
#     "initializing_shards": 0,
#     "number_of_data_nodes": 2,
#     "number_of_in_flight_fetch": 0,
#     "number_of_nodes": 3,
#     "number_of_pending_tasks": 0,
#     "relocating_shards": 0,
#     "status": "green",
#     "task_max_waiting_in_queue_millis": 0,
#     "timed_out": false,
#     "unassigned_shards": 0
# }

ansible-playbook plays/destroy.yml -e layer_name=main
```


## Worshop5 : Consul

### Commands
```
cd ./Workshop5-Consul
ansible-playbook plays/build.yml -e layer_name=main
ansible-playbook plays/apply_consul.yml

consul members
# Node             Address            Status  Type    Build  Protocol  DC
# consul-client-0  10.0.110.18:8301   alive   client  0.9.2  2         dc1
# consul-master-0  10.0.110.221:8301  alive   server  0.9.2  2         dc1

ansible-playbook plays/destroy.yml -e layer_name=main
```


## Worshop6 : Prometheus

### Commands
```
cd ./Workshop6-Prometheus
ansible-playbook plays/build.yml -e layer_name=main

ansible-playbook plays/apply_basics.yml
ansible-playbook plays/apply_consul.yml
consul members
# Node             Address            Status  Type    Build  Protocol  DC
# consul-master-0  10.0.110.221:8301  alive   server  0.9.2  2         dc1
# monitor-0        10.0.110.79:8301   alive   client  0.9.2  2         dc1
# nodejs-server-0  10.0.110.198:8301  alive   client  0.9.2  2         dc1

ansible-playbook plays/apply_nodejs.yml
ansible-playbook plays/apply_nodejs_servers.yml
ssh -F env-ssh.cfg admin@nodejs-server-0
pm2 ls

ansible-playbook plays/apply_monitor_exporters.yml
ansible-playbook plays/apply_monitor.yml
ssh -F env-ssh.cfg admin@monitor-0 -L 3000:localhost:3000 -L 9090:localhost:9090
# import this dashboard : https://grafana.com/dashboards/1860

ansible-playbook plays/destroy.yml -e layer_name=main
```
