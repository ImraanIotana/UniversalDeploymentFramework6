#
# Module 'MainEngine.psm1'
# Last Update: February 2026
#

####################################################################################################
<#
.SYNOPSIS
    Deploys the Objects in the DeploymentObjectsArray.
.DESCRIPTION
    Provides a function for deploying objects in the DeploymentObjectsArray, supporting multiple deployment scenarios and automation tasks.
.EXAMPLE
    Deploy-Objects -Objects $DeploymentObjectsArray
.EXAMPLE
    Deploy-Objects -Objects $DeploymentObjectsArray -Force
.INPUTS
    [System.Array]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : February 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Deploy-Objects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The deployment data that will be used for processing.')]
        [System.Collections.Hashtable]$DeploymentData
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###
    }

    process {

        [System.Collections.Hashtable[]]$DeploymentObjects = $DeploymentData.DeploymentsObjects
        if (-not($DeploymentObjects) -or $DeploymentObjects.Count -eq 0) {
            Write-Line "Deployment Objects file '$DeploymentObjectsFileName' was found but contains no valid Deployment Objects." -Type Fail ; return
        }
        # Write the success message
        Write-Line "Deployment Objects imported successfully from $DeploymentObjectsFilePath" -Type Success
        # Write the amount of Deployment Objects that will be processed
        Write-Line "A total of $($DeploymentObjects.Count) Deployment Objects will be processed." -Type Special
        Write-Line "The Application ID is $($DeploymentData.ApplicationID)" -Type Special
        Write-Line "The Build Number is $($DeploymentData.BuildNumber)" -Type Special
        Write-Line "The Source Files Folder is $($DeploymentData.SourceFilesFolder)" -Type Special


        # EXECUTION
        foreach ($DeploymentObject in $DeploymentObjects) {
            # Write the message to the host
            Write-Line "Processing Deployment Object of type '$($DeploymentObject.Type)'..." -Type Busy
            # Output the Deployment Objects to the host for verification
            $DeploymentObject.GetEnumerator() | Format-Table -AutoSize
        }
    }
    
    end {
        # Write a completion message
        Write-Line "Deployment process completed." -Type Success
    }
}

# END OF FUNCTION
####################################################################################################
