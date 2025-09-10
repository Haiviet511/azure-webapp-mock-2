param location string = resourceGroup().location
param vnetName string = 'vnet-haipv25'
param subnetName string = 'default'
param nsgName string = 'nsg-haipv25'
param appGwName string = 'agw-haipv25'
param sqlServerName string
param sqlResourceId string

module vnet 'vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    vnetName: vnetName
    subnetName: subnetName
    location: location
  }
}

module nsg 'nsg.bicep' = {
  name: 'nsgDeployment'
  params: {
    nsgName: nsgName
    location: location
  }
}

module pe 'private-endpoint.bicep' = {
  name: 'privateEndpointDeployment'
  params: {
    sqlServerName: sqlServerName
    sqlResourceId: sqlResourceId
    vnetName: vnet.outputs.vnetName
    subnetName: vnet.outputs.subnetName
    location: location
  }
}

module appgw 'appgw.bicep' = {
  name: 'appGatewayDeployment'
  params: {
    appGwName: appGwName
    vnetName: vnet.outputs.vnetName
    subnetName: vnet.outputs.appGwSubnetName
    location: location
  }
}
