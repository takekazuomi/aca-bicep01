param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
param containerPort int
param isExternalIngress bool
param secrets array = []
param env array = []

param minReplicas int = 0

@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'single'

@allowed([
  'auto'
  'http'
  'http2'
])
param transport string = 'auto'

param allowInsecure bool = false

// The 'memory' field for each container, if provided, must contain a decimal value to
// no more than 2 decimal places followed by 'Gi' to denote the unit (Gibibytes).
// Example: '1.25Gi' or '2Gi'.
// The total requested CPU and memory resources for this application (CPU: 0.5, memory: 0.5) is invalid. Total CPU and memory for all containers defined in a Container App must add up to one of the following CPU
// - Memory combinations: [cpu: 0.25, memory: 0.5Gi]; [cpu: 0.5, memory: 1.0Gi]; [cpu: 0.75, memory: 1.5Gi]; [cpu: 1.0, memory: 2.0Gi]; [cpu: 1.25, memory: 2.5Gi]; [cpu: 1.5, memory: 3.0Gi]; [cpu: 1.75, memory: 3.5Gi]; [cpu: 2.0, memory: 4.0Gi]

var resources = [
  {
    cpu: '0.25'
    memory: '0.5Gi'
  }
  {
    cpu: '0.5'
    memory: '1.0Gi'
  }
  {
    cpu: '0.75'
    memory: '1.5Gi'
  }
  {
    cpu: '1.0'
    memory: '2.0Gi'
  }
  {
    cpu: '1.25'
    memory: '2.5Gi'
  }
  {
    cpu: '1.5'
    memory: '3.0Gi'
  }
  {
    cpu: '1.75'
    memory: '3.5Gi'
  }
  {
    cpu: '2.0'
    memory: '4.0Gi'
  }
]

// https://github.com/Azure/azure-rest-api-specs/blob/09c4eba6c2d24c5f18226f36948d7987f3b50055/specification/app/resource-manager/Microsoft.App/preview/2022-01-01-preview/ContainerApps.json#L412
resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  identity: {
    //type: 'SystemAssigned'
    type: 'None'
  }
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: revisionMode
      secrets: secrets
      registries: []
      ingress: {
        external: isExternalIngress
        targetPort: containerPort
        transport: transport
        allowInsecure: allowInsecure
        // traffic: [
        //   {
        //     weight: 100
        //     latestRevision: true
        //   }
        // ]
      }
      dapr:{
        enabled:false
      }
    }
    template: {
      // revisionSuffix: 'somevalue'
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
          resources: resources[0]
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 10
        rules: [
          {
            name: 'http-scale'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
