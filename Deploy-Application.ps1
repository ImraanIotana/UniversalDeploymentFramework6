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
    - Install: powershell.exe -ExecutionPolicy Bypass -File .\Deploy-Application.ps1 -Install -Verbose
    - Uninstall: powershell.exe -ExecutionPolicy Bypass -File .\Deploy-Application.ps1 -Uninstall -Verbose
.EXAMPLE
    Deploy-Application.ps1
.EXAMPLE
    Deploy-Application.ps1 -Install
.EXAMPLE
    Deploy-Application.ps1 -Uninstall
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
####################################################################################################
####################################################################################################
#region ### START USER INPUT ###

# 2. SET THE SOURCE FILES FOLDER (If the sourcefiles are on a hardcoded location, then change this value. Else leave it as 'Default')
[System.String]$SourceFilesFolder   = 'Default'

#endregion ### END USER INPUT ###
####################################################################################################
### NO USER INPUT BELOW THIS POINT ###
}

process {
    # MAIN OBJECT
    # Create the Global DeploymentObject
    [PSCustomObject]$Global:DeploymentObject = @{
        # Main
        Name                        = [System.String]'Universal Deployment Framework'
        UDFVersion                  = [System.String]'6.0.0.0'
        # Deployment Handlers
        Action                      = $PSCmdlet.ParameterSetName
        SourceFilesFolder           = if ($SourceFilesFolder -eq 'Default') { $PSScriptRoot } else { $SourceFilesFolder }
        # Folders
        EnginesFolder               = (Join-Path -Path $PSScriptRoot -ChildPath 'Engines')
        Rootfolder                  = $PSScriptRoot
        LogFolder                   = (Join-Path -Path $ENV:ProgramData -ChildPath 'Application Installation Logs')
        # Files
        DeploymentObjectsFileName   = 'DeploymentObjects.psd1'
        # Administrative Handlers
        TimeStamp                   = [System.String]((Get-Date -UFormat '%Y%m%d%R') -replace ':','')
    }

    # ENGINES
    # Get all psm1 files in the Engines folder and import them
    Get-ChildItem -Path $Global:DeploymentObject.EnginesFolder -Filter *.psm1 -File -Recurse | ForEach-Object { Import-Module -Name $_.FullName -Force }

    # DEPLOYMENT OBJECTS
    # Validate the Deployment Objects file
    [System.String]$DeploymentObjectsFileName = $Global:DeploymentObject.DeploymentObjectsFileName
    [System.String]$DeploymentObjectsFilePath = Get-ChildItem -Path $PSScriptRoot -Recurse -File -Include $DeploymentObjectsFileName -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    if (-not($DeploymentObjectsFilePath)) {
        Write-Line "Deployment Objects file '$DeploymentObjectsFileName' was not found in the root folder or any subfolder." -Type Fail ; return
    }
    # Import and Validate the Deployment Objects from the .psd1 file
    [System.Collections.Hashtable]$DeploymentData = Import-PowerShellDataFile -Path $DeploymentObjectsFilePath -ErrorAction Stop

    # EXECUTION
    # Deploy the Objects
    Start-Deployment -DeploymentData $DeploymentData
}

end {
}

### END OF DEPLOYMENTSCRIPT
####################################################################################################
