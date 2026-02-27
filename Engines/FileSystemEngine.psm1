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
    Open-Folder -HighlightItem C:\Demo\NewFolder
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
        [Parameter(Mandatory=$true,ParameterSetName='OpenTheFolder',HelpMessage='The path of the folder that will be opened.')]
        [Alias('Folder')][AllowEmptyString()][System.String]$Path,

        [Parameter(Mandatory=$true,ParameterSetName='HighlightTheItem',HelpMessage='The item that will be highlighted when the folder is opened.')]
        [Alias('SelectItem')][AllowEmptyString()][System.String]$HighlightItem
    )
    
    begin {
        # Set the ParameterSetName
        [System.String]$ParameterSetName    = [System.String]$PSCmdlet.ParameterSetName

        # Input
        [System.String]$FolderToOpen        = $Path
        [System.String]$ItemToHighlight     = $HighlightItem

        # Handlers
        [System.String]$HighlightPrefix     = '/select,"{0}"'
    }
    
    process {
        try {
            # EXECUTION
            switch ($ParameterSetName) {
                'OpenTheFolder'    {
                    # Validation
                    if (Test-String -IsEmpty $FolderToOpen) { Write-Line "The Path string is empty." -Type Fail ; return }
                    if (-Not(Test-Path -Path $FolderToOpen)) { Write-Line "The folder could not be reached: ($FolderToOpen)" -Type Fail ; return }
                    if (-not(Test-Path -Path $FolderToOpen -PathType Container)) { Write-Line "The specified path is not a folder: ($FolderToOpen)" -Type Fail ; return }
                    # Open the folder
                    Write-Line "Opening folder... ($FolderToOpen)"
                    Invoke-Item -Path $FolderToOpen
                }
                'HighlightTheItem' {
                    # Validation
                    if (Test-String -IsEmpty $ItemToHighlight) { Write-Line "The HighlightItem string is empty." -Type Fail ; return }
                    if (-Not(Test-Path -Path $ItemToHighlight)) { Write-Line "The item could not be reached: ($ItemToHighlight)" -Type Fail ; return }
                    # Open the folder and highlight the item
                    Write-Line "Highlighting item... ($ItemToHighlight)"
                    Start-Process explorer.exe -ArgumentList ($HighlightPrefix -f $ItemToHighlight)
                }
            }
        }
        catch {
            Write-ErrorReport -ErrorRecord $_
        }

    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################

