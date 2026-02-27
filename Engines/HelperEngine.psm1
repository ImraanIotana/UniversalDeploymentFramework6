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
        [Parameter(Mandatory=$false,ParameterSetName='ForFileName',HelpMessage='Use this switch to specify that the timestamp should be returned in a format suitable for filenames.')]
        [Switch]$ForFileName
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
