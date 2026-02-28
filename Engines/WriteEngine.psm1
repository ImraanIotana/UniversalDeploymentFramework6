#
# Module 'WriteEngine.psm1'
# Last Update: February 2026
#

####################################################################################################
<#
.SYNOPSIS
    Outputs a formatted message to the host with customizable colors for enhanced readability and status indication.
.DESCRIPTION
    Provides a function for writing messages to the host in various colors, supporting multiple message types for deployment and automation scenarios.
.EXAMPLE
    Write-Line "Hello World!"
.EXAMPLE
    Write-Line "Deployment completed successfully." -Type Success
.INPUTS
    [System.String]
.OUTPUTS
    No objects are returned to the pipeline. All operational output is written to the host and logged to the deployment logfile.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : February 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Write-Line {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()][AllowEmptyString()]
        [System.String]$Message,

        [Parameter(Mandatory=$false,HelpMessage='Type for deciding the colors.')]
        [ValidateSet('Busy','Success','Fail','Normal','Info','Special','NoAction','SuccessNoAction','ValidationSuccess','ValidationFail','Separator','DoubleSeparator','ErrorSeparator')]
        [AllowNull()][AllowEmptyString()]
        [System.String]$Type
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Set the main properties for the message
        [System.String]$OriginalMessage     = $Message
        [System.String]$MessageType         = $Type
        [System.String]$TimeStamp           = Get-TimeStamp -ForHost
        [System.String]$DeploymentAction    = $Global:DeploymentObject.Action # When using "Get-DeploymentData -PropertyName Action", it causes a loop.
        [System.String]$CallingFunction     = "[$((Get-PSCallStack).Command[1])]:"

        ####################################################################################################
    }
    
    process {
        # PREPARATION - MESSAGE FORMATTING
        # Set the message based on the MessageType
        [System.String]$FullMessage = switch ($MessageType) {
            'NoAction'          { 'No action has been taken.' }
            'SuccessNoAction'   { "$TimeStamp $CallingFunction The $($DeploymentAction)-process is considered successful. No action has been taken." }
            'Separator'         { "$TimeStamp ----------------------------------------------------------------------------------------------------" }
            'DoubleSeparator'   { "$TimeStamp ====================================================================================================" }
            'ErrorSeparator'    { "$TimeStamp -------------------------------------ERROR-REPORT---------------------------------------------------" }
            'ValidationSuccess' { "$TimeStamp $CallingFunction The validation is successful. The process will now start." }
            'ValidationFail'    { "$TimeStamp $CallingFunction The validation failed. The process will NOT start." }
            Default             { "$TimeStamp $CallingFunction $OriginalMessage" }
        }

        # PREPARATION - FOREGROUND COLOR SELECTION
        # Set the foreground color based on the MessageType
        [System.String]$ForegroundColor = switch ($MessageType) {
            'Busy'              { 'Yellow' }
            'Success'           { 'Green' }
            'SuccessNoAction'   { 'Green' }
            'Normal'            { 'White' }
            'Fail'              { 'Red' }
            'Special'           { 'Cyan' }
            'Separator'         { 'White' }
            'DoubleSeparator'   { 'White' }
            'ErrorSeparator'    { 'Cyan' }
            'ValidationFail'    { 'Red' }
            'Info'              { 'White' }
            Default             { 'DarkGray' }
        }

        # PREPARATION - BACKGROUND COLOR SELECTION
        # Set the background color based on the MessageType
        [System.String]$BackgroundColor = switch ($MessageType) {
            'Info'              { 'Gray' }
            Default             { '' }
        }

        # EXECUTION
        # Write the message
        switch ([System.String]::IsNullOrEmpty($BackgroundColor)) {
            $false  { Write-Host $FullMessage -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor }
            $true   { Write-Host $FullMessage -ForegroundColor $ForegroundColor }
        }
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################


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

