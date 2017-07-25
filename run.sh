#!/usr/bin/env bash

# Checking the existence of the first parameter from the command line
if [ -n "$1" ]
then
  NUMBER_WEB_INSTANCES=$1
else
  NUMBER_WEB_INSTANCES=1 # default
fi
SLEEP_INTERVAL=10
MYSQL_USER=domru
MYSQL_PASSWORD=passsword01
MYSQL_ROOT_PASSWORD=passsword02
MYSQL_DATABASE=mv_db

#Get web-application source code
git submodule init > /dev/null 2>&1
git submodule update > /dev/null 2>&1

#Copy original config file docker-compose.yml
yes | cp docker-compose.yml.orig docker-compose.yml > /dev/null 2>&1

#Add specified parameters to docker-compose config
sed -i "s/mysqluser/${MYSQL_USER}/g" docker-compose.yml
sed -i "s/user_password/${MYSQL_PASSWORD}/g" docker-compose.yml
sed -i "s/root_password/${MYSQL_ROOT_PASSWORD}/g" docker-compose.yml
sed -i "s/database_name/${MYSQL_DATABASE}/g" docker-compose.yml

#Run virtual infrastructure (configures in docker-compose.yml)
docker-compose up -d --build --scale web=${NUMBER_WEB_INSTANCES}

#Wait for running database service
sleep ${SLEEP_INTERVAL}

#Restore a database data from backup-file
docker exec domru_db_1 sh -c 'exec mysql --user=root --password=${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} < dump.sql'

#Show info about containers that are executing
docker-compose ps
docker stats --no-stream