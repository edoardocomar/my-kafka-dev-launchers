# topology
source cluster: kraft broker nodes 1,2 9092 9292 (9093 9293 controllers)
target cluster: kraft broker nodes 1,2 19092 19292  (19093 19293 controllers)
connect runs 2 workers in target
REST http 8083 8283

# startup
bin/my-kafka-server-start-source1.sh
bin/my-kafka-server-start-source2.sh
bin/my-kafka-server-start-target1.sh
bin/my-kafka-server-start-target2.sh
bin/my-connect-distributed1.sh
bin/my-connect-distributed2.sh

# REST API to create connectors 
curl -v -X POST  -H "Content-Type: application/json" http://localhost:8083/connectors -d @my-msc.json
curl -v -X POST  -H "Content-Type: application/json" http://localhost:8083/connectors -d @my-cpc.json

# get info 
http://localhost:8083/connectors?expand=status&expand=info

# create source topic
bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic mytopic --partitions 2

# ProduceToSource
bin/kafka-producer-perf-test.sh --producer-props bootstrap.servers=localhost:9092 \
  --throughput -1 --record-size 10 --num-records 10000 --topic mytopic

# ConsumeFromSource slowly
 while sleep 0.2; \
   do bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
   --group mygroup1 --topic mytopic --max-messages 100 --from-beginning > /dev/null ; \
   done

# topics in source
% bin/kafka-topics.sh --bootstrap-server localhost:9092 --list
__consumer_offsets
mytopic

# groups in source
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group mygroup1

# topics in target
% bin/kafka-topics.sh --bootstrap-server localhost:19092 --list
__consumer_offsets
__transaction_state
connect-configs
connect-offsets
connect-status
my-source.checkpoints.internal
my-source.mytopic
mm2-offset-syncs.my-source.internal

# OffsetSync & Checkpoints in target
% ./bin/kafka-console-consumer.sh --bootstrap-server localhost:19092 \
--topic mm2-offset-syncs.my-source.internal \
--formatter org.apache.kafka.connect.mirror.formatters.OffsetSyncFormatter \
--from-beginning 

% bin/kafka-console-consumer.sh --bootstrap-server localhost:19092 \
  --topic my-source.checkpoints.internal \
  --formatter org.apache.kafka.connect.mirror.formatters.CheckpointFormatter \
   --from-beginning

# groups in target
bin/kafka-consumer-groups.sh --bootstrap-server localhost:19092 --describe --group mygroup1
