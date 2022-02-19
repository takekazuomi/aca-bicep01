param environmentName string
param containerAppName string

param containerImage string
param containerPort int
param isExternalIngress bool = true
param location string = resourceGroup().location
param minReplicas int = 0
param transport string = 'auto'
param allowInsecure bool = false
param env array = []

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: environmentName
}

module containerApps 'container.bicep' = {
  name: 'containerApps'
  params: {
    location: location
    containerAppName: containerAppName
    containerImage: containerImage
    containerPort: containerPort
    environmentId: environment.id
    isExternalIngress: isExternalIngress
    minReplicas: minReplicas
    transport: transport
    allowInsecure: allowInsecure
    env: env
  }
}

output fqdn string = containerApps.outputs.fqdn
