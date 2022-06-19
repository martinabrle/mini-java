param eventHubNamespaceName string
param eventHubName string

param location string = resourceGroup().location

param tagsArray object = {
  workload: 'DEVTEST'
  costCentre: 'FIN'
  department: 'RESEARCH'
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

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  name: eventHubName
  parent:eventHubNamespace
  properties: {
    messageRetentionInDays: 2
    partitionCount: 2
  }
}
