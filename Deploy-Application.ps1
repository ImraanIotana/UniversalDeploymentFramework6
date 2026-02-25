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
    Copyright (C) Iotana. All rights reserved.
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

# 1. SET THE APPLICATION ID
[System.String]$ApplicationID       = '<<APPLICATIONID>>'
# 2. SET THE BUILD NUMBER
[System.String]$BuildNumber         = '01'
# 3. SET THE SOURCE FILES FOLDER (If the sourcefiles are on a hardcoded location, then change this value. Else leave it as 'Default')
[System.String]$SourceFilesFolder   = 'Default'

#endregion ### END USER INPUT ###
####################################################################################################
### NO USER INPUT BELOW THIS POINT ###
}

process {
    # Create the Global DeploymentObject
    [PSCustomObject]$Global:DeploymentObject = @{
        # Main
        Name                        = [System.String]'Universal Deployment Framework'
        DeploymentScriptVersion     = [System.String]'6.0.0.0'
        # Deployment Handlers
        ApplicationID               = $ApplicationID
        BuildNumber                 = $BuildNumber
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


    # Get all ps1 files from the support folder
    #[System.IO.FileInfo[]]$Local:AllSupportScriptFiles = Get-ChildItem -Path $Global:DeploymentObject.SupportScriptsFolder -Recurse -File -Include *.ps1 -ErrorAction SilentlyContinue
    # Unblock the ps1 files
    #$Local:AllSupportScriptFiles | Unblock-File
    # Dot-source the ps1 files (External functions can be used after this line)
    #$Local:AllSupportScriptFiles | ForEach-Object { . $_.FullName }

    # Add the Engines path to the Environment Variable
    $ENV:PSModulePath += ";$($Global:DeploymentObject.EnginesFolder)"

    # Import the Write module
    #Import-Module ModuleWrite

    # Test
    Write-Host "The Name is: $($Global:DeploymentObject.Name)" -ForegroundColor Cyan
    Write-Host "The deployment action is: $($Global:DeploymentObject.Action)" -ForegroundColor Cyan
    Write-Host "The ApplicationID is: $($Global:DeploymentObject.ApplicationID)" -ForegroundColor Cyan

    # Set the filename of the Deployment Objects file
    [System.String]$DeploymentObjectsFileName = 'DeploymentObjects.psd1'
    [System.String]$DeploymentObjectsFilePath = Get-ChildItem -Path $Global:DeploymentObject.Rootfolder -Recurse -File -Include $DeploymentObjectsFileName -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    # Validate the Deployment Objects file
    if (-not($DeploymentObjectsFilePath)) {
        Write-Host "ERROR: Deployment Objects file '$DeploymentObjectsFileName' not found in the root folder or any subfolder." -ForegroundColor Red
        return
    }

    # Import the Deployment Objects from the .psd1 file
    [System.Collections.Hashtable[]]$DeploymentObjects = Import-PowerShellDataFile -Path $DeploymentObjectsFilePath -ErrorAction Stop
    Write-Host "Deployment Objects imported successfully from $DeploymentObjectsFilePath" -ForegroundColor Green

    # Output the Deployment Objects to the host
    Write-Host "Deployment Objects:" -ForegroundColor Cyan
    $DeploymentObjects.GetEnumerator() | Format-Table -AutoSize
    $Global:DeploymentObject.GetEnumerator() | Format-Table -AutoSize
}

end {
}

### END OF DEPLOYMENTSCRIPT
####################################################################################################
