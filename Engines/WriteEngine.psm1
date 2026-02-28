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
        [ValidateSet('Busy','Success','Fail','Normal','Info','Special','NoAction','SuccessNoAction','ValidationSuccess','ValidationFail','Separation','DoubleSeparation')]
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
            'NoAction'            { 'No action has been taken.' }
            'SuccessNoAction'     { "$TimeStamp $CallingFunction The $($DeploymentAction)-process is considered successful. No action has been taken." }
            'Separation'          { "$TimeStamp ----------------------------------------------------------------------------------------------------" }
            'DoubleSeparation'    { "$TimeStamp ====================================================================================================" }
            'ValidationSuccess'   { "$TimeStamp $CallingFunction The validation is successful. The process will now start." }
            'ValidationFail'      { "$TimeStamp $CallingFunction The validation failed. The process will NOT start." }
            Default               { "$TimeStamp $CallingFunction $OriginalMessage" }
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
            'Separation'        { 'White' }
            'DoubleSeparation'  { 'White' }
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
    Write-ErrorReport -Message 'The file could not be found.'
.EXAMPLE
    Write-ErrorReport -UnknownError
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
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
        $ErrorFullName = $ErrorRecord.Exception.GetType().FullName
        $StackTrace = $ErrorRecord.ScriptStackTrace
        Write-Host ('Error Type: {0}' -f $ErrorFullName) -ForegroundColor Yellow
        Write-Host ('Stack Trace: {0}' -f $StackTrace) -ForegroundColor Yellow

        # Set the DeploymentObject
        [PSCustomObject]$DeploymentObject   = $Global:DeploymentObject

        # Logfile properties
        [System.String]$LogFolder           = $DeploymentObject.LogFolder
        [System.String]$ApplicationID       = $DeploymentObject.DeploymentData.ApplicationID
        [System.String]$TimeStamp           = (Get-Date -UFormat '%Y%m%d%R') -replace ':',''
        [System.String]$LogFileName         = "$($ApplicationID)_Errorlog_${TimeStamp}.log"

        # Text properties
        [System.String]$UnknownError        = 'An unknown error has occured.'
        [System.String]$InvokingHierarchy   = 'InvocationOrder    : '

        # Set the function for getting the invoking function hierarchy
        function Get-InvokingFunctionHierarchy {
            # Set the indeces
            [System.Int32[]]$Indeces    = 0..20
            # Get the call stack
            [System.String[]]$CallStack = (Get-PSCallStack).Command

            # Create a StringBuilder for concatenating strings
            [System.Text.StringBuilder]$StringBuilder = [System.Text.StringBuilder]::new()
            # Fill the StringBuilder with the invoking functions
            foreach ($Index in $Indeces) {
                [System.String]$FunctionName = $CallStack[$Index]
                if ($FunctionName) {
                    $null = $StringBuilder.AppendFormat("[{0}] {1} ", $Index, $FunctionName)
                }
            }
            # Return the result
            $StringBuilder.ToString()
        }

        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            ParameterSetName        = [System.String]$ParameterSetName
            # Log Handlers
            TimeStamp               = [System.String]$TimeStamp
            LogFolder               = [System.String]$LogFolder
            LogFileName             = [System.String]$LogFileName
            # Text Handlers
            UnknownError            = [System.String]$UnknownError
            InvokingHierarchy       = [System.String]$InvokingHierarchy
            # Input
            InputMessage            = [System.String]$InputMessage
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Add the logfile path to the main object
            [System.String]$LogFileName = ($this.LogFileName -f $this.TimeStamp)
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

        #$Local:MainObject.Begin()
    }
    
    process {
        #$Local:MainObject.WriteFullError()
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################

