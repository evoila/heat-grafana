#!/bin/bash

# Expected parameters
VERSION=${VERSION:-4.2.0}

apt-get install -y fontconfig-config fonts-dejavu-core libfontconfig1 

# Install prometheus
curl -Lo /tmp/grafana.deb https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${VERSION}_amd64.deb 
dpkg -i /tmp/grafana.deb

service grafana-server stop
