targetScope = 'resourceGroup'

param location string = resourceGroup().location
param vnetName string = 'vnet-haipv25'
param defaultSubnetName string = 'default'
param appGwSubnetName string = 'appgw-subnet'
param nsgName string = 'haipv25-nsg'
param sqlServerName string = 'sqlserver-haipv25'

param backendFqdns array = [
  'haipv25-webapp-dev-dye4a7c0a6edd8g4.southeastasia-01.azurewebsites.net'
  'haipv25-webapp-staging-bkeucbg5bycuchfc.southeastasia-01.azurewebsites.net'
  'haipv25-webapp-fwcufjbabjgudqed.southeastasia-01.azurewebsites.net'
]

param wafPolicyResourceId string = '/subscriptions/788f2671-c295-4d6e-b5b6-b1535aafefef/resourceGroups/rg_fsa_f1_csm_ec_huutn/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/haipv25-policy-waf'

@secure()
param sqlResourceId string = ''

module nsgModule './nsg.bicep' = {
  name: 'nsgDeployment'
  params: {
    location: location
    nsgName: nsgName
  }
}

module vnetModule './vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    location: location
    vnetName: vnetName
    defaultSubnetName: defaultSubnetName
    appGwSubnetName: appGwSubnetName
    nsgName: nsgName
  }
  dependsOn: [ nsgModule ]
}

module appgwModule './appgw.bicep' = {
  name: 'appgwDeployment'
  params: {
    location: location
    appGwName: 'webapp-haipv25-GW'
    vnetName: vnetName
    appGwSubnetName: appGwSubnetName
    backendFqdns: backendFqdns
    wafPolicyResourceId: wafPolicyResourceId
  }
  dependsOn: [ vnetModule ]
}

module appInsightsModule './appinsights.bicep' = {
  name: 'appInsightsDeployment'
  params: {
    location: location
    appInsightsName: 'appi-haipv25'
  }
}

module privateEndpointModule './private-endpoint.bicep' = if (sqlResourceId != '') {
  name: 'privateEndpointDeployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlResourceId: sqlResourceId
    vnetName: vnetName
    subnetName: defaultSubnetName
  }
  dependsOn: [ vnetModule ]
}
