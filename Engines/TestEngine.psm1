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
        [Parameter(Mandatory=$false, HelpMessage='The ApplicationID to test.')]
        [AllowEmptyString()][AllowNull()][System.String]$ApplicationID
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
        if ($ApplicationID -eq $ApplicationIDDefaultValue) {
            Write-Line "The ApplicationID is still set to the default placeholder value ($ApplicationIDDefaultValue). Please provide a valid ApplicationID." -Type Fail
            $OutputObject = $false ; return
        }

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


####################################################################################################
<#
.SYNOPSIS
    Tests if the provided DeploymentData hashtable contains valid properties.
.DESCRIPTION
    Checks the DeploymentData hashtable for validity. Ensures it is not null or empty, contains the 'ApplicationID' key, and that the value is not null, empty, or a default placeholder. Can be extended to validate additional keys or formats as required by your deployment standards.
.EXAMPLE
    Test-DeploymentData -DeploymentData $DeploymentData
.INPUTS
    [System.Collections.Hashtable]
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
function Test-DeploymentData {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory=$false, HelpMessage='The DeploymentData hashtable to test.')]
        [AllowNull()][System.Collections.Hashtable]$DeploymentData
    )

    begin {
        # Set the initial output value to true
        [System.Boolean]$OutputObject = $true

        # Handlers
        [System.String]$ApplicationIDDefaultValue = '<<APPLICATIONID>>'
    }

    process {
        # VALIDATION - NULL OR EMPTY
        # Validate the DeploymentData hashtable
        if (-not $DeploymentData -or $DeploymentData.Count -eq 0) { Write-Line "The DeploymentData Hashtable is null or empty." -Type Fail ; $OutputObject = $false ; return }

        # VALIDATION - MEMBERS
        # Validate the ApplicationID key
        if (-not $DeploymentData.ContainsKey('ApplicationID')) { Write-Line "DeploymentData does not contain the key 'ApplicationID'." -Type Fail ; $OutputObject = $false ; return }

        # Get the ApplicationID value
        [System.String]$ApplicationID = $DeploymentData['ApplicationID']

        # Validate the ApplicationID value
        if (-not(Test-ApplicationID -ApplicationID $ApplicationID)) { $OutputObject = $false ; return }

        # Write the message
        Write-Line "DeploymentData contains a valid ApplicationID: '$ApplicationID'." -Type Success
    }

    end {
        $OutputObject
    }
}

####################################################################################################

