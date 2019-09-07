# Workshop10 : Graylog

## Commands
```
cd ./Workshop10-Graylog
ansible-playbook plays/build.yml -e layer_name=main
ansible-playbook plays/apply_consul.yml
ansible-playbook plays/apply_logstore.yml

ssh -F env-ssh.cfg admin@consul-master-0
consul members

ssh -F env-ssh.cfg admin@logstore-0 -L 9000:localhost:9000
# open your browser at this address : http://localhost:9000/sources#3600

# to test the http input
curl -XPOST http://<logstore-ip>:12201/gelf -p0 -d '{"short_message":"Hello there", "host":"example.org", "facility":"test", "_foo":"bar"}'

ansible-playbook plays/destroy.yml -e layer_name=main
```
