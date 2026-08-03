$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repo = if ($env:CODEBUILD_SRC_DIR) { $env:CODEBUILD_SRC_DIR } else { (Get-Location).Path }
Set-Location $repo

$candidatePaths = @(
    'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe',
    'C:\Program Files\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe',
    'C:\Program Files\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe',
    'C:\Program Files (x86)\MSBuild\15.0\Bin\MSBuild.exe',
    'C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe'
)

$msbuild = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $msbuild) {
    $msbuild = (Get-Command msbuild.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source)
}

$nuget = (Get-Command nuget.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source)
if (-not $nuget) {
    $nugetCandidates = @(
        'C:\Program Files (x86)\NuGet\nuget.exe',
        'C:\Program Files\NuGet\nuget.exe'
    )
    $nuget = $nugetCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

if (-not $nuget) { throw 'nuget.exe was not found.' }
if (-not $msbuild) { throw 'msbuild.exe was not found.' }

Write-Host "NuGet path: $nuget"
Write-Host "MSBuild path: $msbuild"

$msbuildDir = Split-Path $msbuild -Parent

& $nuget restore .\src\NetFramework4App\NetFramework4App.csproj -PackagesDirectory .\packages -ConfigFile .\nuget.config -MSBuildPath $msbuildDir -NonInteractive
if ($LASTEXITCODE -ne 0) { throw 'NuGet restore failed.' }

& $msbuild .\src\NetFramework4App\NetFramework4App.csproj /p:Configuration=Release /p:Platform='Any CPU' /p:RestorePackages=false
if ($LASTEXITCODE -ne 0) { throw 'MSBuild failed.' }

New-Item -ItemType Directory -Force -Path .\artifacts\codedeploy\app | Out-Null
New-Item -ItemType Directory -Force -Path .\artifacts\codedeploy\scripts | Out-Null
Copy-Item .\src\NetFramework4App\bin\* .\artifacts\codedeploy\app -Recurse -Force
Copy-Item .\deployment\appspec.yml .\artifacts\codedeploy\appspec.yml -Force
Copy-Item .\deployment\scripts\* .\artifacts\codedeploy\scripts -Recurse -Force

if (-not (Test-Path '.\artifacts\codedeploy\app\Web.config')) { throw 'Web.config not found.' }
if (-not (Test-Path '.\artifacts\codedeploy\appspec.yml')) { throw 'appspec.yml not found.' }

Compress-Archive -Path .\artifacts\codedeploy\* -DestinationPath .\artifacts\Vidly.zip -Force

if ($env:S3_BUCKET_NAME) {
    aws s3 cp .\artifacts\Vidly.zip s3://$env:S3_BUCKET_NAME/$env:CODEBUILD_BUILD_ID/Vidly.zip --only-show-errors
}
else {
    Write-Host 'S3_BUCKET_NAME was not set; skipping S3 upload.'
}
