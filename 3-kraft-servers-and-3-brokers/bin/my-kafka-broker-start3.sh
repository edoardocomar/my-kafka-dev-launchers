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

base_dir=$(dirname $0)

if [ "x$KAFKA_LOG4J_OPTS" = "x" ]; then
    # export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$base_dir/../config/my-log4j.properties"
    export KAFKA_LOG4J_OPTS="-Dlog4j2.configurationFile=$base_dir/../config/my-log4j2.yaml"
fi

if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    export KAFKA_HEAP_OPTS="-Xmx2G -Xms2G"
fi

EXTRA_ARGS=${EXTRA_ARGS-'-name kafkaServer -loggc'}

COMMAND=$1
case $COMMAND in
  -daemon)
    EXTRA_ARGS="-daemon "$EXTRA_ARGS
    shift
    ;;
  *)
    ;;
esac

export KAFKA_JMX_OPTS="-Djava.rmi.server.hostname=127.0.0.1"
export LOG_DIR=${HOME}/tmp/3or6kafkas/logs3
mkdir -p ${LOG_DIR}

$base_dir/kafka-storage.sh format --config config/my-broker3.properties --cluster-id lTGdS9wQTBiBiYFwi5jiCA --ignore-formatted

export KAFKA_DEBUG=no
export DEBUG_SUSPEND_FLAG=n
export JAVA_DEBUG_PORT=5305

exec $base_dir/kafka-run-class.sh $EXTRA_ARGS kafka.Kafka config/my-broker3.properties "$@"
