param location string
param sqlServerName string
param sqlResourceId string
param vnetName string
param subnetName string

resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${sqlServerName}-pe'
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
    privateLinkServiceConnections: [
      {
        name: '${sqlServerName}-plsc'
        properties: {
          privateLinkServiceId: sqlResourceId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}
