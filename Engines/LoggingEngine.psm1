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
        # PROPERTIES
        # Set the LogFolder
        [System.String]$LogFolder = Join-Path -Path $ENV:ProgramData -ChildPath 'ApplicationDeploymentLogs'
        # Add the LogFolder to the Global DeploymentObject for later use
        Add-Member -InputObject $Global:DeploymentObject -MemberType NoteProperty -Name LogFolder -Value $LogFolder -Force
    }

    process {
        # PREPARATION - PROPERTIES
        # Set the Log folder path
        [System.String]$LogFolderPath           = Get-DeploymentData -PropertyName LogFolder
        [System.String]$ApplicationID           = Get-DeploymentData -PropertyName ApplicationID
        [System.String]$ApplicationLogFolder    = Join-Path -Path $LogFolderPath -ChildPath $ApplicationID
        # Set the Logfile name
        [System.String]$Timestamp               = Get-TimeStamp -ForFileName
        [System.String]$Action                  = Get-DeploymentData -PropertyName Action
        [System.String]$LogFileName             = "$($ApplicationID)_UTC_$($Timestamp)_$($Action).log"
        # Set the full path to the Logfile
        [System.String]$LogFilePath             = Join-Path -Path $ApplicationLogFolder -ChildPath $LogFileName
        # Get the UDF version from the Global DeploymentObject
        [System.String]$UDFVersion              = Get-DeploymentData -PropertyName UDFVersion

        # PREPARATION - LOG FOLDER
        # Create the Log folder if it does not exist
        if (Test-Path -Path $ApplicationLogFolder -PathType Container) {
            Write-Line "The Log folder already exists. ($ApplicationLogFolder)"
        } else {
            New-Item -Path $ApplicationLogFolder -ItemType Directory -Force | Out-Null
            Write-Line "The Log folder was created at path: $ApplicationLogFolder" -Type Success
        }

        # Add the LogFilePath to the Global DeploymentObject for later use
        Add-Member -InputObject $Global:DeploymentObject -MemberType NoteProperty -Name LogFilePath -Value $LogFilePath -Force

        # LOGGING - START
        # Start the logging process
        Start-Transcript -Path $LogFilePath | Out-Null
        Write-Line "Started logging. Logfile: ($LogFilePath)"

        # Write the Copyright notice to the log
        Write-Line "This Deployment is executed by the Universal Deployment Framework version ($UDFVersion). Copyright (C) Iotana. All rights reserved."
        Write-Line "This Deployment is performed by user ($ENV:USERNAME) on machine ($ENV:COMPUTERNAME)."
        Write-Line "All timestamps are in UTC."
    }

    end {
    }
}

# END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Stops the logging process by ending the transcript session.
.DESCRIPTION
    This function ends the transcript session that was started by the Start-Logging function.
.EXAMPLE
    Stop-Logging
.INPUTS
    No input parameters are required for this function. It operates based on the Global DeploymentObject.
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
function Stop-Logging {
    [CmdletBinding()]
    param (
    )

    begin {
        # Set the LogFilePath
        [System.String]$LogFilePath = Get-DeploymentData -PropertyName LogFilePath
    }

    process {
        # Stop the transcript session to finalize logging
        Write-Line "Stopped logging. Logfile saved at path: ($LogFilePath)" -Type Busy
        Stop-Transcript | Out-Null
    }
    
    end {
    }
}
# END OF FUNCTION
####################################################################################################

