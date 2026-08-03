# Deployment flow

This repository is arranged for the following flow:

Bitbucket -> CodeBuild (Windows Fleet) -> Upload ZIP to S3 -> CodePipeline -> CodeDeploy -> Launch Green EC2 (Golden AMI)

## Files

- buildspec.yml
  - restores NuGet packages
  - builds the .NET Framework app
  - creates a CodeDeploy ZIP artifact
  - uploads the ZIP to S3

- deployment/appspec.yml
  - defines CodeDeploy hooks

- deployment/scripts/
  - BeforeInstall.ps1
  - AfterInstall.ps1
  - ApplicationStart.ps1
  - ValidateService.ps1

- bitbucket-pipelines.yml
  - placeholder pipeline file for Bitbucket trigger integration

## Expected artifact layout

Vidly.zip
  - app/
  - appspec.yml
  - scripts/
