targetScope = 'subscription'

var enableSecurityCenterFor = [
  'KeyVaults'
  'SqlServers'
  'VirtualMachines'
  'StorageAccounts'
  'ContainerRegistry'
  'KubernetesService'
  'SqlServerVirtualMachines'
  'AppServices'
  'Dns'
  'Arm'
]

resource securityCenterPricing 'Microsoft.Security/pricings@2018-06-01' = [for name in enableSecurityCenterFor: {
  name: name
  properties: {
    pricingTier: 'Standard'
  }
}]
