param(
    [string]$WebSiteName = "Default Web Site",
    [string]$AppPoolName = "DefaultAppPool"
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module WebAdministration -ErrorAction SilentlyContinue)) {
    Import-Module WebAdministration
}

if (-not (Get-Website -Name $WebSiteName -ErrorAction SilentlyContinue)) {
    throw "Website '$WebSiteName' was not found."
}

if (-not (Get-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue)) {
    New-WebAppPool -Name $AppPoolName
}

$site = Get-Website -Name $WebSiteName
$sitePath = $site.physicalPath

if (-not (Test-Path $sitePath)) {
    New-Item -ItemType Directory -Path $sitePath -Force | Out-Null
}

Write-Host "IIS setup completed."
