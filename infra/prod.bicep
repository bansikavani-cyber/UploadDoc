@secure()
param sqlPassword string

param location string = 'australiaeast'

// App Service Plan (LOW COST - B1)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'prod-plan'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'prod-webapp-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-08-01' = {
  name: 'prod-sql-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    administratorLogin: 'sqladminuser'
    administratorLoginPassword: sqlPassword
  }
}

// SQL Database (cheap tier)
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: sqlServer
  name: 'proddb'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}
