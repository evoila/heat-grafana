#!/bin/bash

TEST=$1
DISTRIBUTION=$2
KEY=$3
IMAGE=$4
FLAVOR=$5
PUBLIC_NETWORK=$6

openstack stack create -t test/$TEST.yaml\
 -e test/lib/heat-iaas/resources.yaml\
 -e test/lib/heat-common/resources-$DISTRIBUTION.yaml\
 -e test/lib/heat-galera/resources-$DISTRIBUTION.yaml\
 -e test/lib/heat-memcached/resources-$DISTRIBUTION.yaml\
 -e resources-$DISTRIBUTION.yaml\
 --parameter key=$KEY\
 --parameter image=$IMAGE\
 --parameter flavor=$FLAVOR\
 --parameter public_network=$PUBLIC_NETWORK\
 --wait\
 test-$TEST
