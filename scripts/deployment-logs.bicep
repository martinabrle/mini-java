param logAnalyticsWorkspaceName string
param location string = resourceGroup().location

param tagsArray object = {
  workload: 'DEVTEST'
  costCentre: 'FIN'
  department: 'RESEARCH'
}

// resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
//   name: logAnalyticsWorkspaceName
//   location: location
//   tags: tagsArray
//   properties: {
//     defaultDataCollectionRuleResourceId: 'string'
//     features: {
//       clusterResourceId: 'string'
//       disableLocalAuth: false
//       enableDataExport: false
//       enableLogAccessUsingOnlyResourcePermissions: true
//       immediatePurgeDataOn30Days: true
//     }
//     forceCmkForQuery: false
//     publicNetworkAccessForIngestion: 'Enabled'
//     publicNetworkAccessForQuery: 'Enabled'
//     retentionInDays: 30
//     sku: {
//       name: 'PerGB2018'
//     }
//     workspaceCapping: {
//       dailyQuotaGb: 2
//     }
//   }
// }

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tagsArray
  properties: {
    features: {
      immediatePurgeDataOn30Days: true
    }
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: 2
    }
  }
}
