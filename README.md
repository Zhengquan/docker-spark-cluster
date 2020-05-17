# Spark Cluster with Docker & docker-compose

# General

A simple spark standalone cluster for your testing environment purposses. A *docker-compose up* away from you solution for your spark development environment.

The Docker compose will create the following containers:

container|Ip address
---|---
spark-master|10.5.0.2
spark-worker|10.5.0.3

# Installation

The following steps will make you run your spark cluster's containers.

## Pre requisites

* Docker installed

* Docker compose  installed

* A spark Application Jar to play with(Optional)

## Build the images

The first step to deploy the cluster will be the build of the custom images, these builds can be performed with the *build-images.sh* script. 

The executions is as simple as the following steps:

```sh
chmod +x build-images.sh
./build-images.sh
```

This will create the following docker images:

* spark-base:2.3.1: A base image based on java:alpine-jdk-8 wich ships scala, python3 and spark 2.3.1

* spark-master:2.3.1: A image based on the previously created spark image, used to create a spark master containers.

* spark-worker:2.3.1: A image based on the previously created spark image, used to create spark worker containers.

* spark-submit:2.3.1: A image based on the previously created spark image, used to create spark submit containers(run, deliver driver and die gracefully).

## Run the docker-compose

The final step to create your test cluster will be to run the compose file:

```sh
docker-compose up
```

## Validate your cluster

Just validate your cluster accesing the spark UI on each worker & master URL.

### Spark Master

http://localhost:8080/

![alt text](docs/spark-master.png "Spark master UI")

### Spark Worker 1

http://localhost:8081/

![alt text](docs/spark-worker-1.png "Spark worker 1 UI")


# Resource Allocation 

This cluster is shipped with three workers and one spark master, each of these has a particular set of resource allocation(basically RAM & cpu cores allocation).

* The default CPU cores allocation for each spark worker is 1 core.

* The default RAM for each spark-worker is 1024 MB.

* The default RAM allocation for spark executors is 256mb.

* The default RAM allocation for spark driver is 128mb

* If you wish to modify this allocations just edit the env/spark-worker.sh file.

# Binded Volumes

To make app running easier I've shipped two volume mounts described in the following chart:

Host Mount|Container Mount|Purposse
---|---|---
/tmp/spark-apps|/opt/spark-apps|Used to make available your app's jars on all workers & master
/tmp/spark-data|/opt/spark-data| Used to make available your app's data on all workers & master

This is basically a dummy DFS created from docker Volumes...(maybe not...)

# Run a sample application

Now let`s make a **wild spark submit** to validate the distributed nature of our new toy following these steps:

## Create a Python spark app

## Ship your python scripts & dependencies on the Workers and Master

A necesary step to make a **spark-submit** is to copy your application bundle into all workers, also any configuration file or input file you need.

Luckily for us we are using docker volumes so, you just have to copy your app and configs into /tmp/spark-apps, and your input files into /tmp/spark-files.

```bash
#Copy spark application into all workers's app folder
wget https://raw.githubusercontent.com/apache/spark/master/examples/src/main/python/wordcount.py
mv wordcount.py /tmp/spark-apps

#Copy spark application configs into all workers's data folder
wget https://ocw.mit.edu/ans7870/6/6.006/s08/lecturenotes/files/t8.shakespeare.txt
mv t8.shakespeare.txt /tmp/spark-data

```

## Check the successful copy of the data and app jar (Optional)

This is not a necessary step, just if you are curious you can check if your app code and files are in place before running the spark-submit.

```sh
# Worker 1 Validations
docker exec -ti spark-worker ls -l /opt/spark-apps
docker exec -ti spark-worker ls -l /opt/spark-data

```
After running one of this commands you have to see your app's python scripts and files.


## Use docker spark-submit

```bash

SPARK_APPLICATION_LOCATION="/opt/spark-apps/wordcount.py"
SPARK_APPLICATION_ARGS="/opt/spark-data/t8.shakespeare.txt"

#We have to use the same network as the spark cluster(internally the image resolves spark master as spark://spark-master:7077)
docker run \
    --network docker-spark-cluster_spark-network \
    -v /tmp/spark-apps:/opt/spark-apps \
    -v /tmp/spark-data:/opt/spark-data \
    --env SPARK_APPLICATION_LOCATION=$SPARK_APPLICATION_LOCATION \
    --env SPARK_APPLICATION_ARGS=$SPARK_APPLICATION_ARGS \
    spark-submit:latest

```
