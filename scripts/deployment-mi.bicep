param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceRG string
param appInsightsName string

param kvName string
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

param clientIPAddress string
param apiServiceName string
param apiServicePort string

param webServiceName string
param webServicePort string

param location string = resourceGroup().location

param tagsArray object = {
  workload: 'DEVTEST'
  costCentre: 'FIN'
  department: 'RESEARCH'
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceRG)
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
  name: kvName
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
  resource databaseAdminName 'secrets@2021-11-01-preview' = {
    name: 'DB-ADMIN-NAME'
    properties: {
      value: dbAdminName
      contentType: 'string'
    }
  }
  resource databaseAdminPassword 'secrets@2021-11-01-preview' = {
    name: 'DB-ADMIN-PASSWORD'
    properties: {
      value: dbAdminPassword
      contentType: 'string'
    }
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

resource  keyVaultSecretSpringDataSourceURL 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'SPRING-DATASOURCE-URL'
  properties: {
    value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}'
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
  name: '${kvName}-kv-logs'
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
  dependsOn: [
    postgreSQLServer
  ]
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
  dependsOn: [
    postgreSQLServer
    keyVault
  ]
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
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=SPRING-DATASOURCE-URL)'
          //value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}'
        }
        {
          name: 'SPRING_DATASOURCE_USERNAME'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=SPRING-DATASOURCE-USERNAME)'
          //value: dbUserName
        }
        {
          name: 'SPRING_DATASOURCE_PASSWORD'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=SPRING-DATASOURCE-PASSWORD)'
          //value: dbUserPassword
        }
        {
          name: 'SPRING_DATASOURCE_SHOW_SQL'
          value: 'false'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=APPLICATIONINSIGHTS-CONNECTION-STRING)'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
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
  dependsOn: [
    apiService
    keyVault
  ]
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
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=API-URI)'
          //'https://${apiServiceName}.azurewebsites.net/todos/'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=APPLICATIONINSIGHTS-CONNECTION-STRING)'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
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

@description('This is the built-in Key Vault Secrets User role. See https://docs.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: keyVault
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

@description('This is the built-in Key Vault Administrator User role. See https://docs.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultAdministrator 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: keyVaultSecretAppInsightsKey
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
}

//TODO Coming at some point.. - or some variation of
// @description('This is the built-in Admin for PGSQL Flexible Server. Coming at some point to... https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles')
// resource pgsqlFlexibleServerAdmin 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
//   scope: keyVault
//   name: 'TODO'
// }

// to deploy to different scope, we need to utilize modules
// as we're trying to have the least possible assignment scope
module rbac './deployment-mi-role-assignment-kv.bicep' = {
  name: 'deployment-rbac-api'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, apiService.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
  }
}

module rbacWeb './deployment-mi-role-assignment-kv.bicep' = {
  name: 'deployment-rbac-web'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: webService.identity.principalId
    roleAssignmentNameGuid: guid(webService.id, webService.id, keyVaultSecretsUser.id)
    kvName: keyVault.name
  }
}

module rbacKVSecretApiSpringDatasourceUserName './deployment-mi-role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-spring-datasource-user-name'
  params: {
    roleDefinitionId: keyVaultAdministrator.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, keyVaultSecretSpringDatasourceUserName.id, keyVaultAdministrator.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserName.name
  }
}

module rbacKVSecretApiSpringDatasourceUserPassword './deployment-mi-role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-spring-datasource-user-password'
  params: {
    roleDefinitionId: keyVaultAdministrator.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, keyVaultSecretSpringDatasourceUserPassword.id, keyVaultAdministrator.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDatasourceUserPassword.name
  }
}

module rbacKVSecretApiSpringDataSourceURL './deployment-mi-role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-spring-datasource-url'
  params: {
    roleDefinitionId: keyVaultAdministrator.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, keyVaultSecretSpringDataSourceURL.id, keyVaultAdministrator.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretSpringDataSourceURL.name
  }
}

module rbacKVSecretApiAppInsightsKey './deployment-mi-role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-api-app-insights'
  params: {
    roleDefinitionId: keyVaultAdministrator.id
    principalId: apiService.identity.principalId
    roleAssignmentNameGuid: guid(apiService.id, keyVaultSecretAppInsightsKey.id, keyVaultAdministrator.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsKey.name
  }
}

module rbacKVSecretWebAppInsightsKey './deployment-mi-role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-app-insights'
  params: {
    roleDefinitionId: keyVaultAdministrator.id
    principalId: webService.identity.principalId
    roleAssignmentNameGuid: guid(webService.id, keyVaultSecretAppInsightsKey.id, keyVaultAdministrator.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretAppInsightsKey.name
  }
}

module rbacKVSecretApiWebApiUri './deployment-mi-role-assignment-kv-secret.bicep' = {
  name: 'deployment-rbac-kv-secret-web-api-uri'
  params: {
    roleDefinitionId: keyVaultAdministrator.id
    principalId: webService.identity.principalId
    roleAssignmentNameGuid: guid(webService.id, keyVaultSecretApiURI.id, keyVaultAdministrator.id)
    kvName: keyVault.name
    kvSecretName: keyVaultSecretApiURI.name
  }
}


// TODO coming at some point..
// module rbacPGSQL './deployment-mi-role-assignment-kv.bicep' = {
//   name: 'deployment-rbac-pgsql'
//   params: {
//     roleDefinitionId: pgsqlFlexibleServerAdmin.id
//     principalId:  apiService.identity.principalId
//     roleAssignmentNameGuid: guid(postgreSQLServer.id, postgreSQLServer.id, pgsqlFlexibleServerAdmin.id)
//     postgreSQLServerName: postgreSQLServer.name
//   }
// }
