param local_public_ip string
param location string = resourceGroup().location

resource nsgdmz 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: 'nsg-dmz'
  location: location
  tags: {}
  properties: {
    securityRules: [
      {
        name: 'wireguard-udp'
        properties: {
          description: 'Allow Wireguard inbound'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '51820'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 1001
          direction: 'Inbound'
        }
      }
      {
        name: 'allow_vnet_inbound'
        properties: {
          description: 'allow all traffic between subnets'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 3500
          direction: 'Inbound'
        }
      }
      // Disallow SSH once wireguard is in place and use JIT
      // {
      //   name: 'allow_ssh_local'
      //   properties: {
      //     description: 'Allow ssh from current local ip'
      //     protocol: 'Tcp'
      //     sourcePortRange: '*'
      //     destinationPortRange: '22'
      //     sourceAddressPrefix: local_public_ip
      //     destinationAddressPrefix: 'VirtualNetwork'
      //     access: 'Allow'
      //     priority: 115
      //     direction: 'Inbound'
      //   }
      // }
      {
        name: 'deny_catchall'
        properties: {
          description: 'Deny all inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
    ]
  }
}

output nsgdmzId string = nsgdmz.id
