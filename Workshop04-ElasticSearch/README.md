# Workshop04 : ElasticSearch

## Commands
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
