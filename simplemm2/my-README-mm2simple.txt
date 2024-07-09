With sync.group.offsets.enabled = true
With emit.heartbeats.enabled = true
offset.lag.max=10

# source 9092
% bin/my-kafka-server-start-mm2source.sh

# target 9192
bin/my-kafka-server-start-mm2target.sh

# mm2
bin/my-connect-mirror-maker-sourcetarget.sh

# create source topic
bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic mytopic

# ProduceToSource
bin/kafka-producer-perf-test.sh --producer-props bootstrap.servers=localhost:9092 \
  --throughput -1 --record-size 10 --num-records 10000 --topic mytopic

ConsumeFromSource slowly
 while sleep 0.2; \
   do bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 \
   --group mygroup1 --topic mytopic --max-messages 100 --from-beginning > /dev/null ; \
   done

# in source
% watch bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092  --describe --group mygroup1

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                              HOST            CLIENT-ID
mygroup1        mytopic         0          200             435             235             consumer-mygroup1-1-179044d1-1aa5-48b2-9f50-89046cdeb533 /127.0.0.1      consumer-mygroup1-1
mygroup1        mytopic         1          0               565             565             consumer-mygroup1-1-179044d1-1aa5-48b2-9f50-89046cdeb533 /127.0.0.1      consumer-mygroup1-1

# in target // if sync.group.offsets.enabled = true
% watch bin/kafka-consumer-groups.sh --bootstrap-server localhost:9192  --describe --group mygroup1

Consumer group 'mygroup1' has no active members.
GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
mygroup1        source.mytopic  0          200             435             235             -               -               -
mygroup1        source.mytopic  1          0               565             565             -               -               -

# in target
% ./bin/kafka-console-consumer.sh --bootstrap-server localhost:9192 \
--topic mm2-offset-syncs.source.internal \
--formatter org.apache.kafka.connect.mirror.formatters.OffsetSyncFormatter \
--from-beginning | grep -v heartbeat
OffsetSync{topicPartition=heartbeats-0, upstreamOffset=0, downstreamOffset=0}
OffsetSync{topicPartition=heartbeats-0, upstreamOffset=15, downstreamOffset=15}
OffsetSync{topicPartition=mytopic-0, upstreamOffset=0, downstreamOffset=0}
OffsetSync{topicPartition=mytopic-1, upstreamOffset=0, downstreamOffset=0}
...

% bin/kafka-console-consumer.sh --bootstrap-server localhost:9192 \
  --topic source.checkpoints.internal \
  --formatter org.apache.kafka.connect.mirror.formatters.CheckpointFormatter \
   --from-beginning
Checkpoint{consumerGroupId=mygroup1, topicPartition=source.mytopic-1, upstreamOffset=0, downstreamOffset=0, metatadata=}
Checkpoint{consumerGroupId=mygroup1, topicPartition=source.mytopic-0, upstreamOffset=200, downstreamOffset=200, metatadata=}
...
