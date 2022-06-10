param kvName string
param kvRG string

param apiServiceName string
param mainDeploymentRG string


resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: kvName
  scope: resourceGroup(kvRG)
}

resource apiService 'Microsoft.Web/sites@2021-03-01' existing = {
  name: apiServiceName
  scope: resourceGroup(mainDeploymentRG)
}

@description('This is the built-in Key Vault Secrets User role. See https://docs.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope:  subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}


resource keyVaultAppServiceReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(apiService.id, apiService.id, keyVaultSecretsUser.id)
  properties: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: apiService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
