param kvName string
param kvRG string

param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceRG string
param appInsightsName string



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
    name:'S1'
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
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
  }
}

// deploy to different scope
module rbac './deployment-rbac.bicep' = {
  name: 'deployment-rbac'
  scope: resourceGroup(kvRG)
  params: {
    mainDeploymentRG: resourceGroup().name
    kvName: kvName
    kvRG: kvRG
    apiServiceName: apiServiceName
  }
}


// resource keyVaultAppServiceReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(apiService.id, apiService.id, keyVaultSecretsUser.id)
//   properties: {
//     roleDefinitionId: keyVaultSecretsUser.id
//     principalId: apiService.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }


// @description('Create a brand new User Assigned Managed Identity')
// resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
//   name: containersRGMI
//   location: location
// }



// resource keyVaultAppServiceReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(apiService.id, apiService.id, keyVaultSecretsUser.id)
//   scope: keyVault
//   properties: {
//     roleDefinitionId: keyVaultSecretsUser.id
//     principalId: apiService.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

// @description('This is the built-in Key Vault Secrets User role. See https://docs.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
// resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
//   scope:  subscription()
//   name: '4633458b-17de-408a-b874-0445c86b69e6'
// }


// @description('This is the built-in Key Vault Administrator role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-administrator')
// resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
//   scope:  subscription()
//   name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
// }


// @description('This is the built-in Owner role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-administrator')
// resource OwnerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
//   scope:  subscription()
//   name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
// }
// resource keyVaultAppServiceReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   dependsOn: apiService
//   name: guid(apiService.identity, apiService.identity, keyVaultSecretsUser.id)
//   properties: {
//     roleDefinitionId: keyVaultAdministratorRoleDefinition.id
//     principalId: apiService.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

// resource OwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(containersRGMI, containersRGMI, OwnerRoleDefinition.id)
//   properties: {
//     roleDefinitionId: OwnerRoleDefinition.id
//     principalId: managedIdentity.properties.principalId
//     principalType: 'ServicePrincipal'
//   }
// }
