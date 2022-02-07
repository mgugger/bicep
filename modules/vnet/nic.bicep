param subnetId string
param publicIpId string

resource jbnic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'vm-wireguard'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: (publicIpId == 'None') ? null : {
            id: publicIpId
          }
        }
      }
    ]
  }
}

output nicName string = jbnic.name
output nicId string = jbnic.id
