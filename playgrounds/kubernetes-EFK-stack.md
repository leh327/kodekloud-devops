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
1. Get all records
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

2. 
