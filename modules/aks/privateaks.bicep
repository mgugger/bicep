param basename string
param aadGroupdIds array
param logworkspaceid string
param privateDNSZoneId string
param subnetId string
param identity object
param principalId string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: '${basename}aks'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: identity
  }
  properties: {
    kubernetesVersion: '1.22.4'
    nodeResourceGroup: '${basename}-aksInfraRG'
    dnsPrefix: '${basename}aks'
    agentPoolProfiles: [
      {
        name: 'default'
        count: 2
        vmSize: 'Standard_DS3_v2'
        mode: 'System'
        maxCount: 5
        minCount: 1
        maxPods: 50
        enableAutoScaling: true
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
        osDiskType: 'Ephemeral'
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'kubenet'
      dockerBridgeCidr: '172.17.0.1/16'
      dnsServiceIP: '10.244.0.10'
      podCidr: '10.244.128.0/17'
      serviceCidr: '10.244.0.0/17'
      networkPolicy: 'calico'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
      privateDNSZone: privateDNSZoneId
    }
    enableRBAC: true
    aadProfile: {
      adminGroupObjectIDs: aadGroupdIds
      enableAzureRBAC: true
      managed: true
      tenantID: subscription().tenantId
    }
    addonProfiles: {
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: logworkspaceid
        }
        enabled: true
      }
      azurepolicy: {
        enabled: true
      }
      openServiceMesh: {
        enabled: true
        config: {}
      }
    }
  }
}

module aksPvtDNSContrib '../Identity/role.bicep' = {
  name: 'aksPvtDNSContrib'
  params: {
    principalId: principalId
    roleGuid: 'b12aa53e-6015-4669-85d0-8515ebb3ae7f' //Private DNS Zone Contributor
  }
}

module aksPvtNetworkContrib '../Identity/role.bicep' = {
  name: 'aksPvtNetworkContrib'
  params: {
    principalId: principalId
    roleGuid: '4d97b98b-1d4f-4787-a291-c67834d212e7' //Network Contributor
  }
}
