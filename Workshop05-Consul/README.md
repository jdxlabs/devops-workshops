# Workshop05 : Consul

## Commands
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
