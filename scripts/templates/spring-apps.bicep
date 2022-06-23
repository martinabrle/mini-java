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
param eventHubSubscriptionId string = substring(subscription().id, lastIndexOf(subscription().id, '/')) //event hub may be in another subscription (requires script modification)
param eventHubRG string = resourceGroup().name //event hub may be in another resource group (requires script modification)
param eventHubNamespaceName string
param springCloudStreamInDestination string
param springCloudStreamInGroup string
param springCloudStreamOutDestination string

param clientIPAddress string

param springAppName string
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
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'java'
  tags: tagsArray
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
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
  name: 'APPLICATIONINSIGHTS-CONNECTION-STRING'
  properties: {
    value: appInsights.properties.ConnectionString
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

resource postgreSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-01-20-preview' = {
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

resource postgreSQLDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-01-20-preview' = {
  name: dbName
  parent: postgreSQLServer
  properties: {
    charset: 'utf8'
    collation: 'en_US.utf8'
  }
}

resource allowClientIPFirewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-01-20-preview' = {
  name: 'allowClientIP'
  parent: postgreSQLServer
  properties: {
    endIpAddress: clientIPAddress
    startIpAddress: clientIPAddress
  }
}

resource allowAllIPsFirewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-01-20-preview' = {
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

resource springApps 'Microsoft.AppPlatform/Spring@2022-05-01-preview' = {
  name: springAppName
  location: location
  tags: tagsArray
  sku: {
    capacity: 1
    name: 'S0'
    tier: 'Standard'
  }
  properties: {
    zoneRedundant: false
  }
}

resource springAppsDiagnosticsLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${apiServiceName}-logs'
  scope: springApps
  properties: {
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
      }
      {
        category: 'SystemLogs'
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

resource springAppsApiService 'Microsoft.AppPlatform/Spring/apps@2022-05-01-preview' = {
  name: apiServiceName
  location: location
  parent: springApps
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableEndToEndTLS: true
    httpsOnly: true
    public: true
  }
}

resource springAppsApiServiceDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2022-05-01-preview' = {
  name: '${apiServiceName}-deployment'
  parent: springAppsApiService
  dependsOn: [
    rbacKVSecretApiSpringDataSourceURL
    rbacKVSecretApiSpringDatasourceUserName
    rbacKVSecretApiSpringDatasourceUserPassword
    rbacKVSecretApiAppInsightsKey
  ]
  sku: {
    name: 'S0'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '1Gi'
      }
      environmentVariables: {
        'PORT': apiServicePort
        'SPRING_DATASOURCE_URL': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-URL)'
        'SPRING_DATASOURCE_USERNAME': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-USERNAME)'
        'SPRING_DATASOURCE_PASSWORD': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-PASSWORD)'
        'APPLICATIONINSIGHTS_CONNECTION_STRING': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=APPLICATIONINSIGHTS-CONNECTION-STRING)'
        'SPRING_DATASOURCE_SHOW_SQL': 'false'
        'SCM_DO_BUILD_DURING_DEPLOYMENT': 'false'
      }
    }
    active: true
  }
}

resource springAppsWebService 'Microsoft.AppPlatform/Spring/apps@2022-05-01-preview' = {
  name: webServiceName
  location: location
  parent: springApps
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableEndToEndTLS: true
    httpsOnly: true
    public: true
  }
}

resource springAppsWebServiceDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2022-05-01-preview' = {
  name: '${webServiceName}-deployment'
  parent: springAppsWebService
  dependsOn: [
    rbacKVSecretWebApiUri
    rbacKVSecretWebEventHubConnectionString
    rbacKVSecretWebAppInsightsKey
  ]
  sku: {
    name: 'S0'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '1Gi'
      }
      environmentVariables: {
        'PORT': webServicePort
        'API_URI': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=API-URI)'
        'EVENT_HUB_NAMESPACE_CONNECTION_STRING': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-NAMESPACE-CONNECTION-STRING)'
        'APPLICATIONINSIGHTS_CONNECTION_STRING': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=APPLICATIONINSIGHTS-CONNECTION-STRING)'
        'SCM_DO_BUILD_DURING_DEPLOYMENT': 'false'
      }
    }
    active: true
  }
}

resource springAppsEventConsumerService 'Microsoft.AppPlatform/Spring/apps@2022-05-01-preview' = {
  name: eventConsumerServiceName
  location: location
  parent: springApps
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableEndToEndTLS: true
    httpsOnly: true
    public: true
  }
}

