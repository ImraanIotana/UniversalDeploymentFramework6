#
# Module 'HelperEngine.psm1'
# Last Update: February 2026
#

####################################################################################################
<#
.SYNOPSIS
    Returns a timestamp in a format suitable for filenames.
.DESCRIPTION
    This function returns the current timestamp. If the -ForFileName switch is used, the timestamp is formatted in a way that is suitable for use in filenames.
.EXAMPLE
    Get-TimeStamp -ForFileName
.INPUTS
    No input parameters are required for this function. It operates based on the specified parameters to determine the format of the timestamp.
    The function accepts an optional switch parameter named -ForFileName. If this switch is used, the function returns the current timestamp formatted as 'yyyyMMdd_HHmm', which is suitable for use in filenames. If the switch is not used, the function returns the current date and time in the default format.
.OUTPUTS
    [System.String] The timestamp is returned as a string.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
    .COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################
function Get-TimeStamp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,ParameterSetName='ForFileName',HelpMessage='Returns the timestamp in a format suitable for filenames.')]
        [System.Management.Automation.SwitchParameter]$ForFileName,

        [Parameter(Mandatory=$false,ParameterSetName='ForHost',HelpMessage='Returns the timestamp in a format suitable for display.')]
        [System.Management.Automation.SwitchParameter]$ForHost
    )

    begin {
        # PROPERTIES
        # Set the ParameterSetName
        [System.String]$ParameterSetName    = $PSCmdlet.ParameterSetName
        # Get the UTC Timestamp
        [System.DateTime]$UTCTimestamp      = (Get-Date).ToUniversalTime()
        # Set the variations
        [System.String]$LogDate = $UTCTimeStamp.ToString('yyyy-MM-dd')
        [System.String]$LogTime = $UTCTimeStamp.ToString('HH:mm:ss.fff')
        # Set the output
        [System.String]$OutputObject        = [System.String]::Empty
    }

    process {
        # EXECUTION
        # Switch the timestamp format based on the ParameterSetName
        $OutputObject = switch ($ParameterSetName) {
            'ForFileName'   { $UTCTimestamp.ToString('yyyy_MM_dd_HHmm') }
            'ForHost'       { "[$LogDate $LogTime]" }
            Default         { $UTCTimestamp.ToString() }
        }
    }
    
    end {
        # Return the output
        $OutputObject
    }
}

# END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Retrieves the DeploymentData from the Global DeploymentObject. If a specific property name is provided, it returns the value of that property from the DeploymentData.
.DESCRIPTION
    This function accesses the Global DeploymentObject to retrieve the DeploymentData. If a specific property name is provided as a parameter, it checks if that property exists within the DeploymentData and returns its value. If the property does not exist, it issues a warning and returns null. If no property name is provided, it returns the entire DeploymentData object.
.EXAMPLE
    Get-DeploymentData -PropertyName "ApplicationID"
.INPUTS
    [System.String]$PropertyName 
.OUTPUTS
    [System.String] The value of the specified property from the DeploymentData.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
    .COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################
function Get-DeploymentData {
    param (
        [Parameter(Mandatory=$true,HelpMessage='Specify the name of the property to retrieve from the DeploymentData.')]
        [ValidateSet('ApplicationID','BuildNumber','SourceFilesFolder','DeploymentObjects','Action','Rootfolder','LogFolder','LogFilePath','UDFVersion')]
        [System.String]$PropertyName
    )

    begin{
        # PROPERTIES
        # Set the DeploymentObject
        [PSCustomObject]$DeploymentObject               = $Global:DeploymentObject
        # Set the DeploymentData
        [System.Collections.Hashtable]$DeploymentData   = $DeploymentObject.DeploymentData
    }

    process {
        # VALIDATION
        # Validate the DeploymentObject
        if (-not $DeploymentObject) { Write-Line "The DeploymentObject was not found." -Type Fail ; return }
        # Check if the DeploymentData exists in the DeploymentObject
        if (-not $DeploymentData) { Write-Line "The DeploymentData was not found in the DeploymentObject." -Type Fail ; return }

        # EXECUTION
        # Get the DeploymentData from the DeploymentObject
        $OutputObject = switch ($PropertyName) {
            'ApplicationID'       { $DeploymentData.ApplicationID }
            'BuildNumber'         { $DeploymentData.BuildNumber }
            'SourceFilesFolder'   { $DeploymentData.SourceFilesFolder }
            'DeploymentObjects'   { $DeploymentData.DeploymentObjects }
            'Action'              { $DeploymentObject.Action }
            'Rootfolder'          { $DeploymentObject.Rootfolder }
            'LogFolder'           { $DeploymentObject.LogFolder }
            'LogFilePath'         { $DeploymentObject.LogFilePath }
            'UDFVersion'          { $DeploymentObject.UDFVersion }
            Default               { Write-Line "The specified property '$PropertyName' was not found." -Type Fail ; $null }
        }
    }

    end {
        # Return the output
        $OutputObject
    }
    
}

