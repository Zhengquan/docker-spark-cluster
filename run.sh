#!/bin/bash

#Creating some variables to make the docker run command more readable
#App jar environment used by the spark-submit image
SPARK_APPLICATION_LOCATION="/opt/spark-apps/wordcount.py"
SPARK_APPLICATION_ARGS="/opt/spark-data/t8.shakespeare.txt"

# Extra submit args used by the spark-submit image
# SPARK_SUBMIT_ARGS="--conf spark.executor.extraJavaOptions='-Dconfig-path=/opt/spark-apps/dev/config.conf'"

#We have to use the same network as the spark cluster(internally the image resolves spark master as spark://spark-master:7077)
docker run \
    --network docker-spark-cluster_spark-network \
    -v /tmp/spark-apps:/opt/spark-apps \
    -v /tmp/spark-data:/opt/spark-data \
    --env SPARK_APPLICATION_LOCATION=$SPARK_APPLICATION_LOCATION \
    --env SPARK_APPLICATION_ARGS=$SPARK_APPLICATION_ARGS \
    spark-submit:latest
