param cosmosDBAccountName string = 'toyrnd-${uniqueString(resourceGroup().id)}'
param cosmosDBDatabaseThroughput int = 400
param location string = resourceGroup().location

var cosmosDBDatabaseName = 'FlightTests'
var cosmosDBContainerName = 'FlightTestsContainer'
var cosmosDBContainerNameId = 'FlightTestsContainerId'
var cosmosDBContainerPartitionKey = '/droneId'

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
  name: cosmosDBAccountName
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-04-01' = {
  dependsOn: [
    cosmosDBAccount
  ]
  name: '${cosmosDBAccount.name}/${cosmosDBDatabaseName}'
  properties: {
    resource: {
      id: cosmosDBDatabaseName
    }
    options: {
      throughput: cosmosDBDatabaseThroughput
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  dependsOn: [
    cosmosDBDatabase
  ]
  name: '${cosmosDBDatabase.name}/${cosmosDBContainerName}'
  properties: {
    resource: {
      id: cosmosDBContainerName
      partitionKey: {
        kind: 'Hash'
        paths: [
          cosmosDBContainerPartitionKey
        ]
      }
    }
    options: {}
  }
}
