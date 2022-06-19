# Spring Boot Kafka event consumer

### Getting it running
* Start the command line, clone the whole repo and change your current directory to 'consumer_kafka' sub-dir
* [Create an Azure EventHub](https://docs.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-cloud-stream-binder-java-app-kafka-azure-event-hub#create-an-azure-event-hub-using-the-azure-portal)
* [Sign in into Azure from your command line (az login) and set your subscription](https://docs.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-cloud-stream-binder-java-app-kafka-azure-event-hub#sign-in-to-azure-and-set-your-subscription)
* [Create an Azure service principal for this app](https://docs.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-cloud-stream-binder-java-app-kafka-azure-event-hub#create-a-service-principal)
* Set and export following variables for this consumer to connect to EventHub (with examples):
    * UNIX: 
      ```
      export SPRING_DATASOURCE_URL=jdbc:postgresql://PGSQL_SERVER_NAME.postgres.database.azure.com:5432/PGSQL_DATABASE_NAME
      export SPRING_DATASOURCE_USERNAME=YOUR_GENERATED_USER_NAME
      export SPRING_DATASOURCE_PASSWORD=YOUR_GENERATED_USER_PASSWORD_
      export SPRING_DATASOURCE_SHOW_SQL=true
      export AZURE_EVENT_HUB_CLIENT_ID=1111111-0000-0000-0000-000000000000
      export AZURE_EVENT_HUB_CLIENT_SECRET=...
      export AZURE_EVENT_HUB_TENANT_ID=2222222-0000-0000-0000-000000000000
      export AZURE_EVENT_HUB_SUBSCRIPTION_ID=3333333-0000-0000-0000-000000000000
      export AZURE_EVENT_HUB_RESOURCE_GROUP=YOUR_EVENT_HUB_RESOURCE_GROUP
      export AZURE_EVENTHUB_NAMESPACE=YOUR_EVENT_HUB_NAMESPACE_NAME
      export SPRING_CLOUD_STREAM_IN_DESTINATION=YOUR_EVENT_HUB_NAME
      export SPRING_CLOUD_STREAM_OUT_DESTINATION=YOUR_EVENT_HUB_NAME
      ```
    * CMD or PowerShell:
```
set SPRING_DATASOURCE_URL=jdbc:postgresql://PGSQL_SERVER_NAME.postgres.database.azure.com:5432/PGSQL_DATABASE_NAME
set SPRING_DATASOURCE_USERNAME=YOUR_GENERATED_USER_NAME
set SPRING_DATASOURCE_PASSWORD=YOUR_GENERATED_USER_PASSWORD_
set SPRING_DATASOURCE_SHOW_SQL=true
set AZURE_EVENT_HUB_CLIENT_ID=1111111-0000-0000-0000-000000000000
set AZURE_EVENT_HUB_CLIENT_SECRET=...
set AZURE_EVENT_HUB_TENANT_ID=2222222-0000-0000-0000-000000000000
set AZURE_EVENT_HUB_SUBSCRIPTION_ID=3333333-0000-0000-0000-000000000000
set AZURE_EVENT_HUB_RESOURCE_GROUP=YOUR_EVENT_HUB_RESOURCE_GROUP
set AZURE_EVENTHUB_NAMESPACE=YOUR_EVENT_HUB_NAMESPACE_NAME
set SPRING_CLOUD_STREAM_IN_DESTINATION=YOUR_EVENT_HUB_NAME
set SPRING_CLOUD_STREAM_OUT_DESTINATION=YOUR_EVENT_HUB_NAME
```
* Start the event consumer app using './mvnw spring-boot:run'
* If you configured [capturing of events in Azure Blob Storage or Azure Data Lake Storage](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-overview), you can check your storage account and review archived events

