param appGwName string
param location string
param vnetName string
param appGwSubnetName string
param backendFqdns array
param wafPolicyResourceId string
param probePath string = '/'

var defaultFqdn = length(backendFqdns) > 0 ? backendFqdns[length(backendFqdns) - 1] : ''

var probes = [for fqdn in backendFqdns: {
  name: 'probe-${replace(fqdn, '.', '-')}'
  properties: {
    protocol: 'Http'
    host: fqdn
    path: probePath
    interval: 30
    timeout: 30
    unhealthyThreshold: 3
    pickHostNameFromBackendHttpSettings: false
    match: { statusCodes: [ '200-399' ] }
  }
}]

var pools = [for fqdn in backendFqdns: {
  name: 'pool-${replace(fqdn, '.', '-')}'
  properties: { backendAddresses: [ { fqdn: fqdn } ] }
}]

var settings = [for fqdn in backendFqdns: {
  name: 'bhs-${replace(fqdn, '.', '-')}'
  properties: {
    port: 80
    protocol: 'Http'
    cookieBasedAffinity: 'Disabled'
    pickHostNameFromBackendAddress: true
    probe: {
      id: resourceId('Microsoft.Network/applicationGateways/probes', appGwName, 'probe-${replace(fqdn, '.', '-')}')
    }
    requestTimeout: 30
  }
}]

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: '${appGwName}-pip'
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

resource appGw 'Microsoft.Network/applicationGateways@2022-09-01' = {
  name: appGwName
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    firewallPolicy: empty(wafPolicyResourceId) ? null : {
      id: wafPolicyResourceId
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
        properties: { publicIPAddress: { id: publicIP.id } }
      }
    ]
    frontendPorts: [
      { name: 'httpPort',  properties: { port: 80  } }
      { name: 'httpsPort', properties: { port: 443 } }
    ]
    probes: probes
    backendAddressPools: pools
    backendHttpSettingsCollection: settings
    httpListeners: [
      {
        name: 'listener-http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'appGwFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'httpPort')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    urlPathMaps: [
      {
        name: 'pathMap-http'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'pool-${replace(defaultFqdn, '.', '-')}')
          }
          defaultBackendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'bhs-${replace(defaultFqdn, '.', '-')}')
          }
          pathRules: concat(
            length(backendFqdns) > 0 ? [{
              name: 'rule-dev'
              properties: {
                paths: [ '/dev/*' ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'pool-${replace(backendFqdns[0], '.', '-')}')
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'bhs-${replace(backendFqdns[0], '.', '-')}')
                }
              }
            }] : [],
            length(backendFqdns) > 1 ? [{
              name: 'rule-staging'
              properties: {
                paths: [ '/staging/*' ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'pool-${replace(backendFqdns[1], '.', '-')}')
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'bhs-${replace(backendFqdns[1], '.', '-')}')
                }
              }
            }] : []
          )
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule-http-pathbased'
        properties: {
          priority: 100
          ruleType: 'PathBasedRouting'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'listener-http')
          }
          urlPathMap: {
            id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', appGwName, 'pathMap-http')
          }
        }
      }
    ]
  }
}

output appGwId string = appGw.id