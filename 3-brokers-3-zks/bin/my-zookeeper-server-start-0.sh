#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# if [ $# -lt 1 ];
# then
# 	echo "USAGE: $0 [-daemon] zookeeper.properties"
# 	exit 1
# fi
base_dir=$(dirname $0)

if [ "x$KAFKA_LOG4J_OPTS" = "x" ]; then
    export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$base_dir/../config/my-log4j.properties"
fi

if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    export KAFKA_HEAP_OPTS="-Xmx512M -Xms512M"
fi

EXTRA_ARGS=${EXTRA_ARGS-'-name zookeeper -loggc'}

COMMAND=$1
case $COMMAND in
  -daemon)
     EXTRA_ARGS="-daemon "$EXTRA_ARGS
     shift
     ;;
 *)
     ;;
esac

export LOG_DIR=${HOME}/tmp/3kafka3zook/zookeeper0-logs
mkdir -p ${LOG_DIR}

echo "dataDir=${HOME}/tmp/3kafka3zook/zookeeper0-data" >> config/my-zookeeper0.properties
mkdir -p ${HOME}/tmp/3kafka3zook/zookeeper0-data
echo "0" > ${HOME}/tmp/3kafka3zook/zookeeper0-data/myid
exec $base_dir/kafka-run-class.sh $EXTRA_ARGS org.apache.zookeeper.server.quorum.QuorumPeerMain config/my-zookeeper0.properties "$@"
