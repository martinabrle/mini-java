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
   resource databaseAdminName 'secrets' = {
    name: 'DB_ADMIN_NAME'
    properties: {
      value: dbAdminName
      contentType: 'string'
    }  
  }

  // resource databaseAdminPassword 'secrets' = {
  //     name: 'DB_ADMIN_PASSWORD'
  //     properties: {
  //       value: dbAdminPassword
  //   }
  // }
  // resource databaseReaderUserName 'secrets' = {
  //   name: 'SPRING_DATASOURCE_USERNAME'
  //   properties: {
  //     value: dbUserName
  //   }
  // }
  // resource databaseReaderUserPassword 'secrets' = {
  //   name: 'SPRING_DATASOURCE_PASSWORD'
  //   properties: {
  //     value: dbUserPassword
  //   }
  // }
  // resource springDataSourceURL 'secrets' = {
  //   name: 'SPRING_DATASOURCE_URL'
  //   properties: {
  //     value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}'
  //   }
  // }
  // resource apiURI 'secrets' = {
  //   name: 'API_URI'
  //   properties: {
  //     value: 'https://${apiServiceName}.azurewebsites.net/todos/'
  //   }
  // }
}
