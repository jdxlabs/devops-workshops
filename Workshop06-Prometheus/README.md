# Workshop06 : Prometheus

## Commands
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
