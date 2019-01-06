

configuration webConfiguration
{
    param (
        [Parameter(Mandatory = $False)]
        [String]$PackageLocation
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    # Import-DscResource -ModuleName WebAdministration

    Node 'localhost'
    {
        # Install IIS features
        WindowsFeature WebServerRole {
            Name   = "Web-Server"
            Ensure = "Present"
        }

        WindowsFeature WebManagementService {
            Name   = "Web-Mgmt-Service"
            Ensure = "Present"
        }

        WindowsFeature ASPNet45 {
            Name   = "Web-Asp-Net45"
            Ensure = "Present"
        }

        WindowsFeature HTTPRedirection {
            Name   = "Web-Http-Redirect"
            Ensure = "Present"
        }

        WindowsFeature CustomLogging {
            Name   = "Web-Custom-Logging"
            Ensure = "Present"
        }

        WindowsFeature LogginTools {
            Name   = "Web-Log-Libraries"
            Ensure = "Present"
        }

        WindowsFeature RequestMonitor {
            Name   = "Web-Request-Monitor"
            Ensure = "Present"
        }

        WindowsFeature Tracing {
            Name   = "Web-Http-Tracing"
            Ensure = "Present"
        }

        WindowsFeature BasicAuthentication {
            Name   = "Web-Basic-Auth"
            Ensure = "Present"
        }

        WindowsFeature WindowsAuthentication {
            Name   = "Web-Windows-Auth"
            Ensure = "Present"
        }

        WindowsFeature ApplicationInitialization {
            Name   = "Web-AppInit"
            Ensure = "Present"
        }

        if (![String]::IsNullOrEmpty($websitePackageUri)) {

            # Download and unpack the website into the default website
            Script DeployWebPackage {
                GetScript  = {@{Result = "DeployWebPackage"}}
                TestScript = {
                    return Test-Path -Path "C:\WebApp\Site.zip";
                }
                SetScript  = {

                    if (!(Test-Path -Path "C:\WebApp")) {
                        New-Item -Path "C:\WebApp" -ItemType Directory -Force | Out-Null;
                    }

                    $dest = "C:\WebApp\Site.zip" 

                    if (Test-Path -Path "C:\inetpub\wwwroot") {
                        Remove-Item -Path "C:\inetpub\wwwroot" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null;
                    }

                    if (!(Test-Path -Path "C:\inetpub\wwwroot")) {
                        New-Item -Path "C:\inetpub\wwwroot" -ItemType Directory -Force | Out-Null;
                    }

                    Invoke-WebRequest -Uri $using:websitePackageUri -OutFile $dest -UseBasicParsing;

                    Expand-Archive -Path $dest -DestinationPath "C:\inetpub\wwwroot" -Force;
                }
                DependsOn  = "[WindowsFeature]WebServerRole"
            }
        }
    }
}