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

az deployment sub create --location "westeurope" --template-file ./deployment-rg.bicep --parameters name=$resourcegroup
az deployment group create --resource-group $resourcegroup --template-file ./deployment.bicep --parameters serverName=$servername serverAdminLogin=$user serverAdminPassword=$password