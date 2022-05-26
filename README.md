https://docs.microsoft.com/en-us/azure/app-service/configure-language-java?pivots=platform-linux
    --config maven plug in by ./mvnw com.microsoft.azure:azure-webapp-maven-plugin:2.2.0:config
    --deploy ./mvnw package azure-webapp:deploy
    --start locally ./mvnw spring-boot:run
https://docs.microsoft.com/en-us/azure/app-service/quickstart-java?pivots=platform-linux&tabs=javase

az webapp list-runtimes --linux
az webapp create --name maabrle-todo-api --plan maabrle-todo-api-plan --resource-group DELETEME_RG --runtime "JAVA|11-java11"
az appservice plan create -g DELETEME_RG -n maabrle-todo-api-plan --is-linux --sku S1 --location eastus
az webapp log tail --name maabrle-todo-api  --resource-group DELETEME_RG

TODO:
* replace passwords with managed identities
* add AppGateway
* add EventHub for modifying or creating Todo records
* add form for creating new records
* add Azure Function to create new events in EventHub

