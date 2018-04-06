# devops-workshops
Workshops around the devops methodology


## Workshop01 : Terraform

### Terraform installation
* Get it here : https://www.terraform.io/downloads.html
* Copy it with the other executables.
* `terraform -version`

### Commands
```
cd ./Workshop01-Terraform
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


## Workshop02 : Ansible-Terraform

### Commands
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


## Workshop03 : Bastion

### Commands
```
cd ./Workshop03-Bastion
ansible-playbook plays/build.yml -e layer_name=main

ssh -F env-ssh.cfg admin@nodejs-server-0
# should access to the server

ansible-playbook plays/destroy.yml -e layer_name=main
```


## Workshop04 : ElasticSearch

### Commands
```
cd ./Workshop04-ElasticSearch
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


## Workshop05 : Consul

### Commands
```
cd ./Workshop05-Consul
ansible-playbook plays/build.yml -e layer_name=main
ansible-playbook plays/apply_consul.yml

consul members
# Node             Address            Status  Type    Build  Protocol  DC
# consul-client-0  10.0.110.18:8301   alive   client  0.9.2  2         dc1
# consul-master-0  10.0.110.221:8301  alive   server  0.9.2  2         dc1

ansible-playbook plays/destroy.yml -e layer_name=main
```


## Workshop06 : Prometheus

### Commands
```
cd ./Workshop06-Prometheus
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

## Workshop07 : Docker

### Instructions
* Install Docker [following the procedure for your machine](https://grafana.com/dashboards/1860)
* At the end, you can add the Nomad orchestrator [following this tutorial](https://github.com/jdxlabs/hello-nomad)
* You have cheatsheets available for [Docker](https://jdxlabs.com/notes/docker) and for [Nomad](https://jdxlabs.com/notes/nomad)

### Commands
```
cd ./Workshop07-Docker

# to build the docker image
docker build -t hello-docker -f node-app/Dockerfile node-app/.

# to run your container locally
docker run -d -p 8080:8080 --name hello-docker hello-docker

# to see informations about the container
docker ps -a
docker stats

# to have a shell access for your container
docker exec -it hello-docker sh

# to stop the container and remove the image
docker stop -t0 hello-docker
docker rm hello-docker
```

## Workshop08 : Nomad

```
cd ./Workshop08-Nomad

aws ecr create-repository --repository-name bootstrap-nomad-<your-initials>
aws ecr describe-repositories

docker build -t bootstrap-nomad -f node-app/Dockerfile node-app/.
$(aws ecr get-login --no-include-email --region us-east-1)
docker tag bootstrap-nomad <account-id>.dkr.ecr.us-east-1.amazonaws.com/bootstrap-nomad-<your-initials>:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/bootstrap-nomad-<your-initials>:latest

ansible-playbook plays/build.yml -e layer_name=main
ansible-playbook plays/apply_consul.yml
ansible-playbook plays/apply_nomad_masters.yml
ansible-playbook plays/apply_nomad_workers.yml
ansible-playbook plays/nomad_push_job.yml

ssh -F env-ssh.cfg admin@nomad-master-0
consul members
nomad server-members
nomad node-status
nomad run nomad/jobs/bootstrap-nomad.hcl
nomad status bootstrap-nomad

ssh -F env-ssh.cfg admin@nomad-worker-0
curl http://<current-ip>:11201

ansible-playbook plays/destroy.yml -e layer_name=main
```


## Workshop09 : Vault

### Commands
```
cd ./Workshop09-Vault
ansible-playbook plays/build.yml -e layer_name=main
ansible-playbook plays/apply_consul.yml
ansible-playbook plays/apply_vault.yml
ansible-playbook plays/vault_init.yml

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


## Workshop10 : Graylog

### Commands
```
cd ./Workshop10-Graylog
ansible-playbook plays/build.yml -e layer_name=main
ansible-playbook plays/apply_consul.yml
ansible-playbook plays/apply_logstore.yml

ssh -F env-ssh.cfg admin@consul-master-0
consul members

ssh -F env-ssh.cfg admin@logstore-0 -L 9000:localhost:9000
# open your browser at this address : http://localhost:9000/sources#3600

ansible-playbook plays/destroy.yml -e layer_name=main
```
