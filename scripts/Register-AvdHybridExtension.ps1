<#
.SYNOPSIS
    Installs Microsoft.AzureVirtualDesktop.CloudDeviceExtension on Connected Arc hosts from the Azure control plane.
.DESCRIPTION
    Run from Azure Cloud Shell or an operator workstation with Azure CLI (az connectedmachine extension)
    so the AVD host pool registration token never touches GCP instance metadata.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SubscriptionId,

    [Parameter(Mandatory)]
    [string]$ArcResourceGroup,

    [Parameter(Mandatory)]
    [string]$HostPoolName,

    [Parameter(Mandatory)]
    [string]$HostPoolResourceGroup,

    [Parameter(Mandatory)]
    [string]$Location
)

$ErrorActionPreference = 'Stop'

az account set --subscription $SubscriptionId

$tokenJson = az desktopvirtualization hostpool retrieve-registration-token `
    --resource-group $HostPoolResourceGroup `
    --name $HostPoolName | ConvertFrom-Json
$regToken = $tokenJson.token
if (-not $regToken) {
    throw "Failed to retrieve registration token for host pool $HostPoolName."
}

$machines = az connectedmachine list --resource-group $ArcResourceGroup --query "[?status=='Connected'].name" -o json | ConvertFrom-Json
foreach ($m in $machines) {
    Write-Output "Registering Arc machine $m into host pool $HostPoolName..."
    az connectedmachine extension create `
        --resource-group $ArcResourceGroup `
        --machine-name $m `
        --name 'CloudDeviceExtension' `
        --publisher 'Microsoft.AzureVirtualDesktop' `
        --type 'CloudDeviceExtension' `
        --location $Location `
        --settings "{`"hostPoolName`":`"$HostPoolName`"}" `
        --protected-settings "{`"registrationInfoToken`":`"$regToken`"}"
}