# END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Returns the size of a folder in Megabytes.
.DESCRIPTION
    This function returns the size of the specified folder in Megabytes. It recursively calculates the size of all files within the folder and its subfolders.
.EXAMPLE
    Get-FolderSize -FolderPath "C:\MyFolder"
.INPUTS
    [System.String]$FolderPath
    A string representing the path to the folder for which the size will be calculated.
.OUTPUTS
    [System.Double] The size of the folder in Megabytes.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
    .COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################
function Get-FolderSize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The path to the folder for which the size will be calculated.')]
        [System.String]$FolderPath
    )

    begin {
        # Set the output
        [System.Double]$SizeMB = 0.0
    }

    process {
        try {
            # EXECUTION
            # Validate the folder path
            if (-not (Test-Path -Path $FolderPath -PathType Container)) { Write-Line "The specified folder path was not found." -Type Fail ; return }
            # Get the size of the folder in Megabytes
            [System.IO.DirectoryInfo]$Directory = [System.IO.DirectoryInfo]::new($FolderPath)
            $TotalBytes = $Directory.EnumerateFiles('*', 'AllDirectories').Sum({ $_.Length })
            [System.Double]$SizeMB = [math]::Round($TotalBytes / 1MB, 2)
            
            # Write the size of the folder to the host
            Write-Line "The size of the folder '$FolderPath' is $SizeMB MB." -Type Special
        }
        catch {
            Write-ErrorReport -ErrorRecord $_
        }
    }
    
    end {
        # Return the output
        $SizeMB
    }
}

# END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Starts the global timer for the deployment process.
.DESCRIPTION
    This function starts a global timer by storing the current timestamp in a global variable. It is used to measure the elapsed time of the deployment process.
    It also logs the start time of the deployment process to the host.
.EXAMPLE
    Start-GlobalTimer
.INPUTS
    None
.OUTPUTS
    None. All operational output is written to the host and logged to the deployment logfile.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
    .COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################
function Start-GlobalTimer {
    [CmdletBinding()]
    param ()

    begin {}

    process {
        # Start the global timer by storing the current timestamp in a global variable
        $Global:UDF_GlobalStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        # Log the start time of the deployment process
        Write-Line -Type DoubleSeparation
        Write-Line "Deployment process started at $(Get-TimeStamp -ForHost)"
    }

    end{}
}

# END OF FUNCTION
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Stops the global timer and reports elapsed time.
.DESCRIPTION
    This function stops the global timer that was started by Start-GlobalTimer and reports the elapsed time of the deployment process.
    It also logs the completion time of the deployment process to the host.
.EXAMPLE
    Stop-GlobalTimer
.INPUTS
    None
.OUTPUTS
    None. All operational output is written to the host and logged to the deployment logfile.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
    .COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################
function Stop-GlobalTimer {
    [CmdletBinding()]
    param ()

    begin {}

    process {
        # Stop the global timer and report elapsed time
        if ($Global:UDF_GlobalStopwatch) {
            $Global:UDF_GlobalStopwatch.Stop()
            Write-Line "Deployment completed in: [$($Global:UDF_GlobalStopwatch.Elapsed)]"
            Remove-Variable -Name UDF_GlobalStopwatch -Scope Global -ErrorAction SilentlyContinue
        } else {
            # Log a warning if the global timer was not started
            Write-Line "The Global timer was not started." -Type Fail
        }
    }

    end {}
}

# END OF FUNCTION
####################################################################################################
