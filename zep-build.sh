./dev/change_scala_version.sh 2.11
mvn clean package -Pbuild-distr \
    -DskipTests \
    -Pspark-2.1 \
    -Pscala-2.11 \
    -Pr \
    -pl '!groovy,!hbase,!pig,!file,!flink,!ignite,!kylin,!lens,!cassandra,!elasticsearch,!bigquery,!alluxio,!scio,!neo4j'

//
mvn clean package -Pbuild-distr \
    -Pspark-2.1 \
    -Pscala-2.11 \
    -Ppyspark
    -Pr \
    -pl 'zeppelin-interpreter, zeppelin-zengine, zeppelin-display, spark-dependencies, spark, markdown, angular, shell, livy, jdbc, python, zeppelin-web, zeppelin-server, zeppelin-jupyter, zeppelin-distribution'
    -DskipTests

// 2nd on 10-13-17
-pl 'zeppelin-interpreter,
zeppelin-zengine,
zeppelin-display,
spark,
markdown,
angular,
shell,
livy,
jdbc,
file,
python,
zeppelin-web,
zeppelin-server,
zeppelin-jupyter,
zeppelin-distribution'

// initial; build
-pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,zeppelin-web,zeppelin-server,zeppelin-distributio, spark,r,markdown,angular,shell,jdbc,python' \

-pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,spark-dependencies,!groovy,spark,markdown,angular,shell,livy,!hbase,!pig,jdbc,!file,!flink,!ignite,!kylin,python,!lens,!cassandra,!elasticsearch,!bigquery,!alluxio,!scio,!neo4j,zeppelin-web,zeppelin-server,!zeppelin-jupyter,zeppelin-distribution'

// pl for removed
    -pl '\!groovy, \!hbase, \!pig, \!file, \!flink, \!ignite, \!kylin, \!lens, \!cassandra, \!elasticsearch, \!bigquery, \!alluxio, \!scio, \!neo4j'

\!groovy,
\!hbase,
\!pig,
\!file,
\!flink,
\!ignite,
\!kylin,
\!lens,
\!cassandra,
\!elasticsearch,
\!bigquery,
\!alluxio,
\!scio,
\!neo4j,

// removed list
groovy
hbase
pig
file
flink
ignite
kylin
lens
cassandra
elasticsearch
bigquery
alluxio
scio
neo4j

//. full list
zeppelin-interpreter
zeppelin-zengine
zeppelin-display
spark-dependencies
groovy
spark
markdown
angular
shell
livy
hbase
pig
jdbc
file
flink
ignite
kylin
python
lens
cassandra
elasticsearch
bigquery
alluxio
scio
neo4j
zeppelin-web
zeppelin-server
zeppelin-jupyter
zeppelin-distribution