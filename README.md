# .NET Framework 4 on Windows IIS with AWS CodePipeline

This sample provides a minimal ASP.NET Web Forms application targeting .NET Framework 4.8 and deployment assets for:

- AWS CodeBuild via buildspec.yml
- AWS CodeDeploy via appspec.yml
- Blue/Green style IIS deployment using PowerShell scripts

## Structure

- src/NetFramework4App/ - sample .NET Framework 4 web application
- scripts/deploy-iis-bluegreen.ps1 - deploys the package to a new IIS path and switches the site
- scripts/after-install.ps1 - ensures IIS website and application pool exist
- buildspec.yml - CodeBuild build and packaging steps
- appspec.yml - CodeDeploy hooks

## Notes

- Update the IIS website and app pool names in the PowerShell files to match your environment.
- In a real blue/green deployment, you should use a load balancer health check and a staging site/path before switching traffic.
- This example is intentionally simple and intended as a starting point.
