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

function Write-Line {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()][AllowEmptyString()]
        [System.String]$Message,

        [Parameter(Mandatory=$false,HelpMessage='Type for deciding the colors.')]
        [ValidateSet('Busy','Success','Fail','Normal','Special','NoAction','SuccessNoAction','ValidationSuccess','ValidationFail','Seperation','DoubleSeperation')]
        [AllowNull()][AllowEmptyString()]
        [System.String]$Type
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Create the Main Message Object
        [PSCustomObject]$MessageObject = @{
            InputMessage    = $Message
            MessageType     = $Type
            CallingFunction = [System.String]((Get-PSCallStack).Command[1]) # Get the name of the calling function
        }

        # Add the FullTimeStamp property
        $MessageObject | Add-Member -MemberType ScriptProperty FullTimeStamp -Value {
            [System.DateTime]$UTCTimeStamp  = [DateTime]::UtcNow
            [System.String]$LogDate         = $UTCTimeStamp.ToString('yyyy-MM-dd')
            [System.String]$LogTime         = $UTCTimeStamp.ToString('HH:mm:ss.fff')
            [System.String]$FullTimeStamp   = "$LogDate $LogTime"
            # Return the result
            $FullTimeStamp
        }

        # Add the FullMessage property
        $MessageObject | Add-Member -MemberType ScriptProperty FullMessage -Value {
            # Set the properties for the message
            [System.String]$TimeStamp       = $this.FullTimeStamp
            [System.String]$CallingFunction = $this.CallingFunction
            # Set the message based on the MessageType
            switch ($this.MessageType) {
                'NoAction'            { 'No action has been taken.' }
                'SuccessNoAction'     { "[$($TimeStamp)] [$($CallingFunction)]: The $($Global:DeploymentObject.Action)-process is considered successful. No action has been taken." }
                'Seperation'          { "[$($TimeStamp)] ----------------------------------------------------------------------------------------------------" }
                'DoubleSeperation'    { "[$($TimeStamp)] ====================================================================================================" }
                'ValidationSuccess'   { "[$($TimeStamp)] [$($CallingFunction)]: The validation is successful. The process will now start." }
                'ValidationFail'      { "[$($TimeStamp)] [$($CallingFunction)]: The validation failed. The process will NOT start." }
                Default               { "[$($TimeStamp)] [$($CallingFunction)]: $($this.InputMessage)" }
            }
        }

        # Add the ForegroundColor property
        $MessageObject | Add-Member -MemberType ScriptProperty ForegroundColor -Value {
            switch ($this.MessageType) {
                'Busy'                          { 'Yellow' }
                'Success','SuccessNoAction'     { 'Green' }
                'Normal','Fail'                 { 'White' }
                'Special'                       { 'Cyan' }
                'Seperation','DoubleSeperation' { 'White' }
                'ValidationFail'                { 'White' }
                Default                         { 'DarkGray' }
            }
        }

        # Add the BackgroundColor property
        $MessageObject | Add-Member -MemberType ScriptProperty BackgroundColor -Value {
            switch ($this.MessageType) {
                'Fail','ValidationFail' { 'DarkRed' }
                Default                 { '' }
            }
        }

        # WRITE METHOD
        # Add the WriteMessage method
        $MessageObject | Add-Member -MemberType ScriptMethod WriteMessage -Value {
            # Switch on the BackgroundColor
            switch ([System.String]::IsNullOrEmpty($this.BackgroundColor)) {
                $false  { Write-Host $this.FullMessage -ForegroundColor $this.ForegroundColor -BackgroundColor $this.BackgroundColor }
                $true   { Write-Host $this.FullMessage -ForegroundColor $this.ForegroundColor }
            }
        }

        ####################################################################################################
    }
    
    process {
        # Write the message
        $MessageObject.WriteMessage()
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################
