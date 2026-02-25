#
# Module 'TestEngine.psm1'
# Last Update: February 2026
#


####################################################################################################
<#
.SYNOPSIS
    Tests if the provided ApplicationID is valid (non-null, non-empty, and matches a pattern if needed).
.DESCRIPTION
    Checks the ApplicationID for validity. Ensures it is not null or empty, and can be extended to validate a specific format or pattern as required by your deployment standards.
.EXAMPLE
    Test-ApplicationID -ApplicationID "App-12345"
.EXAMPLE
    Test-ApplicationID -ApplicationID $DeploymentData.ApplicationID
.INPUTS
    [System.String]
.OUTPUTS
    [System.Boolean] Returns $true if valid, $false otherwise.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################
function Test-ApplicationID {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory=$true, HelpMessage='The ApplicationID to test.')]
        [System.String]$ApplicationID
    )

    begin {
        # Set the initial output value to true
        [System.Boolean]$OutputObject = $true

        # Handlers
        [System.String]$ApplicationIDDefaultValue = '<<APPLICATIONID>>'
    }

    process {
        # If the ApplicationID is null or empty, set the output to false
        if ([System.String]::IsNullOrWhiteSpace($ApplicationID)) { Write-Line "The ApplicationID is null or empty." -Type Fail ; $OutputObject = $false ; return }

        # If the ApplicationID still is the Default placeholder value, set the output to false
        if ($ApplicationID -eq $ApplicationIDDefaultValue) { Write-Line "The ApplicationID is still set to the default placeholder value ($ApplicationIDDefaultValue). Please provide a valid ApplicationID." -Type Fail ; $OutputObject = $false ; return }

        # Write the message
        Write-Line "ApplicationID '$ApplicationID' is valid." -Type Success
    }

    end {
        # Return the output
        $OutputObject
    }
}

# END OF FUNCTION
####################################################################################################

