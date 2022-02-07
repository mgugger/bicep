param basename string

resource laprivatelinkscope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: '${basename}-pls'
  location: 'global'
  properties: {
    accessModeSettings: {
      exclusions: [
        {
          ingestionAccessMode: 'Open'
          privateEndpointConnectionName: 'laprivatelinkscopeep'
          queryAccessMode: 'Open'
        }
      ]
      ingestionAccessMode: 'Open'
      queryAccessMode: 'Open'
    }
  }
}

resource logworkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${basename}-workspace'
  location: resourceGroup().location
}

output laworkspaceId string = logworkspace.id