resource eventConsumerServiceDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2022-05-01-preview' = {
  name: '${eventConsumerServiceName}-deployment'
  parent: springAppsEventConsumerService
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
  ]
  sku: {
    name: 'S0'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '1Gi'
      }
      environmentVariables: {
        'PORT': eventConsumerServicePort
        'SPRING_DATASOURCE_URL': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-URL)'
        'SPRING_DATASOURCE_USERNAME': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-USERNAME)'
        'SPRING_DATASOURCE_PASSWORD': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-DATASOURCE-PASSWORD)'
        'EVENT_HUB_CLIENT_ID': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-CLIENT-ID)'
        'EVENT_HUB_CLIENT_SECRET': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-CLIENT-SECRET)'
        'EVENT_HUB_TENANT_ID': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-TENANT-ID)'
        'EVENT_HUB_SUBSCRIPTION_ID': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-SUBSCRIPTION-ID)'
        'EVENT_HUB_NAMESPACE': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-NAMESPACE)'
        'SPRING_CLOUD_STREAM_IN_DESTINATION': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-CLOUD-STREAM-IN-DESTINATION)'
        'SPRING_CLOUD_STREAM_IN_GROUP': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-CLOUD-STREAM-IN-GROUP)'
        'SPRING_CLOUD_STREAM_OUT_DESTINATION': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=SPRING-CLOUD-STREAM-OUT-DESTINATION)'
        'EVENT_HUB_RESOURCE_GROUP': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EVENT-HUB-RESOURCE-GROUP)'
        'APPLICATIONINSIGHTS_CONNECTION_STRING': '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=APPLICATIONINSIGHTS-CONNECTION-STRING)'
        'SCM_DO_BUILD_DURING_DEPLOYMENT': 'false'
      }
    }
  }
}

@description('This is the built-in Key Vault Secrets User role. See https://docs.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: keyVault
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

module rbacKVSecretApiSpringDatasourceUserName './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-spring-datasource-user-name'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsApiService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsApiService.id, keyVaultSecretSpringDatasourceUserName.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserName.name
  }
}

module rbacKVSecretApiSpringDatasourceUserPassword './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-spring-datasource-user-password'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsApiService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsApiService.id, keyVaultSecretSpringDatasourceUserPassword.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserPassword.name
  }
}

module rbacKVSecretApiSpringDataSourceURL './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-spring-datasource-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsApiService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsApiService.id, keyVaultSecretSpringDataSourceURL.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDataSourceURL.name
  }
}

module rbacKVSecretApiAppInsightsKey './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-app-insights'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsApiService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsApiService.id, keyVaultSecretAppInsightsKey.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsKey.name
  }
}

module rbacKVSecretWebAppInsightsKey './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-app-insights'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsWebService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsWebService.id, keyVaultSecretAppInsightsKey.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsKey.name
  }
}

module rbacKVSecretWebApiUri './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-api-uri'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsWebService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsWebService.id, keyVaultSecretApiURI.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretApiURI.name
  }
}

module rbacKVSecretWebEventHubConnectionString './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-event-hub-connection-string'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsWebService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsWebService.id, keyVaultSecretAzureEventHubConnectionString.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubConnectionString.name
  }
}

module rbacKVSecretEventConsumerClientId './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-client-id'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretAzureEventHubClientId.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubClientId.name
  }
}

module rbacKVSecretEventConsumerClientSecret './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-client-secret'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretAzureEventHubClientSecret.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubClientSecret.name
  }
}

module rbacKVSecretEventConsumerHubNamespace './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-namespace'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretAzureEventHubNamespace.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubNamespace.name
  }
}

module rbacKVSecretEventConsumerHubRG './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-rg'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretAzureEventHubRG.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubRG.name
  }
}

module rbacKVSecretEventConsumerHubSubscriptionId './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-subscription-id'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretAzureEventHubSubscriptionId.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubSubscriptionId.name
  }
}

module rbacKVSecretEventConsumerHubTenantId './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-hub-tenant-id'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretAzureEventHubTenantId.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAzureEventHubTenantId.name
  }
}

module rbacKVSecretEventConsumerInDestination './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-in-destination'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretSpringCloudStreamInDestination.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringCloudStreamInDestination.name
  }
}

module rbacKVSecretEventConsumerInGroup './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-in-group'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretSpringCloudStreamInGroup.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringCloudStreamInGroup.name
  }
}

module rbacKVSecretEventConsumerOutDestination './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-out-destination'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretSpringCloudStreamOutDestination.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringCloudStreamOutDestination.name
  }
}

module rbacKVSecretEventConsumerSpringDSUser './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-spring-ds-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretSpringDatasourceUserName.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserName.name
  }
}

module rbacKVSecretEventConsumerSpringDSPassword './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-spring-ds-password'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretSpringDatasourceUserPassword.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserPassword.name
  }
}

module rbacKVSecretEventConsumerSpringDataSourceURL './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-spring-datasource-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretSpringDataSourceURL.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDataSourceURL.name
  }
}

module rbacKVSecretEventConsumerAppInsightsKey './components/role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-event-consumer-app-insights'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: springAppsEventConsumerService.identity.principalId
    roleAssignmentNameGuid: guid(springAppsEventConsumerService.id, keyVaultSecretAppInsightsKey.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsKey.name
  }
}
