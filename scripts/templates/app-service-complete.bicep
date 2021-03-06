param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceRG string
param appInsightsName string

param keyVaultName string
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
param eventHubTenantId string = tenant().tenantId //event hub may be in another tenant (requires script modification)
param eventHubSubscriptionId string = substring(subscription().id, lastIndexOf(subscription().id, '/') + 1) //event hub may be in another subscription (requires script modification)
param eventHubRG string = resourceGroup().name //event hub may be in another resource group (requires script modification)
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

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceRG)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  dependsOn: [
    logAnalyticsWorkspace
  ]
  location: location
  kind: 'java'
  tags: tagsArray
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  tags: tagsArray
  sku: {
    capacity: 1
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    isAutoInflateEnabled: false
    kafkaEnabled: true
    zoneRedundant: false
  }
  resource eventHub 'eventhubs@2022-01-01-preview' = {
    name: springCloudStreamOutDestination
    properties: {
      messageRetentionInDays: 1
      partitionCount: 1
      status: 'Active'
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  dependsOn: [
    appInsights
  ]
  location: location
  tags: tagsArray
  properties: {
    createMode: 'default'
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
  }
}

resource keyVaultSecretDatabaseAdminName 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'DB-ADMIN-NAME'
  properties: {
    value: dbAdminName
    contentType: 'string'
  }
}

resource keyVaultSecretDatabaseAdminPassword 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'DB-ADMIN-PASSWORD'
  properties: {
    value: dbAdminPassword
    contentType: 'string'
  }
}

resource keyVaultSecretSpringDatasourceUserName 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'SPRING-DATASOURCE-USERNAME'
  properties: {
    value: dbUserName
    contentType: 'string'
  }
}
resource keyVaultSecretSpringDatasourceUserPassword 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'SPRING-DATASOURCE-PASSWORD'
  properties: {
    value: dbUserPassword
    contentType: 'string'
  }
}

resource keyVaultSecretSpringDataSourceURL 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'SPRING-DATASOURCE-URL'
  properties: {
    value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}'
    contentType: 'string'
  }
}

resource keyVaultSecretAzureEventHubClientId 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'EVENT-HUB-CLIENT-ID'
  properties: {
    value: eventHubClientId
    contentType: 'string'
  }
}

resource keyVaultSecretAzureEventHubClientSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'EVENT-HUB-CLIENT-SECRET'
  properties: {
    value: eventHubClientSecret
    contentType: 'string'
  }
}

resource keyVaultSecretAzureEventHubTenantId 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'EVENT-HUB-TENANT-ID'
  properties: {
    value: eventHubTenantId
    contentType: 'string'
  }
}

resource keyVaultSecretAzureEventHubSubscriptionId 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'EVENT-HUB-SUBSCRIPTION-ID'
  properties: {
    value: eventHubSubscriptionId
    contentType: 'string'
  }
}

resource keyVaultSecretAzureEventHubRG 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'EVENT-HUB-RESOURCE-GROUP'
  properties: {
    value: eventHubRG
    contentType: 'string'
  }
}

resource keyVaultSecretAzureEventHubNamespace 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'EVENT-HUB-NAMESPACE'
  properties: {
    value: eventHubNamespaceName
    contentType: 'string'
  }
}

resource keyVaultSecretSpringCloudStreamInDestination 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'SPRING-CLOUD-STREAM-IN-DESTINATION'
  properties: {
    value: springCloudStreamInDestination
    contentType: 'string'
  }
}

resource keyVaultSecretSpringCloudStreamInGroup 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'SPRING-CLOUD-STREAM-IN-GROUP'
  properties: {
    value: springCloudStreamInGroup
    contentType: 'string'
  }
}

resource keyVaultSecretSpringCloudStreamOutDestination 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'SPRING-CLOUD-STREAM-OUT-DESTINATION'
  properties: {
    value: springCloudStreamOutDestination
    contentType: 'string'
  }
}

resource eventHubNamespaceRootManageSharedAccessKey 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  parent: eventHubNamespace
  name: 'RootManageSharedAccessKey'

}

resource keyVaultSecretAzureEventHubConnectionString 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'EVENT-HUB-NAMESPACE-CONNECTION-STRING'
  properties: {
    value: eventHubNamespaceRootManageSharedAccessKey.listKeys().primaryConnectionString
    contentType: 'string'
  }
}

resource keyVaultSecretAppInsightsKey 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'APPLICATION-INSIGHTS-CONNECTION-STRING'
  properties: {
    value: appInsights.properties.ConnectionString
    contentType: 'string'
  }
}

