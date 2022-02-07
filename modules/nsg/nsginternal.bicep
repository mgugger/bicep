param location string = resourceGroup().location

resource nsginternal 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: 'nsg-internal'
  location: location
  tags: {}
  properties: {
    securityRules: []
  }
}

output nsginternalId string = nsginternal.id
