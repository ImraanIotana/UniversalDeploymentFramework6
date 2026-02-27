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
                'Busy'              { 'Yellow' }
                'Success'           { 'Green' }
                'SuccessNoAction'   { 'Green' }
                'Normal'            { 'White' }
                'Fail'              { 'Red' }
                'Special'           { 'Cyan' }
                'Seperation'        { 'White' }
                'DoubleSeperation'  { 'White' }
                'ValidationFail'    { 'Red' }
                Default             { 'DarkGray' }
            }
        }

        <# Add the BackgroundColor property
        $MessageObject | Add-Member -MemberType ScriptProperty BackgroundColor -Value {
            switch ($this.MessageType) {
                'Fail'              { 'DarkRed' }
                'ValidationFail'    { 'DarkRed' }
                Default             { '' }
            }
        }#>

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


####################################################################################################
<#
.SYNOPSIS
    Writes the full details of an error to the host and logs it to a file.
.DESCRIPTION
    Provides a function for writing the full details of an error to the host in yellow color, including the error message, exception type, invoking function hierarchy and error details.
    The error is also logged to a file in the log folder.
.EXAMPLE
    Write-FullError -Message 'The file could not be found.'
.EXAMPLE
    Write-FullError
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    No objects are returned to the pipeline. All operational output is written to the host and logged to the deployment logfile.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : June 2023
    Last Update     : February 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Write-FullError {
    [CmdletBinding(DefaultParameterSetName='UnknownError')]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='Message',Position=0,HelpMessage='Your custom message that will be written in yellow.')]
        [System.String]
        $Message,

        [Parameter(Mandatory=$false,ParameterSetName='UnknownError',Position=0,HelpMessage='Switch for using the default message for unknown errors.')]
        [System.Management.Automation.SwitchParameter]
        $UnknownError
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            ParameterSetName        = [System.String]$PSCmdlet.ParameterSetName
            # Log Handlers
            TimeStamp               = [System.String]((Get-Date -UFormat '%Y%m%d%R') -replace ':','')
            LogFolder               = [System.String]($Global:DeploymentObject.LogFolder)
            LogFileNameCircumFix    = [System.String]"$($Global:DeploymentObject.DeploymentData.ApplicationID)_Errorlog_{0}.log"
            # Text Handlers
            UnknownError            = [System.String]'An unknown error has occured.'
            InvokingHierarchy       = [System.String]'InvocationOrder    : '
            # Input
            InputMessage            = $Message
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Add the logfile path to the main object
            [System.String]$LogFileName = ($this.LogFileNameCircumFix -f $this.TimeStamp)
            Add-Member -InputObject $this -NotePropertyName LogFilePath -NotePropertyValue (Join-Path -Path $this.LogFolder -ChildPath $LogFileName)
            # Add the InvokingFunctionHierarchy to the main object
            $this.AddInvokingFunctionHierarchyToMainObject()
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the WriteFullError method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteFullError -Value {
            # Set the error message
            [System.String]$ErrorMessage = switch ($this.ParameterSetName) {
                'Message'       { $this.InputMessage }
                'UnknownError'  { $this.UnknownError }
            }
            # Set the full name of the error
            [System.String]$ErrorFullName = $Error[0].Exception.GetType().FullName
            # In case of an unknown error, write all error details
            if ($this.ParameterSetName -eq 'UnknownError') {
                Start-Transcript -Path $this.LogFilePath -Append
                Write-Host ('ERRORMESSAGE       : {0}' -f $ErrorMessage) -ForegroundColor Yellow
                Write-Host ('ExceptionType      : ') -ForegroundColor Yellow -NoNewline
                Write-Host $ErrorFullName
                Write-Host $this.InvokingHierarchy -ForegroundColor Yellow -NoNewline
                Write-Host $this.InvokingFunctionHierarchy
                Write-Host ('Details            :') -ForegroundColor Yellow
                $Error[0] | Out-Host
                Write-Host
                Stop-Transcript
                # Open the logfolder
                Open-Folder -SelectItem $this.LogFilePath
            } else {
                # Else only write the error message
                Write-Host ('ERRORMESSAGE: {0}' -f $ErrorMessage) -ForegroundColor Yellow
                Write-Host $this.InvokingHierarchy -ForegroundColor Yellow -NoNewline
                Write-Host $this.InvokingFunctionHierarchy
            }
        }

        ####################################################################################################
        ### SUPPORTING METHODS ###

        # Add the AddInvokingFunctionHierarchyToMainObject method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddInvokingFunctionHierarchyToMainObject -Value {
            # Set the indeces of the invoking functions
            [int[]]$IndecesOfInvokingFunctions = @(0..20)
            # Get the array of the invoking functions
            [string[]]$InvokingFunctionsArray = (Get-PSCallStack).Command
            # Fill the InvokingFunctionHierarchy
            [System.String]$InvokingFunctionHierarchy = [System.String]::Empty
            $IndecesOfInvokingFunctions.ForEach({
                # Get the name of the invoking function
                [System.String]$InvokingFunctionName = $InvokingFunctionsArray[$_]
                if ($InvokingFunctionName) { $InvokingFunctionHierarchy += ('[{0}] {1} ' -f $_, $InvokingFunctionName) }
            })
            # Add the InvokingFunctionHierarchy to the main object
            Add-Member -InputObject $this -NotePropertyName InvokingFunctionHierarchy -NotePropertyValue $InvokingFunctionHierarchy
        }

        ####################################################################################################

        $Local:MainObject.Begin()
    }
    
    process {
        $Local:MainObject.WriteFullError()
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################

