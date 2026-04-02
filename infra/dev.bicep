// Dev environment: App Service (F1) + Azure SQL (Basic)
param location string = resourceGroup().location
param appServicePlanName string = 'dev-appserviceplan'
param webAppName string = 'dev-uploadapp'
param sqlServerName string = 'dev-sql${uniqueString(resourceGroup().id)}'
param sqlDbName string = 'dev-uploaddb'

param sqlAdmin string = 'devadmin'
@secure()
param sqlPassword string

// App Service Plan (Free tier)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'SqlConnectionString'
          value: 'Server=tcp:${sqlServerName}.${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDbName};User ID=${sqlAdmin};Password=${sqlPassword};Encrypt=true;Connection Timeout=30;'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
  dependsOn: [sqlDb]
}

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2022-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdmin
    administratorLoginPassword: sqlPassword
    version: '12.0'
  }
}

// SQL Database (Basic)
resource sqlDb 'Microsoft.Sql/servers/databases@2022-11-01' = {
  parent: sqlServer
  name: sqlDbName
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2 GB for Basic
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
    size: '2GB'
  }
}