resource keyVaultSecretAppInsightsInstrumentationKey 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'APP-INSIGHTS-INSTRUMENTATION-KEY'
  properties: {
    value: appInsights.properties.InstrumentationKey
    contentType: 'string'
  }
}

resource keyVaultSecretApiURI 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'API-URI'
  properties: {
    value: 'https://${apiServiceName}.azurewebsites.net/todos/'
    contentType: 'string'
  }
}

resource kvDiagnotsicsLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${keyVaultName}-kv-logs'
  scope: keyVault
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
  }
}

resource postgreSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01-preview' = {
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

resource postgreSQLServerDiagnotsicsLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${dbServerName}-db-logs'
  scope: postgreSQLServer
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
  }
}

resource apiServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${apiServiceName}-plan'
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
}

resource apiServicePARMS 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'web'
  parent: apiService
  dependsOn: [
    rbacKVSecretApiSpringDataSourceURL
    rbacKVSecretApiSpringDatasourceUserName
    rbacKVSecretApiSpringDatasourceUserPassword
    rbacKVSecretApiAppInsightsKey
    rbacKVSecretApiAppInsightsInstrKey
  ]
  kind: 'string'
  properties: {
    appSettings: [
      {
        name: 'PORT'
        value: apiServicePort
      }
      {
        name: 'SPRING_DATASOURCE_URL'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-URL)'
        //value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}'
      }
      {
        name: 'SPRING_DATASOURCE_USERNAME'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-USERNAME)'
        //value: dbUserName
      }
      {
        name: 'SPRING_DATASOURCE_PASSWORD'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-PASSWORD)'
        //value: dbUserPassword
      }
      {
        name: 'SPRING_DATASOURCE_SHOW_SQL'
        value: 'false'
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=APPLICATIONINSIGHTS-CONNECTION-STRING)'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=APP-INSIGHTS-INSTRUMENTATION-KEY)'
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'false'
      }
    ]
  }
}

resource apiServiceDiagnotsicsLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${apiServiceName}-app-logs'
  scope: apiService
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
  }
}

resource webServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${webServiceName}-plan'
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
}

resource webServicePARMS 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'web'
  parent: webService
  dependsOn: [
    rbacKVSecretApiWebApiUri
    rbacKVSecretApiWebEventHubConnectionString
    rbacKVSecretApiWebEventHubName
    rbacKVSecretWebAppInsightsKey
    rbacKVSecretWebAppInsightsInstrKey
  ]
  kind: 'string'
  properties: {
    appSettings: [
      {
        name: 'PORT'
        value: webServicePort
      }
      {
        name: 'API_URI'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=API-URI)'
        //'https://${apiServiceName}.azurewebsites.net/todos/'
      }
      {
        name: 'EVENT_HUB_NAMESPACE_CONNECTION_STRING'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-NAMESPACE-CONNECTION-STRING)'
      }
      {
        name: 'EVENT_HUB_NAME'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-CLOUD-STREAM-OUT-DESTINATION)'
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=APPLICATION-INSIGHTS-CONNECTION-STRING)'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=APP-INSIGHTS-INSTRUMENTATION-KEY)'
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'false'
      }
    ]
  }
}

resource webServiceDiagnotsicsLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${webServiceName}-web-logs'
  scope: webService
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        // retentionPolicy: {
        //   days: 90
        //   enabled: true
        // }
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
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
}

