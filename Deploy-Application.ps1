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
    # Switch for Installation
    [Parameter(Mandatory=$false,ParameterSetName='Install',Position=0)]
    [System.Management.Automation.SwitchParameter]
    $Install,

    # Switch for Uninstallation
    [Parameter(Mandatory=$true,ParameterSetName='Uninstall',Position=0)]
    [System.Management.Automation.SwitchParameter]
    $Uninstall,

    # Switch for Reinstallation
    [Parameter(Mandatory=$true,ParameterSetName='Reinstall',Position=0)]
    [System.Management.Automation.SwitchParameter]
    $Reinstall
)

begin {

####################################################################################################
####################################################################################################
####################################################################################################
#region ### START PACKAGER INPUT ###

# 1. SET THE APPLICATION ID
[System.String]$ApplicationID           = '<<APPLICATIONID>>'
# 1a. If you want to reverse the deployment order during Uninstall, then set this boolean to true. (Default value is $false. Note: this only works with Uninstall, not with Reinstall.)
[System.Boolean]$ReverseUninstallOrder  = $false
# 1b. If you want to abort the installation sequence, when the deployment of one object fails, then set this boolean to true. (Default value is $true)
[System.Boolean]$AbortWhenOneFails      = $true
# 1c. If the sourcefiles are on a network location, then change this value. Only fill in the Parent Folder. (For example: '//Domain/SCCMSources/NetworkInstallations'. The Application ID will be added automatically. Default value is 'Default')
[System.String]$SourceFilesFolder       = 'Default'
# 1d. The default Buildnumber is 01. If you created a new build of the same application and version, then increment this value.
[System.String]$BuildNumber             = '01'

####################################################################################################
# 2. SET THE DEPLOYMENT OBJECTS
# Add the Deployment Objects here. Please see the explanation in the lower section of this script.
[PSCustomObject[]]$DeploymentsObjectsArray = @(
)
####################################################################################################

#endregion ### END PACKAGER INPUT ###
####################################################################################################
####################################################################################################
####################################################################################################
### NO PACKAGER INPUT BELOW THIS POINT ###


####################################################################################################

    # Create the Global DeploymentObject
    [PSCustomObject]$Global:DeploymentObject = @{
        # Main
        Name                    = [System.String]'Universal Deployment Framework'
        DeploymentScriptVersion = [System.String]'5.6.2'
        CompanyName             = [System.String]'KeyStone'
        # Deployment Handlers
        ApplicationID           = [System.String]$ApplicationID
        BuildNumber             = [System.String]$BuildNumber
        #DeploymentObjects       = [PSCustomObject[]]$DeploymentsObjectsArray
        Action                  = [System.String]$PSCmdlet.ParameterSetName
        ReverseUninstallOrder   = [System.Boolean]$ReverseUninstallOrder
        AbortWhenOneFails       = [System.Boolean]$AbortWhenOneFails
        # Folders
        SupportScriptsFolder    = [System.String](Join-Path -Path $PSScriptRoot -ChildPath 'Deploy-ApplicationSupport')
        SourceFilesFolder       = if ($SourceFilesFolder -eq 'Default') { $PSScriptRoot } else { Join-Path -Path $SourceFilesFolder -ChildPath $ApplicationID }
        Rootfolder              = [System.String]$PSScriptRoot
        LogFolder               = [System.String](Join-Path -Path $ENV:ProgramData -ChildPath 'Application Installation Logs')
        SystemStartmenuFolder   = [System.String](Join-Path -Path $ENV:ProgramData -ChildPath 'Microsoft\Windows\Start Menu\Programs')
        SystemDesktopFolder     = [System.String]'C:\Users\Public\Desktop'
        # Files
        PowerShellExePath       = [System.String](Join-Path -Path ([System.Environment]::SystemDirectory) -ChildPath 'WindowsPowerShell\v1.0\powershell.exe')
        MSIExecutablePath       = [System.String](Join-Path -Path $ENV:SystemRoot -ChildPath 'System32\msiexec.exe')
        REGExecutablePath       = [System.String](Join-Path -Path $ENV:SystemRoot -ChildPath 'System32\REG.exe')
        # Administrative Handlers
        TimeStamp               = [System.String]((Get-Date -UFormat '%Y%m%d%R') -replace ':','')
        DeploymentResult        = [System.String]'DEFAULT_VALUE'
    }

    # Add the Module path to the Environment Variable
    #$ENV:PSModulePath += ";$($Global:DeploymentObject.SupportScriptsFolder)"
    # Import the Write module
    #Import-Module ModuleWrite

    # Get all ps1 files from the support folder
    #[System.IO.FileInfo[]]$Local:AllSupportScriptFiles = Get-ChildItem -Path $Global:DeploymentObject.SupportScriptsFolder -Recurse -File -Include *.ps1 -ErrorAction SilentlyContinue
    # Unblock the ps1 files
    #$Local:AllSupportScriptFiles | Unblock-File
    # Dot-source the ps1 files (External functions can be used after this line)
    #$Local:AllSupportScriptFiles | ForEach-Object { . $_.FullName }

}

process {
    # Test
    Write-Host "The Name is: $($Global:DeploymentObject.Name)" -ForegroundColor Cyan
    Write-Host "The deployment action is: $($Global:DeploymentObject.Action)" -ForegroundColor Cyan
    Write-Host "The ApplicationID is: $($Global:DeploymentObject.ApplicationID)" -ForegroundColor Cyan

    # Set the filename of the Deployment Objects file
    [System.String]$DeploymentObjectsFileName = 'DeploymentObjects.psd1'
    [System.String]$DeploymentObjectsFilePath = Get-ChildItem -Path $Global:DeploymentObject.Rootfolder -Recurse -File -Include $DeploymentObjectsFileName -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    # Check if the Deployment Objects file exists
    if (Test-Path -Path $DeploymentObjectsFilePath) {
        # Import the Deployment Objects from the .psd1 file
        [System.Collections.Hashtable[]]$Global:DeploymentObject.DeploymentObjects = Import-PowerShellDataFile -Path $DeploymentObjectsFilePath -ErrorAction Stop
        Write-Host "Deployment Objects imported successfully from $DeploymentObjectsFilePath" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: Deployment Objects file not found at $DeploymentObjectsFilePath" -ForegroundColor Red
        return
    }
    # Output the Deployment Objects to the host
    Write-Host "Deployment Objects:" -ForegroundColor Cyan
    $Global:DeploymentObject.DeploymentObjects | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
}

end {
}

### END OF DEPLOYMENTSCRIPT
####################################################################################################
