####################################################################################################
<#
.SYNOPSIS
    UNIVERSAL DEPLOYMENT FRAMEWORK: This deploys and removes applications, using a collection of scripts, collectively called The Universal Deployment Framework.
.DESCRIPTION
    This script is part of the Universal Deployment Framework (UDF) and provides a standardized, modular approach for installing and uninstalling applications.
    It supports all common deployment asset types, including MSI, EXE, fonts, drivers, certificates, and other application resources.
    The script can be executed manually or integrated into enterprise deployment platforms such as Microsoft Intune or Microsoft Configuration Manager (SCCM).
    INTUNE USAGE: Package this script together with the application source files into an .intunewin package. Use the command lines below.
    SCCM USAGE: Import the application into SCCM and configure the following command lines:
    - Install: powershell.exe -ExecutionPolicy Bypass -File .\Start-Deployment.ps1 -Install -Verbose
    - Uninstall: powershell.exe -ExecutionPolicy Bypass -File .\Start-Deployment.ps1 -Uninstall -Verbose
.EXAMPLE
    Start-Deployment.ps1
.EXAMPLE
    Start-Deployment.ps1 -Install
.EXAMPLE
    Start-Deployment.ps1 -Uninstall
.INPUTS
    Requires at minimum:
        - A valid Application/Asset ID
        - One or more Deployment Objects
    Source files (MSI, EXE, fonts, drivers, certificates, icons, etc.) may be placed in the root folder or any subfolder. The framework automatically discovers and
    resolves the required files. If multiple files share the same name, prepend the parent folder name to ensure uniqueness.
.OUTPUTS
    No objects are returned to the pipeline. All operational output is written to the host and logged to the deployment logfile.
.NOTES
    Version         : Defined in the DeploymentScriptVersion variable
    Author          : Imraan Iotana
    Creation Date   : January 2023
    Last Update     : January 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################


[CmdletBinding(DefaultParameterSetName='Install')]
param (
    [Parameter(Mandatory=$false,ParameterSetName='Install',HelpMessage='Use this switch to trigger the installation process.')]
    [System.Management.Automation.SwitchParameter]$Install,

    [Parameter(Mandatory=$true,ParameterSetName='Uninstall',HelpMessage='Use this switch to trigger the uninstallation process.')]
    [System.Management.Automation.SwitchParameter]$Uninstall
)

begin {
}

process {
    # MAIN OBJECT
    # Create the Global DeploymentObject
    [PSCustomObject]$Global:DeploymentObject = @{
        # Main
        Name                    = [System.String]'Universal Deployment Framework'
        UDFVersion              = [System.String]'6.0.0.0'
        Action                  = $PSCmdlet.ParameterSetName
        # Items
        Rootfolder              = $PSScriptRoot
        EnginesFolder           = (Join-Path -Path $PSScriptRoot -ChildPath 'Engines')
        DeploymentDataFilePath  = (Join-Path -Path $PSScriptRoot -ChildPath 'DeploymentData.psd1')
    }

    # ENGINES
    # Get all psm1 files in the Engines folder and import them
    Get-ChildItem -Path $Global:DeploymentObject.EnginesFolder -Filter *.psm1 -File -Recurse | ForEach-Object { Import-Module -Name $_.FullName -Force }

    # EXECUTION
    # Start the Deployment Process
    Start-MainDeploymentProcess -DeploymentDataFilePath $Global:DeploymentObject.DeploymentDataFilePath
}

end {
}

### END OF DEPLOYMENTSCRIPT
####################################################################################################
