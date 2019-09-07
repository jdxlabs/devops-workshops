# Workshop08 : Nomad

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
