#!/bin/bash

VERSION=${VERSION:-4.2.0-1}

yum install -y initscripts fontconfig

# Install prometheus
curl -Lo /tmp/grafana.rpm https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-${VERSION}.x86_64.rpm
rpm -Uvh /tmp/grafana.rpm

service grafana-server stop

systemctl daemon-reload
systemctl enable grafana-server.service