resource eventConsumerServicePARMS 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'web'
  parent: eventConsumerService
  dependsOn: [
    rbacKVSecretEventConsumerClientId
    rbacKVSecretEventConsumerClientSecret
    rbacKVSecretEventConsumerHubNamespace
    rbacKVSecretEventConsumerHubRG
    rbacKVSecretEventConsumerHubSubscriptionId
    rbacKVSecretEventConsumerHubTenantId
    rbacKVSecretEventConsumerInDestination
    rbacKVSecretEventConsumerInGroup
    rbacKVSecretEventConsumerInDestination
    rbacKVSecretEventConsumerSpringDSUser
    rbacKVSecretEventConsumerSpringDSPassword
    rbacKVSecretEventConsumerSpringDataSourceURL
    rbacKVSecretEventConsumerAppInsightsKey
    rbacKVSecretEventConsumerAppInsightsInstrKey
  ]
  kind: 'string'
  properties: {
    appSettings: [
      {
        name: 'PORT'
        value: eventConsumerServicePort
      }
      {
        name: 'SPRING_DATASOURCE_URL'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-URL)'
        //value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}'
      }
      {
        name: 'SPRING_DATASOURCE_USERNAME'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-USERNAME)'
        //value: dbUserName
      }
      {
        name: 'SPRING_DATASOURCE_PASSWORD'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-PASSWORD)'
        //value: dbUserPassword
      }
      {
        name: 'EVENT_HUB_CLIENT_ID'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-CLIENT-ID)'
      }
      {
        name: 'EVENT_HUB_CLIENT_SECRET'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-CLIENT-SECRET)'
      }
      {
        name: 'EVENT_HUB_TENANT_ID'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-TENANT-ID)'
      }
      {
        name: 'EVENT_HUB_SUBSCRIPTION_ID'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-SUBSCRIPTION-ID)'
      }
      {
        name: 'EVENT_HUB_NAMESPACE'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-NAMESPACE)'
      }
      {
        name: 'SPRING_CLOUD_STREAM_IN_DESTINATION'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-CLOUD-STREAM-IN-DESTINATION)'
      }
      {
        name: 'SPRING_CLOUD_STREAM_IN_GROUP'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-CLOUD-STREAM-IN-GROUP)'
      }
      {
        name: 'SPRING_CLOUD_STREAM_OUT_DESTINATION'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-CLOUD-STREAM-OUT-DESTINATION)'
      }
      {
        name: 'EVENT_HUB_RESOURCE_GROUP'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-RESOURCE-GROUP)'
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=APPLICATION-INSIGHTS-CONNECTION-STRING)'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=APP-INSIGHTS-INSTRUMENTATION-KEY)'
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'false'
      }
    ]
  }
}

resource eventConsumerServiceDiagnotsicsLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${eventConsumerServiceName}-web-logs'
  scope: eventConsumerService
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        // retentionPolicy: {
        //   days: 90
        //   enabled: true
        // }
      }
    ]
    workspaceId: logAnalyticsWorkspace.id
  }
}

@description('This is the built-in Key Vault Secrets User role. See https://docs.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: keyVault
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

// @description('This is the built-in Key Vault Administrator User role. See https://docs.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
// resource keyVaultAdministrator 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
//   scope: keyVaultSecretAppInsightsKey
//   name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
// }

// module rbacKeyVaultAdmin './components/role-assignment-kv.bicep' = {
//   name: 'deployment-rbac-kv-deployer'
//   params: {
//     roleDefinitionId: keyVaultAdministrator.id
//     principalId: currentClientId
//     roleAssignmentNameGuid: guid(currentClientId, keyVault.id, keyVaultAdministrator.id)
//     kvName: keyVault.name
//   }
// }

//TODO Coming at some point.. - or some variation of
// @description('This is the built-in Admin for PGSQL Flexible Server. Coming at some point to... https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles')
// resource pgsqlFlexibleServerAdmin 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
//   scope: keyVault
//   name: 'TODO'
// }

// to deploy to different scope, we need to utilize modules
// as we're trying to have the least possible assignment scope
// Even though these assignments below work, let's try to avoid
// too broad of an access
// module rbac './components/role-assignment-kv.bicep' = {
//   name: 'deployment-rbac-api'
//   params: {
//     roleDefinitionId: keyVaultSecretsUser.id
//     principalId: apiService.identity.principalId
//     roleAssignmentNameGuid: guid(apiService.id, apiService.id, keyVaultSecretsUser.id)
//     kvName: keyVault.name
//   }
// }

// module rbacWeb './components/role-assignment-kv.bicep' = {
//   name: 'deployment-rbac-web'
//   params: {
//     roleDefinitionId: keyVaultSecretsUser.id
//     principalId: webService.identity.principalId
//     roleAssignmentNameGuid: guid(webService.id, webService.id, keyVaultSecretsUser.id)
//     kvName: keyVault.name
//   }
// }

module rbacKVSecretApiSpringDatasourceUserName './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-spring-datasource-user-name'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, keyVaultSecretSpringDatasourceUserName.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserName.name
  }
}

module rbacKVSecretApiSpringDatasourceUserPassword './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-spring-datasource-user-password'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, keyVaultSecretSpringDatasourceUserPassword.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserPassword.name
  }
}

module rbacKVSecretApiSpringDataSourceURL './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-spring-datasource-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, keyVaultSecretSpringDataSourceURL.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDataSourceURL.name
  }
}

// resource rbacKVSecretApiSpringDataSourceURL 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
//   name: guid(apiService.id, keyVaultSecretSpringDataSourceURL.id, keyVaultSecretsUser.id)
//   scope: keyVaultSecretSpringDataSourceURL
//   properties: {
//     roleDefinitionId: keyVaultSecretsUser.id
//     principalId: apiService.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

