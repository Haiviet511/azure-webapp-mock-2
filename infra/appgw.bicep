param appGwName string = 'agw-haipv25'
param vnetName string = 'vnet-haipv25'
param appGwSubnetName string = 'appgw-subnet'
param location string = resourceGroup().location
param backendFqdns array = []
param probePath string = '/'

resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: '${appGwName}-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource appgw 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: appGwName
  location: location
  sku: {
    name: 'WAF_v2'
    tier: 'WAF_v2'
  }
  properties: {
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGwIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, appGwSubnetName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwFrontendIP'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port443'
        properties: {
          port: 443
        }
      }
    ]
    probes: [
      {
        name: 'probe-backends'
        properties: {
          protocol: 'Https'
          path: probePath
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          port: 443
        }
      }
    ]
    httpListeners: [
      {
        name: 'listener-80'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'appGwFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'port80')
          }
          protocol: 'Http'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'defaultPool'
        properties: {
          backendAddresses: [
            for f in backendFqdns: {
              fqdn: string(f)
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'defaultHttpsSettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGwName, 'probe-backends')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'listener-80')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'defaultPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'defaultHttpsSettings')
          }
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection' // theo yêu cầu bài
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
  }
}

output appGwName string = appgw.name
output appGwPublicIP string = pip.properties.ipAddress
