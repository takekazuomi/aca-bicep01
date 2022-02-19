param vNetName string
param tags object = {}
param environmentStaticIp string
param environmentDefaultDomain string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vNetName
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.network/privatednszones
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: environmentDefaultDomain
  tags: tags
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.network/privatednszones/virtualnetworklinks
resource link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: vNetName
  parent: dnsZone
  tags: tags
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: true
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.network/privatednszones/a?tabs=bicep
resource dnsRecord  'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '*'
  parent: dnsZone
  properties: {
    aRecords: [
      {
        ipv4Address: environmentStaticIp
      }
    ]
    ttl: 3600
  }
}
