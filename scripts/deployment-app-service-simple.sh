#This script expects the variables $eventHubClientId and $eventHubClientSecret

export clientIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

export UNIQUE_STRING="`openssl rand -hex 5`"

export AZURE_RESOURCE_GROUP="maabr-${UNIQUE_STRING}_rg"
export AZURE_LOCATION="eastus"
export AZURE_RESOURCE_TAGS="{ 'Workload': 'DEVTEST', 'CostCenter': 'FIN', 'Department': 'RESEARCH', 'DeleteNightly': 'true', 'DeleteWeekly': 'true' }"

export AZURE_EVENT_HUB_CLIENT_ID=${eventHubClientId} \
export AZURE_EVENT_HUB_CLIENT_SECRET=${eventHubClientSecret} \
export AZURE_EVENT_HUB_RESOURCE_GROUP="maabr-${UNIQUE_STRING}-evt_rg" \
export AZURE_EVENT_HUB_NAMESPACE="maabr-${UNIQUE_STRING}-evt-ns" \
export SPRING_CLOUD_STREAM_IN_DESTINATION="maabr-hub" \
export SPRING_CLOUD_STREAM_IN_GROUP="\$Default" \
export SPRING_CLOUD_STREAM_OUT_DESTINATION="maabr-hub" \

export AZURE_DB_SERVER_NAME="maabr-${UNIQUE_STRING}-pg"
export AZURE_DB_NAME="tododb"

export AZURE_DB_ADMIN_NAME="a`openssl rand -hex 12`"
export AZURE_DB_ADMIN_PASSWORD=`openssl rand -base64 22`
export AZURE_API_DB_USER_NAME="u`openssl rand -hex 12`"
export AZURE_API_DB_USER_PASSWORD=`openssl rand -base64 22`

export AZURE_API_SERVICE_NAME="maabr-${UNIQUE_STRING}-api"
export AZURE_API_SERVICE_PORT="443"

export AZURE_WEB_SERVICE_NAME="maabr-${UNIQUE_STRING}-web"
export AZURE_WEB_SERVICE_PORT="443"

export AZURE_EVENT_CONSUMER_SERVICE_NAME="maabr-${UNIQUE_STRING}-evt"
export AZURE_EVENT_CONSUMER_SERVICE_PORT="443"

az deployment sub create --location ${AZURE_LOCATION} --template-file ./deployment-rg.bicep --parameters name=${AZURE_EVENT_HUB_RESOURCE_GROUP} resourceTags="${AZURE_RESOURCE_TAGS}"

az deployment group create --resource-group ${AZURE_EVENT_HUB_RESOURCE_GROUP} --template-file ./deployment-event-hub.bicep \
              --parameters location=${AZURE_LOCATION} \
                           eventHubNamespaceName=${AZURE_EVENT_HUB_NAMESPACE} \
                           eventHubName=${SPRING_CLOUD_STREAM_OUT_DESTINATION}

az deployment sub create --location ${AZURE_LOCATION} --template-file ./deployment-rg.bicep --parameters name=$AZURE_RESOURCE_GROUP resourceTags="${AZURE_RESOURCE_TAGS}"

az deployment group create --resource-group ${AZURE_RESOURCE_GROUP} --template-file ./deployment.bicep \
              --parameters  location=${AZURE_LOCATION}  \
                            dbServerName=${AZURE_DB_SERVER_NAME} \
                            dbName=${AZURE_DB_NAME} \
                            dbAdminName=${AZURE_DB_ADMIN_NAME} \
                            dbAdminPassword=${AZURE_DB_ADMIN_PASSWORD} \
                            dbUserName=${AZURE_API_DB_USER_NAME} \
                            dbUserPassword=${AZURE_API_DB_USER_PASSWORD} \
                            eventHubClientId=${AZURE_EVENT_HUB_CLIENT_ID} \
                            eventHubClientSecret=${AZURE_EVENT_HUB_CLIENT_SECRET} \
                            eventHubRG=${AZURE_EVENT_HUB_RESOURCE_GROUP} \
                            eventHubNamespaceName=${AZURE_EVENT_HUB_NAMESPACE} \
                            springCloudStreamInDestination=${SPRING_CLOUD_STREAM_IN_DESTINATION} \
                            springCloudStreamInGroup=${SPRING_CLOUD_STREAM_IN_GROUP} \
                            springCloudStreamOutDestination=${SPRING_CLOUD_STREAM_OUT_DESTINATION} \
                            apiServiceName=${AZURE_API_SERVICE_NAME} \
                            apiServicePort=${AZURE_API_SERVICE_PORT} \
                            webServiceName=${AZURE_WEB_SERVICE_NAME} \
                            webServicePort=${AZURE_WEB_SERVICE_PORT} \
                            eventConsumerServiceName=${AZURE_EVENT_CONSUMER_SERVICE_NAME} \
                            eventConsumerServicePort=${AZURE_EVENT_CONSUMER_SERVICE_PORT} \
                            clientIPAddress=$clientIP

az group delete --resource-group ${AZURE_RESOURCE_GROUP}
az group delete --resource-group ${AZURE_EVENT_HUB_RESOURCE_GROUP}
az group delete --resource-group ${AZURE_LOG_ANALYTICS_WRKSPC_RESOURCE_GROUP}

./mvnw spring-boot:run

/Applications/Postgres.app/Contents/Versions/14/bin/psql "host=${dbServerName}.postgres.database.azure.com port=5432 dbname=${dbName} user=$adminName password=$adminPassword sslmode=require"

