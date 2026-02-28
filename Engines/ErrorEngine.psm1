#
# Module 'ErrorEngine.psm1'
# Last Update: February 2026
#

####################################################################################################
<#
.SYNOPSIS
    Writes the full details of an error to the host and logs it to a file.
.DESCRIPTION
    Provides a function for writing the full details of an error to the host in yellow color, including the error message, exception type, invoking function hierarchy and error details.
    The error is also logged to a file in the log folder.
.EXAMPLE
    Write-ErrorReport -ErrorRecord $_
.INPUTS
    [System.Management.Automation.ErrorRecord]$ErrorRecord
    The error record of which the details will be written.
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

function Write-ErrorReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage='The error record of which the details will be written.')]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )
    
    begin {
        # Get the full name of the exception type and the stack trace from the error record
        [System.String]$ErrorFullName   = $ErrorRecord.Exception.GetType().FullName
        [System.String]$StackTrace      = $ErrorRecord.ScriptStackTrace
    }
    
    process {
        # Write the error message and details to the host
        Write-Line -Type ErrorSeparator
        Write-Line "ERRORMESSAGE: An error has occurred. Please use the following details to pinpoint the issue:" -Type Busy
        Write-Line "Exception Type: $ErrorFullName" -Type Busy
        # Write the original error message
        $ErrorRecord | Out-Host
        # Write the stack trace
        [System.String[]]$TraceLines = $StackTrace -split "`n"
        foreach ($TraceLine in $TraceLines) {
            if ($TraceLine.TrimStart().StartsWith('at ')) {
                $TraceLine = 'Function: ' + $TraceLine.TrimStart().Substring(3)
            }
            Write-Host $TraceLine -ForegroundColor DarkGray
        }
        Write-Line -Type ErrorSeparator
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################

