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

param apiServiceName string

param location string = resourceGroup().location

param tagsArray object = {
  workload: 'DEVTEST'
  costCentre: 'FIN'
  department: 'RESEARCH'
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: kvName
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
  // resource test 'secrets@2021-11-01-preview' = {
  //   name: 'whatever'
  //   properties: {
  //     value: 'huhu'
  //     contentType: 'string'
  //   }
  // }
  resource databaseAdminName 'secrets@2021-11-01-preview' = {
    name: 'DB_ADMIN_NAME'
    properties: {
      value: 'dbAdminName'
      contentType: 'string'
    }
  }
  // resource databaseAdminPassword 'secrets@2021-11-01-preview' = {
  //   name: 'DB_ADMIN_PASSWORD'
  //   properties: {
  //     value: dbAdminPassword
  //     contentType: 'string'
  //   }
  // }
  // resource databaseReaderUserName 'secrets@2021-11-01-preview' = {
  //   name: 'SPRING_DATASOURCE_USERNAME'
  //   properties: {
  //     value: dbUserName
  //     contentType: 'string'
  //   }
  // }
  // resource databaseReaderUserPassword 'secrets@2021-11-01-preview' = {
  //   name: 'SPRING_DATASOURCE_PASSWORD'
  //   properties: {
  //     value: dbUserPassword
  //     contentType: 'string'
  //   }
  // }
  // resource springDataSourceURL 'secrets@2021-11-01-preview' = {
  //   name: 'SPRING_DATASOURCE_URL'
  //   properties: {
  //     value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}'
  //     contentType: 'string'
  //   }
  // }
  // resource apiURI 'secrets@2021-11-01-preview' = {
  //   name: 'API_URI'
  //   properties: {
  //     value: 'https://${apiServiceName}.azurewebsites.net/todos/'
  //     contentType: 'string'
  //   }
  // }
}
