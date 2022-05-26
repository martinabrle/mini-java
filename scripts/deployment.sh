#!/bin/bash
# helper script for manual deployment
# call with ./deployment.sh --resourcegroup=*** --servername=*** --user=*** --password=***
# note to myself: to create a resource group manually: az group create --location "WestEurope" --name "testpg-rg"
while [ $# -gt 0 ]; do
  case "$1" in
     --resourcegroup=*)
      resourcegroup="${1#*=}"
      ;;   
     --servername=*)
      servername="${1#*=}"
      ;; 
    --user=*)
      user="${1#*=}"
      ;;
    --password=*)
      password="${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

clientIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
adminName="a`openssl rand -hex 12`"
adminPassword=`openssl rand -base64 22`
dbUserName="u`openssl rand -hex 12`"
dbUserPassword=`openssl rand -base64 22`
location="eastus2"
dbName="tododb"

./mvnw spring-boot:run

/Applications/Postgres.app/Contents/Versions/14/bin/psql "host=${dbServerName}.postgres.database.azure.com port=5432 dbname=${dbName} user=$adminName password=$adminPassword sslmode=require"

SPRING_DATASOURCE_URL="jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}"
SPRING_DATASOURCE_PASSWORD=$adminPassword
SPRING_DATASOURCE_USERNAME=$adminName
SPRING_DATASOURCE_SHOW_SQL=true
export SPRING_DATASOURCE_URL 
export SPRING_DATASOURCE_USERNAME
export SPRING_DATASOURCE_PASSWORD
export SPRING_DATASOURCE_SHOW_SQL

echo "Admin:'$adminName'"
echo "Password:'$adminPassword'"

echo "---------------"
echo "User:'$dbUserName'"
echo "Password:'$adminPassword'"

az deployment sub create --location $location --template-file ./deployment-rg.bicep --parameters name=$resourcegroup
az deployment group create --resource-group $resourcegroup --template-file ./deployment.bicep \
              --parameters location=$location  \
                           dbServerName=$dbServerName \
                           dbName=$dbName \
                           dbAdminName=$adminName \
                           dbAdminPassword=$adminPassword \
                           dbUserName=$userName \
                           dbUserPassword=$userPassword \
                           apiServiceName=$apiServiceName \
                           apiServicePort=$apiServicePort \
                           webServiceName=$webServiceName \
                           webServicePort=$webServicePort \
                           clientIPAddress=$clientIP
