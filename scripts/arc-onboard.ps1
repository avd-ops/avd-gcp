<#
.SYNOPSIS
    Onboards a GCP Compute Engine Windows 11 Enterprise host to Entra ID and Azure Arc.
.DESCRIPTION
    Idempotent onboarding script for AVD Hybrid on GCP:
    1. Optionally applies an Entra ID bulk-enrollment provisioning package (.ppkg) if not already Entra-joined.
    2. Installs AzureConnectedMachineAgent if absent.
    3. Fetches the scoped Arc service principal secret from GCP Secret Manager (via the VM's least-privilege
       service account metadata token) or accepts -ServicePrincipalSecret out-of-band.
    4. Connects the host to the target Azure Arc Resource Group.
    5. Run scripts/Register-AvdHybridExtension.ps1 from the Azure control plane to install CloudDeviceExtension.
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

    [string]$GcpProjectId,

    [string]$ArcSpSecretId,

    [SecureString]$ServicePrincipalSecret,

    [string]$EntraProvisioningPackagePath,

    [string]$ProviderTag = 'hybrid-gcp'
)

$ErrorActionPreference = 'Stop'

# 1. Entra ID join (bulk-enrollment .ppkg) if not already joined
if ($EntraProvisioningPackagePath -and (Test-Path $EntraProvisioningPackagePath)) {
    $dsreg = & dsregcmd.exe /status | Out-String
    if ($dsreg -notmatch 'AzureAdJoined\s*:\s*YES') {
        Install-ProvisioningPackage -PackagePath $EntraProvisioningPackagePath -QuietInstall
    }
}

# 2. Install Azure Connected Machine Agent if absent
$azcmagent = 'C:\Program Files\AzureConnectedMachineAgent\azcmagent.exe'
if (-not (Test-Path $azcmagent)) {
    $msiPath = Join-Path $env:TEMP 'AzureConnectedMachineAgent.msi'
    Invoke-WebRequest -Uri 'https://aka.ms/AzureConnectedMachineAgent' -OutFile $msiPath
    Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /qn /norestart" -Wait
}

# 3. Connect to Azure Arc if not already Connected
$status = & $azcmagent show --json 2>$null | ConvertFrom-Json
if (-not $status -or $status.status -ne 'Connected') {
    $plainSpSecret = $null

    if ($GcpProjectId -and $ArcSpSecretId) {
        $tokenResp = Invoke-RestMethod -Headers @{ 'Metadata-Flavor' = 'Google' } `
            -Uri 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token'
        $smUri = "https://secretmanager.googleapis.com/v1/projects/$GcpProjectId/secrets/$ArcSpSecretId/versions/latest:access"
        $smResp = Invoke-RestMethod -Headers @{ Authorization = "Bearer $($tokenResp.access_token)" } -Uri $smUri
        $plainSpSecret = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($smResp.payload.data)).Trim()
    } elseif ($ServicePrincipalSecret) {
        $bstrSp = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ServicePrincipalSecret)
        try {
            $plainSpSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrSp)
        } finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstrSp)
        }
    } else {
        throw 'Provide either (-GcpProjectId and -ArcSpSecretId) or -ServicePrincipalSecret.'
    }

    try {
        & $azcmagent connect `
            --service-principal-id $ServicePrincipalId `
            --service-principal-secret $plainSpSecret `
            --subscription-id $SubscriptionId `
            --resource-group $ResourceGroup `
            --tenant-id $TenantId `
            --location $Location `
            --tags "avd-ops=$ProviderTag"
    } finally {
        $plainSpSecret = $null
    }
}

Write-Output "Azure Arc agent connected for $env:COMPUTERNAME in $ResourceGroup."
