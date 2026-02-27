#
# Module 'MainEngine.psm1'
# Last Update: February 2026
#

####################################################################################################
<#
.SYNOPSIS
    Starts the main deployment process.
.DESCRIPTION
    This function serves as the main entry point for the deployment process. It takes the file path to the deployment objects .psd1 file as input, imports the deployment data, validates it, and then processes each deployment object accordingly.
    The deployment objects are expected to be defined in a .psd1 file as a hashtable with a key named 'DeploymentObjects' that holds an array of deployment objects to be processed.
    Each deployment object should have a 'Type' property that indicates the type of deployment action to be performed, along with any other necessary properties required for that action.
.EXAMPLE
    Start-MainDeploymentProcess -DeploymentObjectsFilePath $DeploymentObjectsFilePath
.INPUTS
    [System.String]$DeploymentObjectsFilePath
    A string representing the file path to the deployment objects .psd1 file that will be used for processing.
    The .psd1 file must contain a hashtable with a key named 'DeploymentObjects' that holds an array of deployment objects to be processed.
.OUTPUTS
    No objects are returned to the pipeline. All operational output is written to the host and logged to the deployment logfile.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Start-MainDeploymentProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The path to the deployment objects file that will be used for processing.')]
        [AllowEmptyString()][AllowNull()][System.String]$DeploymentObjectsFilePath
    )

    begin {
    }

    process {
        # VALIDATION
        # Validate the Deployment Objects file
        if (Test-String -IsEmpty $DeploymentObjectsFilePath) { Write-Line "The Deployment Objects filepath is empty." -Type Fail ; return }
        # Validate that the file exists at the specified path
        if (-not(Test-Path -Path $DeploymentObjectsFilePath -PathType Leaf)) { Write-Line "The Deployment Objects file was not found at the specified path. ($DeploymentObjectsFilePath)" -Type Fail ; return }
        # Import the Deployment Data from the .psd1 file
        [System.Collections.Hashtable]$DeploymentData = Import-PowerShellDataFile -Path $DeploymentObjectsFilePath -ErrorAction SilentlyContinue
        if (-not($DeploymentData)) { Write-Line "Failed to import the Deployment Objects file. Please ensure the file is a valid .psd1 file and contains the necessary data." -Type Fail ; return }
        # Validate the DeploymentData
        if (-not(Test-DeploymentData -DeploymentData $DeploymentData)) { return }
        # Add the DeploymentData to the Global DeploymentObject for later use
        Add-Member -InputObject $Global:DeploymentObject -MemberType NoteProperty -Name DeploymentData -Value $DeploymentData -Force | Out-Null


        # LOGGING
        # Start the logging process
        Start-Logging

        # EXECUTION
        # Get the DeploymentObjects from the DeploymentData hashtable
        [System.Collections.ArrayList]$DeploymentObjects = $DeploymentData.DeploymentObjects

        # Write the amount of Deployment Objects that will be processed
        Write-Line "A total of $($DeploymentObjects.Count) Deployment Objects will be processed." -Type Special

        foreach ($DeploymentObject in $DeploymentObjects) {
            # Write the message to the host
            Write-Line "Processing Deployment Object of type '$($DeploymentObject.Type)'..." -Type Busy
            # Output the Deployment Objects to the host for verification
            $DeploymentObject.GetEnumerator() | Format-Table -AutoSize
        }
    }
    
    end {
    }
}

# END OF FUNCTION
####################################################################################################

