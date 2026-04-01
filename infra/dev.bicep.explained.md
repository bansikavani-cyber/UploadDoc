# dev.bicep Explained (Line by Line)

This document explains each part of your `dev.bicep` file with beginner-friendly examples and comments. It is designed to help you understand Bicep and Azure resource deployment, even if you are new to Infrastructure as Code.

---

## 1. Parameters

```
param location string = resourceGroup().location
```
- **What it does:** Defines a parameter called `location` (type: string) that defaults to the location of the resource group where you deploy this template.
- **Example:** If your resource group is in `eastus`, this will be `eastus`.

```
param storageAccountName string = 'devuploadstorage${uniqueString(resourceGroup().id)}'
```
- **What it does:** Sets a unique name for your storage account by combining `devuploadstorage` with a unique string based on your resource group ID.
- **Example:** `devuploadstorage9f8d2a` (the suffix will be different for each resource group).

```
param appServicePlanName string = 'dev-appserviceplan'
param webAppName string = 'dev-uploadapp'
param sqlServerName string = 'dev-sqlserver${uniqueString(resourceGroup().id)}'
param sqlDbName string = 'dev-uploaddb'
```
- **What they do:** Set names for your App Service Plan, Web App, SQL Server (with unique suffix), and SQL Database.

```
param sqlAdmin string = 'devadmin'
@secure()
param sqlPassword string
```
- **What they do:** Set the SQL admin username and a secure password (which you provide at deployment time).

---

## 2. Storage Account

```
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
```
- **What it does:** Creates an Azure Storage Account for storing files/blobs.
- **Key settings:**
  - `Standard_LRS`: Standard performance, locally-redundant storage (cheapest option).
  - `StorageV2`: General-purpose storage.
  - `accessTier: 'Hot'`: Optimized for frequent access.

---

## 3. App Service Plan (Free Tier)

```
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}
```
- **What it does:** Creates a hosting plan for your web app, using the free tier to avoid charges.

---

## 4. Web App

```
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'BlobStorageConnectionString'
          value: storageAccount.listKeys().keys[0].value
        }
        {
          name: 'SqlConnectionString'
          value: 'Server=tcp:${sqlServerName}.${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDbName};User ID=${sqlAdmin};Password=${sqlPassword};Encrypt=true;Connection Timeout=30;'
        }
      ]
    }
  }
  dependsOn: [sqlDb]
}
```
- **What it does:** Creates your backend web app (API) and connects it to the App Service Plan.
- **App settings:**
  - `AzureWebJobsStorage`: URL for blob storage.
  - `BlobStorageConnectionString`: Connection string for blob operations.
  - `SqlConnectionString`: Connection string for the SQL database (uses parameters for security and flexibility).
- **dependsOn:** Ensures the SQL database is created before the web app.

---

## 5. SQL Server

```
resource sqlServer 'Microsoft.Sql/servers@2022-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdmin
    administratorLoginPassword: sqlPassword
    version: '12.0'
  }
}
```
- **What it does:** Creates a logical SQL Server in Azure for your database.
- **Key settings:**
  - `administratorLogin` and `administratorLoginPassword`: Credentials for the server.
  - `version: '12.0'`: SQL Server version.

---

## 6. SQL Database (Free Tier)

```
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
```
- **What it does:** Creates a database inside your SQL Server.
- **Key settings:**
  - `collation`: How text is sorted/stored.
  - `maxSizeBytes`: 250MB (free tier limit).
  - `sampleName`: Loads a sample database for testing.
  - `sku`: Uses the free tier to avoid charges.

---

## Summary Table

| Resource           | Name Example                  | Purpose                        |
|--------------------|------------------------------|--------------------------------|
| Storage Account    | devuploadstorage9f8d2a       | Store files/blobs              |
| App Service Plan   | dev-appserviceplan           | Host web app (free tier)       |
| Web App            | dev-uploadapp                | Backend API                    |
| SQL Server         | dev-sqlserver9f8d2a          | Host SQL databases             |
| SQL Database       | dev-uploaddb                 | Store app data (free tier)     |

---

## How to Deploy

1. Make sure you have the Azure CLI and Bicep CLI installed.
2. Log in: `az login`
3. Set your subscription: `az account set --subscription <your-subscription-id>`
4. Deploy: 
   ```
   az deployment group create --resource-group <your-resource-group> --template-file infra/dev.bicep --parameters sqlPassword=<your-password>
   ```

---

## Tips
- You can reuse this template for QA and Prod by changing the parameter values.
- All names are unique per environment to avoid conflicts.
- Free tiers help you avoid charges while learning and testing.

---

If you have any line you want explained in even more detail, just ask!
