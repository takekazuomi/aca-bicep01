param name string
param location string
param addressPrefixes array = [
  '10.0.0.0/16'
]
param controlPlane string = '10.0.0.0/21'
param applications string = '10.0.8.0/21'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: 'control-plane'
        properties: {
          addressPrefix: controlPlane
        }
      }
      {
        name: 'applications'
        properties: {
          addressPrefix: applications
        }
      }
    ]
  }
}

output controlPlaneSubnetId string = vnet.properties.subnets[0].id
output applocationSubnetId string = vnet.properties.subnets[1].id
