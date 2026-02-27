#
# Module 'FileSystemEngine.psm1'
# Last Update: February 2026
#

####################################################################################################
<#
.SYNOPSIS
    Opens a folder or highlights an item in Explorer after basic validation.
.DESCRIPTION
    This function provides two main functionalities: opening a specified folder in Explorer or opening a folder and highlighting a specific item within it.
    It performs validation to ensure that the provided paths are valid and exist before attempting to open them.
    The function uses the 'Invoke-Item' cmdlet to open folders and 'Start-Process' with 'explorer.exe' to open folders with highlighted items.
.EXAMPLE
    Open-Folder -Path C:\Demo
    Opens the specified folder in Explorer.
.EXAMPLE
    Open-Folder -SelectItem C:\Demo\NewFolder
    Opens the folder and highlights the specified item in Explorer.
.INPUTS
    [System.String]
.OUTPUTS
    No objects are returned to the pipeline. All operational output is written to the host and logged to the deployment logfile.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : December 2025
    Last Update     : February 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Open-Folder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='OpenFolder',HelpMessage='The path of the folder that will be opened.')]
        [Alias('Folder')][AllowEmptyString()][System.String]$Path,

        [Parameter(Mandatory=$true,ParameterSetName='HighlightItem',HelpMessage='The item that will be highlighted when the folder is opened.')]
        [Alias('HighlightItem')][AllowEmptyString()][System.String]$SelectItem
    )
    
    begin {
        # Set the ParameterSetName
        [System.String]$ParameterSetName    = [System.String]$PSCmdlet.ParameterSetName

        # Input
        [System.String]$FolderToOpen        = $Path
        [System.String]$ItemToHighlight     = $SelectItem

        # Handlers
        [System.String]$HighlightPrefix     = '/select,"{0}"'
    }
    
    process {
        # VALIDATION
        switch ($ParameterSetName) {
            'OpenFolder'    {
                if (Test-String -IsEmpty $FolderToOpen) { Write-Line "The Path string is empty." -Type Fail ; Return }
                if (-Not(Test-Path -Path $FolderToOpen)) { Write-Line "The folder could not be reached: ($FolderToOpen)" -Type Fail ; Return }
                if (-not(Test-Path -Path $FolderToOpen -PathType Container)) { Write-Line "The specified path is not a folder: ($FolderToOpen)" -Type Fail ; Return }
            }
            'HighlightItem' {
                if (Test-String -IsEmpty $ItemToHighlight) { Write-Line "The SelectItem string is empty." -Type Fail ; Return }
                if (-Not(Test-Path -Path $ItemToHighlight)) { Write-Line "The selected item could not be reached: ($ItemToHighlight)" -Type Fail ; Return }
            }
        }

        # EXECUTION
        switch ($ParameterSetName) {
            'OpenFolder'    {
                # Open the folder
                try {
                    Write-Line "Opening folder... ($FolderToOpen)"
                    Invoke-Item -Path $FolderToOpen
                }
                catch {
                    Write-FullError
                }
            }
            'HighlightItem' {
                # Open the folder
                try {
                    Write-Line "Selecting item... ($ItemToHighlight)"
                    Start-Process explorer.exe -ArgumentList ($HighlightPrefix -f $ItemToHighlight)
                }
                catch {
                    Write-FullError
                }
            }
        }

    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################

