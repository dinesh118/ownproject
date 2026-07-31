param(
    [Parameter(Mandatory=$true)] [string]$WebsiteName,
    [Parameter(Mandatory=$true)] [string]$AppPoolName,
    [Parameter(Mandatory=$true)] [string]$SourcePath,
    [Parameter(Mandatory=$true)] [string]$TargetPath,
    [Parameter(Mandatory=$true)] [string]$DeploymentSlot,
    [string]$SitePhysicalPath = $null
)

$ErrorActionPreference = 'Stop'

function Ensure-Directory($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Get-IISWebSite($name) {
    return Get-Website | Where-Object { $_.Name -eq $name } | Select-Object -First 1
}

if (-not (Get-Module WebAdministration -ErrorAction SilentlyContinue)) {
    Import-Module WebAdministration
}

$site = Get-IISWebSite -name $WebsiteName
if (-not $site) {
    throw "Website '$WebsiteName' was not found."
}

$sitePath = if ($SitePhysicalPath) { $SitePhysicalPath } else { $site.physicalPath }
$slotPath = Join-Path $sitePath $DeploymentSlot
Ensure-Directory $slotPath

Write-Host "Copying deployment files to $slotPath"
Copy-Item -Path (Join-Path $SourcePath '*') -Destination $slotPath -Recurse -Force

Write-Host "Updating IIS site path to $slotPath"
Set-ItemProperty "IIS:\Sites\$WebsiteName" -Name physicalPath -Value $slotPath

Write-Host "Restarting application pool $AppPoolName"
Restart-WebAppPool -Name $AppPoolName

Write-Host "Deployment completed successfully for slot $DeploymentSlot"