module rbacKVSecretApiAppInsightsKey './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-app-insights'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, keyVaultSecretAppInsightsKey.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsKey.name
  }
}

module rbacKVSecretApiAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-app-insights-instr'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, keyVaultSecretAppInsightsInstrumentationKey.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsInstrumentationKey.name
  }
}

module rbacKVSecretWebAppInsightsKey './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-app-insights'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: webService.identity.principalId
    roleAssignmentNameGuid: guid(webService.id, keyVaultSecretAppInsightsKey.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsKey.name
  }
}

module rbacKVSecretWebAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-app-insights-instr'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: webService.identity.principalId
    roleAssignmentNameGuid: guid(webService.id, keyVaultSecretAppInsightsInstrumentationKey.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsInstrumentationKey.name
  }
}

module rbacKVSecretApiWebApiUri './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-api-uri'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: webService.identity.principalId
    roleAssignmentNameGuid: guid(webService.id, keyVaultSecretApiURI.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretApiURI.name
  }
}

// resource rbacKVSecretApiWebApiUri 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
//   name: guid(webService.id, keyVaultSecretApiURI.id, keyVaultSecretsUser.id)
//   scope: keyVaultSecretApiURI
//   properties: {
//     roleDefinitionId: keyVaultSecretsUser.id
//     principalId: webService.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

module rbacKVSecretApiWebEventHubConnectionString './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-event-hub-connection-string'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: webService.identity.principalId
    roleAssignmentNameGuid: guid(webService.id, keyVaultSecretAzureEventHubConnectionString.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubConnectionString.name
  }
}

module rbacKVSecretApiWebEventHubName './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-event-hub-name'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: webService.identity.principalId
    roleAssignmentNameGuid: guid(webService.id, keyVaultSecretSpringCloudStreamOutDestination.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringCloudStreamOutDestination.name
  }
}


module rbacKVSecretEventConsumerClientId './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-client-id'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretAzureEventHubClientId.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubClientId.name
  }
}

module rbacKVSecretEventConsumerClientSecret './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-client-secret'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretAzureEventHubClientSecret.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubClientSecret.name
  }
}

module rbacKVSecretEventConsumerHubNamespace './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-namespace'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretAzureEventHubNamespace.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubNamespace.name
  }
}

module rbacKVSecretEventConsumerHubRG './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-rg'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretAzureEventHubRG.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubRG.name
  }
}

module rbacKVSecretEventConsumerHubSubscriptionId './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-subscription-id'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretAzureEventHubSubscriptionId.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubSubscriptionId.name
  }
}

module rbacKVSecretEventConsumerHubTenantId './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-tenant-id'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretAzureEventHubTenantId.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubTenantId.name
  }
}

module rbacKVSecretEventConsumerInDestination './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-in-destination'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretSpringCloudStreamInDestination.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringCloudStreamInDestination.name
  }
}

module rbacKVSecretEventConsumerInGroup './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-in-group'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretSpringCloudStreamInGroup.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringCloudStreamInGroup.name
  }
}

module rbacKVSecretEventConsumerOutDestination './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-out-destination'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretSpringCloudStreamOutDestination.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringCloudStreamOutDestination.name
  }
}

module rbacKVSecretEventConsumerSpringDSUser './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-spring-ds-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretSpringDatasourceUserName.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserName.name
  }
}

module rbacKVSecretEventConsumerSpringDSPassword './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-spring-ds-password'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretSpringDatasourceUserPassword.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserPassword.name
  }
}

module rbacKVSecretEventConsumerSpringDataSourceURL './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-spring-datasource-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretSpringDataSourceURL.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDataSourceURL.name
  }
}

module rbacKVSecretEventConsumerAppInsightsKey './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-app-insights'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretAppInsightsKey.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsKey.name
  }
}

module rbacKVSecretEventConsumerAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-app-insights-instr'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: eventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(eventConsumerService.id, keyVaultSecretAppInsightsInstrumentationKey.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsInstrumentationKey.name
  }
}

// TODO coming at some point..
// module rbacPGSQL './components/role-assignment-pgsql.bicep' = {
//   name: 'deployment-rbac-pgsql'
//   params: {
//     roleDefinitionId: pgsqlFlexibleServerAdmin.id
//     principalId:  apiService.identity.principalId
//     roleAssignmentNameGuid: guid(postgreSQLServer.id, postgreSQLServer.id, pgsqlFlexibleServerAdmin.id)
//     postgreSQLServerName: postgreSQLServer.name
//   }
// }
