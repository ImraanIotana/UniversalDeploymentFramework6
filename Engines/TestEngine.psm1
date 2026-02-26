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
    }

    process {
        # Validate the DeploymentData hashtable
        if (-not $DeploymentData -or $DeploymentData.Count -eq 0) { Write-Line "The DeploymentData Hashtable is null or empty." -Type Fail ; $OutputObject = $false ; return }
        # Validate the ApplicationID
        if (-not(Test-ApplicationID -DeploymentData $DeploymentData)) { $OutputObject = $false ; return }
        # Validate the SourceFilesFolder
        if (-not(Test-SourceFilesFolder -DeploymentData $DeploymentData)) { $OutputObject = $false ; return }
        # Validate the BuildNumber
        if (-not(Test-BuildNumber -DeploymentData $DeploymentData)) { $OutputObject = $false ; return }
        # Validate the DeploymentObjects
        if (-not(Test-DeploymentObjects -DeploymentData $DeploymentData)) { $OutputObject = $false ; return }
        # Write the success message
        Write-Line "The Deployment Data is valid." -Type Success
    }

    end {
        # Return the output
        $OutputObject
    }
}

####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Tests if the provided ApplicationID is valid (non-null, non-empty, not default placeholder).
.DESCRIPTION
    Checks the ApplicationID for validity. Ensures it is not null, empty, or a default placeholder value.
.EXAMPLE
    Test-ApplicationID -DeploymentData $DeploymentData
.INPUTS
    [System.Collections.Hashtable] The DeploymentData hashtable containing the ApplicationID key to test.
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
    param (
        [Parameter(Mandatory=$false, HelpMessage='The DeploymentData hashtable to test.')]
        [AllowNull()][System.Collections.Hashtable]$DeploymentData
    )
    begin {
        # Set the Property Name variable for ApplicationID
        [System.String]$PropertyName = 'ApplicationID'
        # Set the default placeholder value for ApplicationID
        [System.String]$ApplicationIDDefaultValue = '<<APPLICATIONID>>'
        # Set the initial output value to true
        [System.Boolean]$OutputObject = $true
    }
    process {
        # Validate the ApplicationID key
        if (-not(Test-DeploymentDataProperty -Hashtable $DeploymentData -Key $PropertyName)) { $OutputObject = $false ; return }
        # Validate the ApplicationID value
        [System.String]$ApplicationID = $DeploymentData[$PropertyName]
        if (Test-String -IsEmpty $ApplicationID) { Write-Line "The $PropertyName value is null or empty." -Type Fail ; $OutputObject = $false ; return }
        if ($ApplicationID -eq $ApplicationIDDefaultValue) {
            Write-Line "The $PropertyName is still set to the default placeholder value ($ApplicationIDDefaultValue). Please provide a valid ApplicationID." -Type Fail
            $OutputObject = $false ; return
        }
        # Write the success message
        Write-Line "The $PropertyName is valid. ($ApplicationID)" #-Type Success
    }
    end {
        # Return the output
        $OutputObject
    }
}
####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Tests if the provided SourceFilesFolder is valid (non-null, non-empty).
.DESCRIPTION
    Checks the SourceFilesFolder for validity. Ensures it is not null or empty.
.EXAMPLE
    Test-SourceFilesFolder -DeploymentData $DeploymentData
.INPUTS
    [System.Collections.Hashtable] The DeploymentData hashtable containing the SourceFilesFolder key to test.
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
function Test-SourceFilesFolder {
    param (
        [Parameter(Mandatory=$false, HelpMessage='The DeploymentData hashtable to test.')]
        [AllowNull()][System.Collections.Hashtable]$DeploymentData
    )
    begin {
        # Set the Property Name variable for SourceFilesFolder
        [System.String]$PropertyName = 'SourceFilesFolder'
        # Set the initial output value to true
        [System.Boolean]$OutputObject = $true
    }
    process {
        # Validate the SourceFilesFolder key
        if (-not(Test-DeploymentDataProperty -Hashtable $DeploymentData -Key $PropertyName)) { $OutputObject = $false ; return }
        # Validate the SourceFilesFolder value
        [System.String]$SourceFilesFolder = $DeploymentData[$PropertyName]
        if (Test-String -IsEmpty $SourceFilesFolder) { Write-Line "The $PropertyName value is null or empty." -Type Fail ; $OutputObject = $false ; return }
        # If the SourceFilesFolder value is not 'Default', validate that the folder exists
        if ($SourceFilesFolder -ne 'Default' -and -not (Test-Path -Path $SourceFilesFolder -PathType Container)) {
            Write-Line "The $PropertyName ($SourceFilesFolder) cannot be found." -Type Fail ; $OutputObject = $false ; return
        }
        # Write the success message
        Write-Line "The $PropertyName is valid. ($SourceFilesFolder)" #-Type Success
    }

    end {
        # Return the output
        $OutputObject
    }
}

