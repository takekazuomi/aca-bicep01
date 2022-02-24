param environmentName string
param logAnalyticsWorkspaceName string = 'logs-${environmentName}'
param appInsightsName string = 'appins-${environmentName}'
param location string = resourceGroup().location
param controlPlaneSubnetId string
param applicationsSubnetId string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId:logAnalyticsWorkspace.id
  }
}

// https://github.com/Azure/azure-rest-api-specs/blob/main/specification/web/resource-manager/Microsoft.Web/stable/2021-03-01/KubeEnvironments.json
resource environment 'Microsoft.Web/kubeEnvironments@2021-03-01' = {
  name: environmentName
  location: location
  properties: {
    environmentType:'managed'
    internalLoadBalancerEnabled: true
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    containerAppsConfiguration: {
      daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
      controlPlaneSubnetResourceId:controlPlaneSubnetId
      appSubnetResourceId: applicationsSubnetId
    }
  }
}

output location string = location
output environmentId string = environment.id

