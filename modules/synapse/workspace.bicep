param synapseName string
param location string
param sqlAdministratorLogin string
param sqlAdministratorLoginPassword string
param blobName string
param storageAccountType string
param sqlpoolName string
param bigDataPoolName string
param nodeSize string
param sparkPoolMinNodeCount int
param sparkPoolMaxNodeCount int
param defaultDataLakeStorageFilesystemName string
param collation string
param startIpaddress string
param endIpAddress string
param userObjectId string
param privateLinkSnetId string
param privateDnsZoneId string

var storageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageRoleUniqueId = guid(resourceId('Microsoft.Storage/storageAccounts', synapseName), blobName)
var storageRoleUserUniqueId = guid(resourceId('Microsoft.Storage/storageAccounts', synapseName), userObjectId)
resource datalakegen2 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: blobName
  kind: 'StorageV2'
  location: location
  properties:{
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: true
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: false
    allowCrossTenantReplication: false
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: []
  }
}
  sku: {
    name: storageAccountType
  }
  
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: '${blobName}-plink'
  location: location
  properties: {
    subnet: {
      id: privateLinkSnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${blobName}-plink'
        properties: {
          privateLinkServiceId: datalakegen2.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${privateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  name: '${datalakegen2.name}/default'
}

resource containera 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${datalakegen2.name}/default/${defaultDataLakeStorageFilesystemName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    blob
  ]
}

resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' = {
  name: synapseName
  location: location
  properties: {
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    managedVirtualNetwork: 'default'
    defaultDataLakeStorage: {
      accountUrl: 'https://${datalakegen2.name}.dfs.core.windows.net'
      filesystem: defaultDataLakeStorageFilesystemName
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource synapseroleassing 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: storageRoleUniqueId
  scope: datalakegen2
  properties: {
    principalId: synapse.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleID)
  }
}

resource userroleassing 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: storageRoleUserUniqueId
  scope: datalakegen2
  properties: {
    principalId: userObjectId
    principalType: 'User'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleID)
  }
}

resource manageid4Pipeline 'Microsoft.Synapse/workspaces/managedIdentitySqlControlSettings@2021-05-01' = {
  name: 'default'
  properties: {
    grantSqlControlToManagedIdentity: {
      desiredState: 'Enabled'
    }
  }
  parent: synapse
}

resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-03-01' = {
  name: sqlpoolName
  location: location
  parent: synapse
  sku: {
    name: 'DW100c'
  }
  properties: {
    collation: collation
    createMode: 'Default'
  }
}

resource sparkpool 'Microsoft.Synapse/workspaces/bigDataPools@2021-03-01' = {
  name: bigDataPoolName
  location: location
  parent: synapse
  properties: {
    nodeSize: nodeSize
    nodeSizeFamily: 'MemoryOptimized'
    autoScale: {
      enabled: true
      minNodeCount: sparkPoolMinNodeCount
      maxNodeCount: sparkPoolMaxNodeCount
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    sparkVersion: '3.1'
  }
}

resource allowazure4synapse 'Microsoft.Synapse/workspaces/firewallRules@2021-03-01' = {
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
  parent: synapse
}

resource symbolicname 'Microsoft.Synapse/workspaces/firewallRules@2021-03-01' = {
  name: 'AllowAccessPoint'
  properties: {
    endIpAddress: endIpAddress
    startIpAddress: startIpaddress
  }
  parent: synapse
}
