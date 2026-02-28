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
        [Parameter(Mandatory=$false,HelpMessage='The path to the deployment data file that will be used for processing.')]
        [AllowEmptyString()][AllowNull()][System.String]$DeploymentDataFilePath
    )

    begin {
    }

    process {
        try {
            # IMPORT
            # Import the Deployment Data (This action needs to happen before all else, as the deployment data contains all the necessary information for the deployment process)
            if (-not(Import-DeploymentData -DeploymentDataFilePath $DeploymentDataFilePath)) { return }

            # LOGGING
            # Start the logging process
            Start-Logging
    
            # EXECUTION
            # Get the DeploymentObjects from the DeploymentData hashtable
            [System.Collections.ArrayList]$DeploymentObjects = Get-DeploymentData -PropertyName DeploymentObjects
    
            # Get the amount
            [System.Int32]$DeploymentObjectCount = $DeploymentObjects.Count
            # Write the amount of Deployment Objects that will be processed
            Write-Line "A total of $DeploymentObjectCount Deployment Objects will be processed." -Type Busy
            # Set the counter for the current Deployment Object
            [System.Int32]$CurrentDeploymentObjectIndex = 1
            # Process each Deployment Object    
            foreach ($DeploymentObject in $DeploymentObjects) {
                # Write the message to the host
                Write-Line -Type Seperation
                Write-Line "Processing Deployment Object ($CurrentDeploymentObjectIndex of $DeploymentObjectCount) of type ($($DeploymentObject.Type))..." -Type Busy
                # Output the Deployment Objects to the host for verification
                $DeploymentObject.GetEnumerator() | Format-Table -AutoSize
                # Increment the counter for the current Deployment Object
                $CurrentDeploymentObjectIndex++
            }
        }
        catch {
            Write-ErrorReport -ErrorRecord $_
        }
    }
    
    end {
        # Stop the global timer and report elapsed time
        Stop-GlobalTimer
        # End the logging process
        Stop-Logging
    }
}

# END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Imports the deployment data from the specified .psd1 file and adds it to the global deployment object for later use.
.DESCRIPTION
    This function takes the file path to the deployment data .psd1 file as input, validates the file, imports the data, and then adds it to the global deployment object for later use in the deployment process.
    The deployment data is expected to be defined in a .psd1 file as a hashtable with a key named 'DeploymentObjects' that holds an array of deployment objects to be processed.
.EXAMPLE
    Import-DeploymentData -DeploymentDataFilePath $DeploymentDataFilePath
.INPUTS
    [System.String]$DeploymentDataFilePath
    A string representing the file path to the deployment data .psd1 file that will be used for processing.
.OUTPUTS
    [System.Boolean]$ImportSuccessful
    A boolean value indicating whether the import process was successful or not. Returns $true if the import was successful, and $false if it failed.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Import-DeploymentData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The path to the deployment data file that will be imported.')]
        [AllowEmptyString()][AllowNull()][System.String]$DeploymentDataFilePath
    )

    begin {
        # Set the output
        [System.Boolean]$ImportSuccessful = $true
    }

    process {
        try {
            # VALIDATION
            # Validate the Deployment Data file
            if (Test-String -IsEmpty $DeploymentDataFilePath) { Write-Line "The Deployment Data filepath is empty." -Type Fail ; $ImportSuccessful = $false ; return }
            # Validate that the file exists at the specified path
            if (-not(Test-Path -Path $DeploymentDataFilePath -PathType Leaf)) { Write-Line "The Deployment Data file was not found at the specified path. ($DeploymentDataFilePath)" -Type Fail ; $ImportSuccessful = $false ; return }
            # Import the Deployment Data from the .psd1 file
            [System.Collections.Hashtable]$DeploymentData = Import-PowerShellDataFile -Path $DeploymentDataFilePath -ErrorAction SilentlyContinue
            if (-not($DeploymentData)) { Write-Line "Failed to import the Deployment Data file. Please ensure the file is a valid .psd1 file and contains the necessary data." -Type Fail ; $ImportSuccessful = $false ; return }
            # Validate the DeploymentData
            if (-not(Test-DeploymentData -DeploymentData $DeploymentData)) { $ImportSuccessful = $false ; return }
            # Add the DeploymentData to the Global DeploymentObject for later use
            Add-Member -InputObject $Global:DeploymentObject -MemberType NoteProperty -Name DeploymentData -Value $DeploymentData -Force
        }
        catch {
            Write-ErrorReport -ErrorRecord $_
            $ImportSuccessful = $false
        }
    }

    end {
        # Return the output
        $ImportSuccessful
    }
}

# END OF FUNCTION
####################################################################################################