####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Tests if the provided BuildNumber is valid (non-null, non-empty).
.DESCRIPTION
    Checks the BuildNumber for validity. Ensures it is not null or empty.
.EXAMPLE
    Test-BuildNumber -DeploymentData $DeploymentData
.INPUTS
    [System.Collections.Hashtable] The DeploymentData hashtable containing the BuildNumber key to test.
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
function Test-BuildNumber {
    param (
        [Parameter(Mandatory=$false, HelpMessage='The DeploymentData hashtable to test.')]
        [AllowNull()][System.Collections.Hashtable]$DeploymentData
    )
    begin {
        # Set the Property Name variable for BuildNumber
        [System.String]$PropertyName = 'BuildNumber'
        # Set the initial output value to true
        [System.Boolean]$OutputObject = $true
    }
    process {
        # Validate the BuildNumber key
        if (-not(Test-DeploymentDataProperty -Hashtable $DeploymentData -Key $PropertyName)) { $OutputObject = $false ; return }
        # Validate the BuildNumber value
        [System.String]$BuildNumber = $DeploymentData[$PropertyName]
        if (Test-String -IsEmpty $BuildNumber) { Write-Line "The $PropertyName value is null or empty." -Type Fail ; $OutputObject = $false ; return }
        # Validate the numeric format of the BuildNumber value
        [System.Int32]$ParsedBuildNumber = [System.Int32]::TryParse($BuildNumber, [ref]$null)
        if (-not $ParsedBuildNumber) { Write-Line "The $PropertyName value ('$BuildNumber') is not in a valid numeric format." -Type Fail ; $OutputObject = $false ; return }
        # Write the success message
        Write-Line "The $PropertyName is valid. ($BuildNumber)" #-Type Success
    }

    end {
        # Return the output
        $OutputObject
    }
    
}

####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Tests if the provided DeploymentObjects property is valid (non-null, non-empty).
.DESCRIPTION
    Checks the DeploymentObjects property for validity. Ensures it is not null or empty.
.EXAMPLE
    Test-DeploymentObjects -DeploymentData $DeploymentData
.INPUTS
    [System.Collections.Hashtable] The DeploymentData hashtable containing the DeploymentObjects key to test.
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
function Test-DeploymentObjects {
    param (
        [Parameter(Mandatory=$false, HelpMessage='The DeploymentData hashtable to test.')]
        [AllowNull()][System.Collections.Hashtable]$DeploymentData
    )
    begin {
        # Set the Property Name variable for DeploymentObjects
        [System.String]$PropertyName = 'DeploymentObjects'
        # Set the initial output value to true
        [System.Boolean]$OutputObject = $true
    }
    process {
        # Validate the DeploymentObjects key
        if (-not(Test-DeploymentDataProperty -Hashtable $DeploymentData -Key $PropertyName)) { $OutputObject = $false ; return }
        # Validate the DeploymentObjects value
        [System.Collections.Hashtable[]]$DeploymentObjects = $DeploymentData[$PropertyName]
        if (-not $DeploymentObjects -or $DeploymentObjects.Count -eq 0) { Write-Line "The $PropertyName value is null or empty." -Type Fail ; $OutputObject = $false ; return }
        # Write the success message
        Write-Line "The $PropertyName is valid." #-Type Success
    }
    end {
        # Return the output
        $OutputObject
    }
}

####################################################################################################


####################################################################################################
<#
.SYNOPSIS
    Helper function to test if a hashtable contains a key.
.DESCRIPTION
    Checks if the specified key exists in the hashtable.
.EXAMPLE
    Test-DeploymentDataProperty -Hashtable $DeploymentData -Key 'ApplicationID'
.INPUTS
    [System.Collections.Hashtable] The hashtable to check.
    [System.String] The key to look for in the hashtable.
.OUTPUTS
    [System.Boolean] Returns $true if the key exists, $false otherwise.
.NOTES
    Version         : 6.0.0.0
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
.COPYRIGHT
    This script is part of the Universal Deployment Framework. Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################
function Test-DeploymentDataProperty {
    param (
        [Parameter(Mandatory=$true, HelpMessage='The hashtable to check.')]
        [System.Collections.Hashtable]$Hashtable,

        [Parameter(Mandatory=$true, HelpMessage='The key to look for in the hashtable.')]
        [System.String]$Key
    )
    begin {
        # Set the initial output value to true
        [System.Boolean]$OutputObject = $true
    }

    process {
        # Check if the hashtable contains the specified key
        if (-not $Hashtable.ContainsKey($Key)) {
            Write-Line "DeploymentData does not contain the key '$Key'." -Type Fail
            $OutputObject = $false ; return
        }
    }

    end {
        # Return the output
        $OutputObject
    }
}

####################################################################################################
