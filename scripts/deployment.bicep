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

resource postgreSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: dbServerName
  location: location
  tags: {
    workload: 'DEVTEST'
    costCentre: 'FIN'
    department: 'RESEARCH'
  }
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
    name:'S1'
  }
  kind: 'linux'
}

resource apiService 'Microsoft.Web/sites@2021-02-01' = {
  name: apiServiceName
  location: location
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
          name: 'SPRING_DATASOURCE_URL'
          value: 'jdbc:postgresql://${dbServerName}.postgres.database.azure.com:5432/${dbName}?sslmode=verify-full&sslrootcert=`./DigiCertGlobalRootCA.crt.pem`'
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
    name: 'S1'
  }
  kind: 'linux'
}

resource webService 'Microsoft.Web/sites@2021-02-01' = {
  name: webServiceName
  location: location
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
          value: apiServiceName
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
  }
}
