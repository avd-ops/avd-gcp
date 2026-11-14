<#
.SYNOPSIS
    Onboards a GCP Compute Engine Windows 11 Enterprise host to Azure Arc and registers it with an AVD Hybrid host pool.
.DESCRIPTION
    Idempotent onboarding script for AVD Hybrid on GCP. Installs the Azure Connected Machine agent
    if not present, connects the host to the target Azure Arc Resource Group using a scoped service
    principal, and registers the host into the AVD Hybrid host pool via CloudDeviceExtension.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SubscriptionId,

    [Parameter(Mandatory)]
    [string]$ResourceGroup,

    [Parameter(Mandatory)]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [string]$Location,

    [Parameter(Mandatory)]
    [string]$ServicePrincipalId,

    [Parameter(Mandatory)]
    [SecureString]$ServicePrincipalSecret,

    [Parameter(Mandatory)]
    [string]$HostPoolName,

    [Parameter(Mandatory)]
    [SecureString]$HostPoolRegistrationToken
)

$ErrorActionPreference = 'Stop'

$azcmagent = 'C:\Program Files\AzureConnectedMachineAgent\azcmagent.exe'
if (-not (Test-Path $azcmagent)) {
    $msiPath = Join-Path $env:TEMP 'AzureConnectedMachineAgent.msi'
    Invoke-WebRequest -Uri 'https://aka.ms/AzureConnectedMachineAgent' -OutFile $msiPath
    Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /qn /norestart" -Wait
}

$status = & $azcmagent show --json 2>$null | ConvertFrom-Json
if (-not $status -or $status.status -ne 'Connected') {
    $bstrSp = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ServicePrincipalSecret)
    try {
        $plainSpSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrSp)
        & $azcmagent connect `
            --service-principal-id $ServicePrincipalId `
            --service-principal-secret $plainSpSecret `
            --subscription-id $SubscriptionId `
            --resource-group $ResourceGroup `
            --tenant-id $TenantId `
            --location $Location `
            --tags 'avd-ops=hybrid-gcp'
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrSp)
    }
}

Write-Output "Azure Arc agent connected for $env:COMPUTERNAME in $ResourceGroup. Install Microsoft.AzureVirtualDesktop.CloudDeviceExtension via Azure control plane with host pool $HostPoolName."
