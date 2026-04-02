// kt: Bicep template for QA environment
// kt: Provisions Storage Account, App Service, and Azure SQL Database for QA
param location string = resourceGroup().location
// Shortened prefix to keep storage account name <=24 chars
param storageAccountName string = 'qastg${uniqueString(resourceGroup().id)}'
param appServicePlanName string = 'qa-appserviceplan'
param webAppName string = 'qa-uploadapp'
param sqlServerName string = 'qa-sqlserver${uniqueString(resourceGroup().id)}'
param sqlDbName string = 'qa-uploaddb'

param sqlAdmin string = 'qaadmin'
@secure()
param sqlPassword string

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// App Service Plan
// kt: Use Free tier for App Service Plan to avoid charges
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

// Function App (consumption)
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
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
// kt: SQL Server resource
resource sqlServer 'Microsoft.Sql/servers@2022-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdmin
    administratorLoginPassword: sqlPassword
    version: '12.0'
  }
}

// SQL Database
// kt: SQL Database resource
// kt: Use free tier for SQL Database (250MB, limited features)
resource sqlDb 'Microsoft.Sql/servers/databases@2022-11-01' = {
  parent: sqlServer
  name: sqlDbName
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 262144000 // 250MB
    sampleName: 'AdventureWorksLT'
  }
  sku: {
    name: 'Free'
    tier: 'GeneralPurpose'
  }
}
