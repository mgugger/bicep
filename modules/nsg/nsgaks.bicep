param location string = resourceGroup().location

resource nsgaks 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: 'nsg-aks'
  location: location
  tags: {}
  properties: {
    securityRules: [
    ]
  }
}

output nsgaksId string = nsgaks.id
