param prefixName string
param location string = resourceGroup().location

//var environmentName = 'env-${prefixName}-${uniqueString(resourceGroup().id)}'
var environmentName = 'acaenv-${prefixName}'

module vnet 'vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
    name: 'vnet'
  }
}

module environment './environment.bicep' = {
  name: 'environment'
  params: {
    location: location
    environmentName: environmentName
    controlPlaneSubnetId: vnet.outputs.controlPlaneSubnetId
    applicationsSubnetId: vnet.outputs.applocationSubnetId
  }
}

module acr 'acr.bicep' = {
  name: 'acr'
  params: {
    location: location
    namePrefix: prefixName
  }
}
