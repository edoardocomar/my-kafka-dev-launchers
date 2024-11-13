# kafka-dev-launchers

Shell scripts used for development to run local Kafka instance(s)

* 3-kraft-servers-and-3-brokers:
  A 3-Node Kraft cluster (plus 3 optional brokers)

* mm2connectdistributed:
  Two 2-nodes Kafka clusters and a 2-workers Connect cluster used to run MirroMaker2 in "Connect distributed" mode

* simple:
  1-Broker Kafka "cluster", either KRaft (combnined or with separate controller) or with ZK quorum

* simplemm2:
  Two 1-node KRaft Kafkas and 1 node Mirromaker2 in dedicated mode

