# Description
Welcome to the EFK stack sandbox.

EFK stands for Elasticsearch, Fluentd, and Kibana. EFK is a popular and the best open-source choice for the Kubernetes log aggregation and analysis.
Elasticsearch helps solve the problem of separating huge amounts of unstructured data and is in use by many organizations. Elasticsearch is commonly deployed alongside Kibana.

Here we have deployed the EFK stack with one sample application exporting its log to Elasticsearch. Explore the setup, tinker with it and learn various concepts while doing so.
`Note:` It might take few minutes for kibana UI to come up. To check the status , run the following commands: 

#### To check the status of pods in elastic-stack namespace:
```
 kubectl -n elastic-stack get pods -o=custom-columns='NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status'
```
#### To check if Kibana is UP (check and if failed, sleep 5 seconds, and repeat until successful):
```
until $(curl --output /dev/null --silent --head --fail `kubectl get pod -n elastic-stack -o jsonpath='{.items[0].spec.nodeName}'`:30601); do
    echo 'Waiting for Kibana UI...'
    sleep 5
done
```

# Exercise
1. Get all records - press `Ctrl+Enter` to execute 
## Query
```
GET _search
{
  "query": {
    "match_all": {}
  }
}
```
Or
```
Get _search
```
## Result
```
{
  "took": 6,
  "timed_out": false,
  "_shards": {
    "total": 6,
    "successful": 6,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 3255,
    "max_score": 1,
    "hits": [
      {
        "_index": ".kibana",
        "_type": "doc",
        "_id": "index-pattern:filebeat-*",
        "_score": 1,
        "_source": {
          "type": "index-pattern",
          "updated_at": "2022-09-24T12:07:51.403Z",
          "index-pattern": {
            "title": "filebeat-*",
            "timeFieldName": "@timestamp"
          }
        }
      },
```

2. Get overall cluster health
### Query
```
Get _cat/health?v
```
### Output
```
epoch      timestamp cluster        status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1664043850 18:24:10  docker-cluster yellow          1         1      5   5    0    0        5             0                  -                 50.0%
```
3. Get indexes
```
GET _cat/indices?v
```
health status index                     uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   filebeat-6.4.2-2022.09.24 RE-pKs0MRaWldazoM7CJXQ   5   1       3061            0    650.9kb        650.9kb
```

4. Get all records for filebeat
```
GET 
