#!/bin/bash

printf "%s\n%s\nus-east-1\njson" "$1" "$2" | aws configure --profile default-profile

rm -rf $HOME/install-dir

mkdir $HOME/install-dir
WORKING_DIR=$HOME/install-dir

HADOOP_HOME=/usr/lib/hadoop
HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
SPARK_HOME=/usr/lib/spark
SPARK_CONF_DIR=${SPARK_HOME}/conf

PATH=${HADOOP_HOME}/bin:$PATH

S3_BUCKET=squeakysimple-k8s-aws-io
FILE=dr-elephant.zip

aws s3 cp "s3://${S3_BUCKET}/${FILE}" $WORKING_DIR

cd $WORKING_DIR; unzip $FILE
rm -rf $FILE

cd dr-elephant; cd dist; unzip dr-elephant*.zip

echo "db_url=$3" >> $WORKING_DIR/dr-elephant/app-conf/elephant.conf
echo "db_name=$4" >> $WORKING_DIR/dr-elephant/app-conf/elephant.conf
echo "db_user=$5" >> $WORKING_DIR/dr-elephant/app-conf/elephant.conf
echo "db_password=$6" >> $WORKING_DIR/dr-elephant/app-conf/elephant.conf

$WORKING_DIR/dr-elephant/dist/dr-elephant*/bin/start.sh $WORKING_DIR/dr-elephant/app-conf

if [ "$?" -ne "0" ];
then
        echo "Dr Elephant failed to start.";
fi

