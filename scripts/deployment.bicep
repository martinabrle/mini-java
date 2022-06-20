param dbServerName string
param dbName string

@secure()
param dbAdminName string
@secure()
param dbAdminPassword string

@secure()
param dbUserName string
@secure()
param dbUserPassword string

@secure()
param eventHubClientId string
@secure()
param eventHubClientSecret string

param eventHubTenantId string = tenant().tenantId //event hub may be in another tenant
param eventHubSubscriptionId string = subscription().id //event hub may be in another subscription
param eventHubRG string
param eventHubNamespaceName string
param springCloudStreamInDestination string
param springCloudStreamInGroup string
param springCloudStreamOutDestination string

param clientIPAddress string
param apiServiceName string
param apiServicePort string

param webServiceName string
param webServicePort string

param eventConsumerServiceName string
param eventConsumerServicePort string

param location string = resourceGroup().location

param tagsArray object = resourceGroup().tags


resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' existing = {
  name: eventHubNamespaceName
  scope: resourceGroup(eventHubRG)
}

resource postgreSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: dbServerName
  location: location
  tags: tagsArray
  sku: {
    name: 'Standard_B2s'
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: dbAdminName
    administratorLoginPassword: dbAdminPassword
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    createMode: 'Default'
    highAvailability: {
      mode: 'Disabled'
      standbyAvailabilityZone: ''
    }
    network: {
      delegatedSubnetResourceId: ''
      privateDnsZoneArmResourceId: ''
    }
    storage: {
      storageSizeGB: 32
    }
    version: '13'
  }
}

resource postgreSQLDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2021-06-01' = {
  name: dbName
  parent: postgreSQLServer
  properties: {
    charset: 'utf8'
    collation: 'en_US.utf8'
  }
}

resource allowClientIPFirewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2021-06-01' = {
  name: 'allowClientIP'
  parent: postgreSQLServer
  properties: {
    endIpAddress: clientIPAddress
    startIpAddress: clientIPAddress
  }
}

resource allowAllIPsFirewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2021-06-01' = {
  name: 'allowAllIps'
  parent: postgreSQLServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource apiServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${apiServiceName}-plan'
  location: location
  tags: tagsArray
  dependsOn: [
    postgreSQLServer
  ]
  properties: {
    reserved: true
  }
  sku: {
    name: 'S1'
  }
  kind: 'linux'
}

resource apiService 'Microsoft.Web/sites@2021-03-01' = {
  name: apiServiceName
  location: location
  tags: tagsArray
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: apiServicePlan.id
    siteConfig: {
      linuxFxVersion: 'JAVA|11-java11'
      scmType: 'None'
    }
  }

  resource apiServicePARMS 'config@2021-03-01' = {
    name: 'web'
    kind: 'string'
    properties: {
      appSettings: [
        {
          name: 'PORT'
          value: apiServicePort
        }
        {
          name: 'SPRING_DATASOURCE_URL'
          value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}'
        }
        {
          name: 'SPRING_DATASOURCE_USERNAME'
          value: dbUserName
        }
        {
          name: 'SPRING_DATASOURCE_PASSWORD'
          value: dbUserPassword
        }
        {
          name: 'SPRING_DATASOURCE_SHOW_SQL'
          value: 'false'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
  }
}

resource webServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${webServiceName}-plan'
  location: location
  tags: tagsArray
  dependsOn: [
    apiService
  ]
  properties: {
    reserved: true
  }
  sku: {
    name: 'S1'
  }
  kind: 'linux'
}

resource eventHubNamespaceRootManageSharedAccessKey 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  parent: eventHubNamespace
  name: 'RootManageSharedAccessKey'

}

// var listEventHubKeysEndpoint = '${eventHubNamespace.id}/AuthorizationRules/RootManageSharedAccessKey'
// var eventHubNamespaceConnectionString = 'Endpoint=sb://${eventHubNamespace.name}.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=${listKeys(listEventHubKeysEndpoint, eventHubNamespace.apiVersion).primaryKey}'

resource webService 'Microsoft.Web/sites@2021-03-01' = {
  name: webServiceName
  location: location
  tags: tagsArray
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: webServicePlan.id
    siteConfig: {
      linuxFxVersion: 'JAVA|11-java11'
      scmType: 'None'
    }
  }
  resource webServicePARMS 'config@2021-03-01' = {
    name: 'web'
    kind: 'string'
    properties: {
      appSettings: [
        {
          name: 'PORT'
          value: webServicePort
        }
        {
          name: 'API_URI'
          value: 'https://${apiServiceName}.azurewebsites.net/todos/'
        }
        {
          name: 'AZURE-EVENTHUB-NAMESPACE-CONNECTION-STRING'
          value: eventHubNamespaceRootManageSharedAccessKey.listKeys().primaryConnectionString
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
  }
}

resource eventConsumerServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${eventConsumerServiceName}-plan'
  location: location
  tags: tagsArray

  properties: {
    reserved: true
  }
  sku: {
    name: 'S1'
  }
  kind: 'linux'
}

resource eventConsumerService 'Microsoft.Web/sites@2021-03-01' = {
  name: eventConsumerServiceName
  location: location
  tags: tagsArray
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: eventConsumerServicePlan.id
    siteConfig: {
      linuxFxVersion: 'JAVA|11-java11'
      scmType: 'None'
    }
  }

  resource eventConsumerServicePARMS 'config@2021-03-01' = {
    name: 'web'
    kind: 'string'
    properties: {
      appSettings: [
        {
          name: 'PORT'
          value: eventConsumerServicePort
        }
        {
          name: 'SPRING_DATASOURCE_URL'
          value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}'
        }
        {
          name: 'SPRING_DATASOURCE_USERNAME'
          value: dbUserName
        }
        {
          name: 'SPRING_DATASOURCE_PASSWORD'
          value: dbUserPassword
        }
        {
          name: 'AZURE_EVENT_HUB_CLIENT_ID'
          value: eventHubClientId
        }
        {
          name: 'AZURE_EVENT_HUB_CLIENT_SECRET'
          value: eventHubClientSecret
        }
        {
          name: 'AZURE_EVENT_HUB_TENANT_ID'
          value: eventHubTenantId
        }
        {
          name: 'AZURE_EVENT_HUB_SUBSCRIPTION_ID'
          value: eventHubSubscriptionId
        }
        {
          name: 'AZURE_EVENT_HUB_NAMESPACE'
          value: eventHubNamespaceName
        }
        {
          name: 'SPRING_CLOUD_STREAM_IN_DESTINATION'
          value: springCloudStreamInDestination
        }
        {
          name: 'SPRING_CLOUD_STREAM_IN_GROUP'
          value: springCloudStreamInGroup
        }
        {
          name: 'SPRING_CLOUD_STREAM_OUT_DESTINATION'
          value: springCloudStreamOutDestination
        }
        {
          name: 'AZURE_EVENT_HUB_RESOURCE_GROUP'
          value: eventHubRG
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
  }
}
