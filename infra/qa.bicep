@secure()
param sqlPassword string

param location string = 'eastus'

// App Service Plan (LOW COST - B1)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'qa-plan'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'qa-webapp-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2022-11-01' = {
  name: 'qa-sql-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    administratorLogin: 'sqladminuser'
    administratorLoginPassword: sqlPassword
  }
}

// SQL Database (cheap tier)
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-11-01' = {
  name: '${sqlServer.name}/qadb'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}
