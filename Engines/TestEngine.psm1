#
# Module 'TestEngine.psm1'
# Last Update: February 2026
#


####################################################################################################
<#
.SYNOPSIS
    This function tests if a String is empty or populated.
.DESCRIPTION
    Tests if a String is empty or populated. The function has two parameter sets: one for testing if a string is empty, and another for testing if a string is populated.
    Depending on the parameter set used, it returns $true or $false accordingly.
.EXAMPLE
    Test-String -IsEmpty $MyString
.EXAMPLE
    Test-String -IsPopulated $MyString
.INPUTS
    [System.String]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Test-String {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='TestStringIsEmpty',HelpMessage='The string that will be handled.')]
        [AllowNull()][AllowEmptyString()][System.String]$IsEmpty,

        [Parameter(Mandatory=$true,ParameterSetName='TestStringIsPopulated',HelpMessage='The string that will be handled.')]
        [AllowNull()][AllowEmptyString()][System.String]$IsPopulated
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String]$ParameterSetName = $PSCmdlet.ParameterSetName

        # Input
        [System.String]$StringToTest = switch ($ParameterSetName) {
            'TestStringIsEmpty'     { $IsEmpty }
            'TestStringIsPopulated' { $IsPopulated }
        }

        # Output
        [System.Boolean]$OutputObject = $null

        ####################################################################################################
    }
    
    process {
        # Test if the string is empty
        [System.Boolean]$StringIsEmpty = if ( [System.String]::IsNullOrWhiteSpace($StringToTest) -or [System.String]::IsNullOrEmpty($StringToTest) ) { $true } else { $false }

        # Set the OutputObject based on the ParameterSetName
        $OutputObject = switch ($ParameterSetName) {
            'TestStringIsEmpty'     { $StringIsEmpty }
            'TestStringIsPopulated' { -Not($StringIsEmpty) }
        }
    }
    
    end {
        # Return the output
        $OutputObject
    }
}

### END OF SCRIPT
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
        # Define the default placeholder value for ApplicationID
        [System.String]$ApplicationIDDefaultValue = '<<APPLICATIONID>>'
    }

    process {
        # VALIDATION - NULL OR EMPTY
        # Validate the DeploymentData hashtable
        if (-not $DeploymentData -or $DeploymentData.Count -eq 0) { Write-Line "The DeploymentData Hashtable is null or empty." -Type Fail ; $OutputObject = $false ; return }

        # VALIDATION - APPLICATION ID
        # Set the Property Name variable for ApplicationID
        [System.String]$PropertyName = 'ApplicationID'
        # Validate the ApplicationID key
        if (-not $DeploymentData.ContainsKey($PropertyName)) { Write-Line "DeploymentData does not contain the key '$PropertyName'." -Type Fail ; $OutputObject = $false ; return }
        # Get the ApplicationID value
        [System.String]$ApplicationID = $DeploymentData[$PropertyName]
        # Validate the ApplicationID value
        if (Test-String -IsEmpty $ApplicationID) { $OutputObject = $false ; return }
        # Validate the ApplicationID value against the default placeholder
        if ($ApplicationID -eq $ApplicationIDDefaultValue) {
            Write-Line "The ApplicationID in DeploymentData is still set to the default placeholder value ($ApplicationIDDefaultValue). Please provide a valid ApplicationID." -Type Fail ; $OutputObject = $false ; return
        }
        # Write the success message
        Write-Line "The $PropertyName value in DeploymentData is valid. ($ApplicationID)" -Type Success

        # VALIDATION - SOURCEFILESFOLDER
        # Set the Property Name variable for SourceFilesFolder
        [System.String]$PropertyName = 'SourceFilesFolder'
        # Validate the SourceFilesFolder key
        if (-not $DeploymentData.ContainsKey($PropertyName)) { Write-Line "DeploymentData does not contain the key '$PropertyName'." -Type Fail ; $OutputObject = $false ; return }
        # Validate the SourceFilesFolder value
        [System.String]$SourceFilesFolder = $DeploymentData[$PropertyName]
        if (Test-String -IsEmpty $SourceFilesFolder) { Write-Line "The $PropertyName value in DeploymentData is null or empty." -Type Fail ; $OutputObject = $false ; return }
        # Write the success message
        Write-Line "The $PropertyName value in DeploymentData is valid. ($SourceFilesFolder)" -Type Success

        # VALIDATION - BUILD NUMBER
        # Set the Property Name variable for BuildNumber
        [System.String]$PropertyName = 'BuildNumber'
        # Validate the BuildNumber key
        if (-not $DeploymentData.ContainsKey($PropertyName)) { Write-Line "DeploymentData does not contain the key '$PropertyName'." -Type Fail ; $OutputObject = $false ; return }
        # Validate the BuildNumber value
        [System.String]$BuildNumber = $DeploymentData[$PropertyName]
        if (Test-String -IsEmpty $BuildNumber) { Write-Line "The $PropertyName value in DeploymentData is null or empty." -Type Fail ; $OutputObject = $false ; return }
        # Write the success message
        Write-Line "The $PropertyName value in DeploymentData is valid. ($BuildNumber)" -Type Success

        # VALIDATION - DeploymentObjects
        # Set the Property Name variable for DeploymentObjects
        [System.String]$PropertyName = 'DeploymentObjects'
        # Validate the DeploymentObjects key
        if (-not $DeploymentData.ContainsKey($PropertyName)) { Write-Line "DeploymentData does not contain the key '$PropertyName'." -Type Fail ; $OutputObject = $false ; return }
        # Validate the DeploymentObjects value
        [System.Collections.Hashtable[]]$DeploymentObjects = $DeploymentData[$PropertyName]
        if (-not $DeploymentObjects -or $DeploymentObjects.Count -eq 0) { Write-Line "The $PropertyName value in DeploymentData is null or empty." -Type Fail ; $OutputObject = $false ; return }
        # Write the success message
        Write-Line "The $PropertyName value in DeploymentData is valid." -Type Success
    }

    end {
        $OutputObject
    }
}

####################################################################################################

