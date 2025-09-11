param location string = resourceGroup().location
param vnetName string = 'vnet-haipv25'
param appGwName string = 'agw-haipv25'
param nsgName string = 'nsg-haipv25'

@allowed([ '' ])
param sqlServerName string = ''
@allowed([ '' ])
param sqlResourceId string = ''

module vnet 'vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    vnetName: vnetName
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

module appgw 'appgw.bicep' = {
  name: 'appGatewayDeployment'
  params: {
    appGwName: appGwName
    vnetName: vnet.outputs.vnetName
    appGwSubnetName: vnet.outputs.appGwSubnetName
    location: location
    backendFqdns: [
      'haipv25-webapp-dev.azurewebsites.net'
      'haipv25-webapp-stg.azurewebsites.net'
      'haipv25-webapp.azurewebsites.net'
    ]
    probePath: '/actuator/health'
  }
}

module pe 'private-endpoint.bicep' = if (length(sqlServerName) > 0 && length(sqlResourceId) > 0) {
  name: 'privateEndpointDeployment'
  params: {
    sqlServerName: sqlServerName
    sqlResourceId: sqlResourceId
    vnetName: vnet.outputs.vnetName
    subnetName: vnet.outputs.defaultSubnetName
    location: location
  }
}
