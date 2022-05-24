param dbServerDomain string
param dbServerName string
param dbServerPort string
param dbName string

@secure()
param dbServerLogin string
@secure()
param dbServerPassword string

param apiServiceName string
param apiServicePort string

param webServiceName string
param webServicePort string

param location string = resourceGroup().location

resource postgreSQLServer 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  name: dbServerName
  location: location
  tags: {
    workload: 'test'
    costCentre: 'development'
  }
  sku: {
    capacity: 1
    family: 'Gen5'
    name: 'B_Gen5_1'
    size: 'string'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    infrastructureEncryption: 'Disabled'
    minimalTlsVersion: 'TLSEnforcementDisabled'
    publicNetworkAccess: 'Enabled'
    sslEnforcement: 'Disabled'
    storageProfile: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
      storageAutogrow: 'Disabled'
      storageMB: 5120
    }
    version: '11'
    createMode: 'Default' //PointInTimeRestore, Replica, GeoRestore
    administratorLogin: dbServerLogin
    administratorLoginPassword: dbServerPassword
  }
}

resource postgreSQLServer_AllowAllWindowsAzureIps 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = {
  parent: postgreSQLServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource postgreSQLServer_ClientIPAddress 'Microsoft.DBforPostgreSQL/servers/firewallRules@2017-12-01' = {
  parent: postgreSQLServer
  name: 'CurrentClientIPAddress_CICD'
  properties: {
    startIpAddress: '2.30.99.244'
    endIpAddress: '2.30.99.244'
  }
}

resource apiServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${apiServiceName}-plan'
  location: location
  dependsOn: [
    postgreSQLServer
  ]
  properties: {
    reserved: true
  }
  sku: {
    name:'B1'
  }
  kind: 'linux'
}

resource apiService 'Microsoft.Web/sites@2021-02-01' = {
  name: apiServiceName
  location: location
  properties: {
    serverFarmId: apiServicePlan.id
    siteConfig: {
      linuxFxVersion: 'node|16-lts'
      scmType: 'None' 
    }
  }
  resource apiServicePARMS 'config@2021-02-01' = {
    name: 'web'
    kind: 'string'
    properties: {
      appSettings: [
        {
          name: 'PORT'
          value: apiServicePort
        }
        {
          name: 'DB_SERVER'
          value: '${dbServerName}.${dbServerDomain}'
        }
        {
          name: 'DB_SERVER_PORT'
          value: dbServerPort
        }
        {
          name: 'DB_NAME'
          value: dbName
        }
        {
          name: 'DB_LOGIN'
          value: dbServerLogin
        }
        {
          name: 'DB_PASSWORD'
          value: dbServerPassword
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
  }
}

resource webServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${webServiceName}-plan'
  location: location
  dependsOn: [
    apiService
  ]
  properties: {
    reserved: true
  }
  sku: {
    name: 'B1'
  }
  kind: 'linux'
}

resource webService 'Microsoft.Web/sites@2021-02-01' = {
  name: webServiceName
  location: location
  properties: {
    serverFarmId: webServicePlan.id
    siteConfig: {
      linuxFxVersion: 'node|16-lts'
      scmType: 'None' 
    }
  }
  resource webServicePARMS 'config@2021-02-01' = {
    name: 'web'
    kind: 'string'
    properties: {
      appSettings: [
        {
          name: 'PORT'
          value: webServicePort
        }
        {
          name: 'API_SERVER'
          value: apiService.name
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
  }
}
