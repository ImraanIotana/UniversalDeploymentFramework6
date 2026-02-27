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
        [Parameter(Mandatory=$false,ParameterSetName='ForFileName',HelpMessage='Switch to return the timestamp in a format suitable for filenames.')]
        [System.Management.Automation.SwitchParameter]$ForFileName
    )

    begin {
        # PROPERTIES
        # Set the ParameterSetName
        [System.String]$ParameterSetName    = $PSCmdlet.ParameterSetName
        # Set the output
        [System.String]$OutputObject        = [System.String]::Empty
    }

    process {
        # EXECUTION
        # Switch the timestamp format based on the ParameterSetName
        $OutputObject = switch ($ParameterSetName) {
            'ForFileName'   { (Get-Date).ToString('yyyyMMdd_HHmm') }
            Default         { Get-Date }
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
        [Parameter(Mandatory=$false,HelpMessage='Specify the name of the property to retrieve from the DeploymentData.')]
        [ValidateSet('ApplicationID','BuildNumber','SourceFilesFolder','DeploymentObjects','Action','Rootfolder','LogFolder','LogFilePath')]
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
