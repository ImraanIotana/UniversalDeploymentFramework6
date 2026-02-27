#
# Module 'LoggingEngine.psm1'
# Last Update: February 2026
#

####################################################################################################
<#
.SYNOPSIS
    Creates the Log folder if it does not exist and initializes the deployment logfile.
.DESCRIPTION
    This function checks if the Log folder exists at the specified path. If it does not exist, it creates the folder. Then, it initializes the deployment logfile by creating a new log file with a unique name based on the current timestamp and stores the path to this logfile in the Global DeploymentObject for later use.
.EXAMPLE
    Start-Logging
.INPUTS
    No input parameters are required for this function. It operates based on the Global DeploymentObject.
    The function relies on the Global DeploymentObject to determine the path for the Log folder and to store the path to the initialized deployment logfile.
    The Global DeploymentObject is expected to have a property named 'LogFolder' that specifies the path to the Log folder where the deployment logfile will be created, and a property named 'TimeStamp' that provides a unique timestamp for naming the logfile.
    The function will create a new logfile with a name in the format 'DeploymentLog_<TimeStamp>.log' and store the full path to this logfile in the Global DeploymentObject under a property named 'LogFilePath'.
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
function Start-Logging {
    [CmdletBinding()]
    param (
    )

    begin {
        # Set the DeploymentObject
        [PSCustomObject]$DeploymentObject = $Global:DeploymentObject
    }

    process {
        # PREPARATION
        # Set the Log folder path
        [System.String]$LogFolderPath   = $DeploymentObject.LogFolder
        # Set the Logfile name using the timestamp from the Global DeploymentObject
        [System.String]$ApplicationID   = $DeploymentObject.DeploymentData.ApplicationID
        [System.String]$Timestamp       = $DeploymentObject.TimeStamp
        [System.String]$Action          = $DeploymentObject.Action
        [System.String]$LogFileName     = "$($ApplicationID)_$($Timestamp)_$($Action).log"
        # Set the full path to the Logfile
        [System.String]$LogFilePath     = Join-Path -Path $LogFolderPath -ChildPath $LogFileName

        # quick test
        write-line "Log folder path: $LogFolderPath" -Type Special
        write-line "Log file name: $LogFileName" -Type Special
        write-line "Log file path: $LogFilePath" -Type Special

        # LOGGING SETUP
        # Create the Log folder if it does not exist
        if (Test-Path -Path $LogFolderPath -PathType Container) {
            Write-Line "Log folder already exists at path: $LogFolderPath" -Type Success
        } else {
            New-Item -Path $LogFolderPath -ItemType Directory -Force | Out-Null
            Write-Line "Log folder created at path: $LogFolderPath" -Type Success
        }
        # Open the folder
        Open-Folder -Path $LogFolderPath

        <# Initialize the deployment logfile
        $Global:DeploymentObject.LogFilePath = $LogFilePath
        New-Item -Path $Global:DeploymentObject.LogFilePath -ItemType File -Force | Out-Null
        Write-Line "Deployment logfile initialized at path: $($Global:DeploymentObject.LogFilePath)" -Type Success#>
    }
    
    end {
    }
}

# END OF FUNCTION
####################################################################################################
