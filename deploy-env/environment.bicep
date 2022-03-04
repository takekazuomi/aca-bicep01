param environmentName string
param logAnalyticsWorkspaceName string
param appInsightsName string
param location string = resourceGroup().location
param controlPlaneSubnetId string
param applicationsSubnetId string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
  name: logAnalyticsWorkspaceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

// https://github.com/Azure/azure-rest-api-specs/blob/Microsoft.App-2022-01-01-preview/specification/app/resource-manager/Microsoft.App/preview/2022-01-01-preview/ManagedEnvironments.json
resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: environmentName
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    vnetConfiguration: {
      internal: false
      infrastructureSubnetId: controlPlaneSubnetId
      runtimeSubnetId: applicationsSubnetId
      // dockerBridgeCidr:''
      // platformReservedDnsIP:''
      // platformReservedCidr:''
    }
  }
}

output location string = location
output environmentId string = environment.id
