#!/bin/bash

ADMIN_PASSWORD=${ADMIN_PASSWORD}
PROMETHEUS_ADDR=${PROMETHEUS_ADDR}
ELASTICSEARCH_ADDR=${ELASTICSEARCH_ADDR}

service grafana-server start

# Wait until grafana is listening. After that we can be sure the node
# successfully initialized the database.
while ! nc -z 127.0.0.1 3000; do   
  sleep 1
done

# ADD PROMETHEUS AS DATASOURCE

cat <<EOF > /tmp/grafana-datasource-prometheus.json
{
  "Name": "prometheus",
  "Type": "prometheus",
  "Access": "proxy",
  "url": "http://$PROMETHEUS_ADDR:9090",
  "basicAuth": false,
  "withCredentials": false,
  "isDefault": true
}
EOF

cat <<EOF > /tmp/grafana-datasource-elasticsearch.json
{
  "name": "elasticsearch",
  "type": "elasticsearch",
  "access": "proxy",
  "url": "http://$ELASTICSEARCH_ADDR:9200",
  "password": "",
  "user": "",
  "database": "[logstash-]YYYY.MM.DD.HH",
  "basicAuth": false,
  "withCredentials": false,
  "isDefault": false,
  "jsonData": {
    "esVersion": 5,
    "interval": "Hourly",
    "timeField": "@timestamp"
  }
}
EOF

curl -XPOST 127.0.0.1:3000/api/datasources \
 -H 'Content-Type: application/json;charset=UTF-8' \
 --user admin:$ADMIN_PASSWORD \
 -d @/tmp/grafana-datasource-prometheus.json

curl -XPOST 127.0.0.1:3000/api/datasources \
 -H 'Content-Type: application/json;charset=UTF-8' \
 --user admin:$ADMIN_PASSWORD \
 -d @/tmp/grafana-datasource-elasticsearch.json

