param vnetName string = 'vnet-haipv25'
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.1.0.0/24'
        }
      }
      {
        name: 'appgw-subnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output defaultSubnetName string = 'default'
output appGwSubnetName string = 'appgw-subnet'
output defaultSubnetId string = '${vnet.id}/subnets/default'
output appGwSubnetId string = '${vnet.id}/subnets/appgw-subnet'
