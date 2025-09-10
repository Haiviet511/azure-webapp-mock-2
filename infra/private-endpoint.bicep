param sqlServerName string
param sqlResourceId string
param vnetName string
param subnetName string
param location string = resourceGroup().location

resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pe-${sqlServerName}'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${sqlServerName}-sql-conn'
        properties: {
          privateLinkServiceId: sqlResourceId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
  }
}
