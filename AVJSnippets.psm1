# Source: https://github.com/avjacobsen/AVJSnippets

<#
.SYNOPSIS
    Converts an encrypted string to a plain text string.
#>
function Get-DecryptedString {
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "Encrypted string value to decrypt.")]
        [String]
        $EncryptedString
    )
    # Get Password from encrypted string
    $SecureString = $EncryptedString | ConvertTo-SecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    $PlainTextString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    return $PlainTextString
}
<#
.SYNOPSIS
    Converts a plain text string to an encrypted string.
    >>> SECURITY WARNING <<<
    The function takes a plain text string as an argument, that may be intercepted. Use at your own risk.
#>
function Get-EncryptedString {
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "String value to encrypt.")]
        [String]
        $String
    )
    $EncryptedString = ConvertTo-SecureString -String $String -AsPlainText -Force | ConvertFrom-SecureString
    return $EncryptedString
}
<#
.SYNOPSIS
    Read-Host enhancements.

    DefaultValue will let you set a default value, in case input is blank.
    Require will force a non-blank value.
#>
function Read-Host2 {
    param (
        [Parameter()]
        [switch]
        $AsSecureString,
        [Parameter()]
        [System.Object]
        $Prompt,
        [Parameter()]
        [String]
        $DefaultValue,
        [Parameter()]
        [switch]
        $Required
    )
    if (!$Prompt -and $DefaultValue) { throw "Prompt required if DefaultValue is used." }
    if ($AsSecureString) {
        if ($DefaultValue -ne "") {
            $Result = Read-Host -AsSecureString -Prompt "$($Prompt) [$($DefaultValue)]"
            if ($Result.Length -eq 0) {
                $Result = ConvertTo-SecureString -String $DefaultValue -AsPlainText -Force
            }
        }
        else {
            if ($null -ne $Prompt) {
                if ($Required) {
                    $Result = ""
                    while ($Result -eq "") {
                        $Result = Read-Host -AsSecureString -Prompt $Prompt
                    }
                }
                else {
                    $Result = Read-Host -AsSecureString -Prompt $Prompt
                }
            }
            else {
                if ($Required) {
                    $Result = ""
                    while ($Result -eq "") {
                        $Result = Read-Host -AsSecureString
                    }
                }
                else {
                    $Result = Read-Host -AsSecureString
                }
            }
        }
        return $Result
    }
    else {
        if ($DefaultValue -ne "") {
            $Result = Read-Host -Prompt "$($Prompt) [$($DefaultValue)]"
            if ($Result -eq "") {
                $Result = $DefaultValue
            }
        }
        else {
            if ($null -ne $Prompt) {
                if ($Required) {
                    $Result = ""
                    while ($Result -eq "") {
                        $Result = Read-Host -Prompt $Prompt
                    }
                }
                else {
                    $Result = Read-Host -Prompt $Prompt
                }
            }
            else {
                if ($Required) {
                    $Result = ""
                    while ($Result -eq "") {
                        $Result = Read-Host
                    }
                }
                else {
                    $Result = Read-Host
                }
            }
        }
        return $Result
    }
    return $null
}
function Read-HostTime {
    param (
        [Parameter()]
        [String]
        $Year,
        [Parameter()]
        [String]
        $Month,
        [Parameter()]
        [String]
        $Day,
        [Parameter()]
        [String]
        $Hour,
        [Parameter()]
        [String]
        $Minute,
        [Parameter()]
        [String]
        $Second
    )
    $DefaultDate = Get-Date -Millisecond 0
    $NewYear = $DefaultDate.Year
    $NewMonth = $DefaultDate.Month
    $NewDay = $DefaultDate.Day
    $NewHour = $DefaultDate.Hour
    $NewMinute = $DefaultDate.Minute
    $NewSecond = $DefaultDate.Second
    if ($Year -eq "") { $NewYear = Read-Host2 -Prompt "Year" -DefaultValue $DefaultDate.Year } else { $NewYear = $Year }
    if ($Month -eq "") { $NewMonth = Read-Host2 -Prompt "Month" -DefaultValue $DefaultDate.Month } else { $NewMonth = $Month }
    if ($Day -eq "") { $NewDay = Read-Host2 -Prompt "Day" -DefaultValue $DefaultDate.Day } else { $NewDay = $Day }
    if ($Hour -eq "") { $NewHour = Read-Host2 -Prompt "Hour" -DefaultValue $DefaultDate.Hour } else { $NewHour = $Hour }
    if ($Minute -eq "") { $NewMinute = Read-Host2 -Prompt "Minute" -DefaultValue $DefaultDate.Minute } else { $NewMinute = $Minute }
    if ($Second -eq "") { $NewSecond = Read-Host2 -Prompt "Second" -DefaultValue $DefaultDate.Second } else { $NewSecond = $Second }
    $NewDate = Get-Date -Year $NewYear -Month $NewMonth -Day $NewDay -Hour $NewHour -Minute $NewMinute -Second $NewSecond -Millisecond 0
    return $NewDate
}
<#
.SYNOPSIS
    Writes log messages to log file. Log filename, if omitted, is equal to base name of script running it prefixed by date and suffixed by .log.
    If function is run outside of a script, it simply writes to console instead of to file.
#>
function Write-LogMessage {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [String]
        $Message,
        [Parameter(Mandatory = $false)]
        [String]
        $MessageType = "INFO",
        [Parameter(Mandatory = $false)]
        [String]
        $Path = ""
    )
    $CurrentDate = Get-Date
    if ($Path -eq "" -and $MyInvocation.ScriptName -ne "") {
        # No path supplied but running from script. Setting path to script name.
        $Path = "{0:D4}" -f $CurrentDate.Year
        $Path += "{0:D2}" -f $CurrentDate.Month
        $Path += "{0:D2}" -f $CurrentDate.Day
        $Path += "_$((Get-Item $MyInvocation.ScriptName).BaseName).log"
    }
    $MessagePrefix = "{0:D4}" -f $CurrentDate.Year
    $MessagePrefix += ".{0:D2}" -f $CurrentDate.Month
    $MessagePrefix += ".{0:D2}" -f $CurrentDate.Day
    $MessagePrefix += " {0:D2}" -f $CurrentDate.Hour
    $MessagePrefix += ":{0:D2}" -f $CurrentDate.Minute
    $MessagePrefix += ":{0:D2}" -f $CurrentDate.Second
    if ($Path -ne "") {
        # Set-Content/Add-Content is not used because of unhandled exceptions that are thrown outside the function,
        # preventing the function itself to catch it.
        [System.IO.File]::AppendAllText($Path, "$($MessagePrefix)[$($MessageType)] $($Message)`n")
    }
    else {
        Write-Host "$($MessagePrefix)[$($MessageType)] $($Message)"
    }
    if ($VerbosePreference) {
        Write-Verbose "$($MessagePrefix)[$($MessageType)] $($Message)"
    }
    if ($DebugPreference) {
        Write-Debug "$($MessagePrefix)[$($MessageType)] $($Message)"
    }
}
function Get-RDSDenyTSConnections {
    $KeyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\'
    $ValueName = 'fDenyTSConnections'
    $Value = (Get-Item -Path $KeyPath).GetValue($ValueName)
    return $Value
}
function Set-RDSDenyTSConnections {
    param([switch]$Enabled, [switch]$Disabled, [switch]$NotConfigured)
    $KeyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\'
    $ValueName = 'fDenyTSConnections'
    if ($Enabled) {
        Set-ItemProperty -Path $KeyPath -Name $ValueName -Value 1
    }
    else {
        if ($Disabled) {
            Set-ItemProperty -Path $KeyPath -Name $ValueName -Value 0
        }
        else {
            if ($NotConfigured) {
                Remove-ItemProperty -Path $KeyPath -Name $ValueName
            }
        }
    }
}
function Get-RDSSingleSessionPerUser {
    $KeyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\'
    $ValueName = 'fSingleSessionPerUser'
    $Value = (Get-Item -Path $KeyPath).GetValue($ValueName)
    return $Value
}
function Set-RDSSingleSessionPerUser {
    param([switch]$Enabled, [switch]$Disabled, [switch]$NotConfigured)
    $KeyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\'
    $ValueName = 'fSingleSessionPerUser'
    if ($Enabled) {
        Set-ItemProperty -Path $KeyPath -Name $ValueName -Value 1
    }
    else {
        if ($Disabled) {
            Set-ItemProperty -Path $KeyPath -Name $ValueName -Value 0
        }
        else {
            if ($NotConfigured) {
                Remove-ItemProperty -Path $KeyPath -Name $ValueName
            }
        }
    }
}

function Get-RandomPassword {
    Param(
        [Parameter(Mandatory = $false)][ValidateRange(1, 2048)][UInt32] $Length = 16,
        [Parameter(Mandatory = $false)][ValidateSet($true, $false)][switch]$IncludeNonAlphaNumericCharacters = $false,
        [Parameter(Mandatory = $false)][ValidateSet($true, $false)][switch]$IncludeUpperCaseCharacters = $true,
        [Parameter(Mandatory = $false)][ValidateSet($true, $false)][switch]$IncludeLowerCaseCharacters = $true,
        [Parameter(Mandatory = $false)][ValidateSet($true, $false)][switch]$IncludeNumbers = $true,
        [Parameter(Mandatory = $false)][ValidateSet($true, $false)][switch]$IncludeSimilarCharacters = $false,
        [Parameter(Mandatory = $false)][ValidateSet($true, $false)][switch]$IncludeExclamationMark = $true
    )

    $NonAlphaNumericCharacters = '!', '"', '#', '$', '''', '%', '&', '/', '(', ')', '=', '+', '?', '-', '_', '<', '>', '*', ',', '.', ':', ';', '@', '[', ']', '^', '{', '|', '}'
    $UpperCaseCharacters = 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    $LowerCaseCharacters = 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
    $Numbers = '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'
    $SimilarCharacters = 'i', 'l', 'o', 'I', 'O', '0', '|', ',', '.'
    $ExclamationMark = @('!');

    # Determine minimum length based on parameters supplied
    $MinimumLength = 0;
    if ($IncludeNonAlphaNumericCharacters) { $MinimumLength += 1 }
    if ($IncludeUpperCaseCharacters) { $MinimumLength += 1 }
    if ($IncludeLowerCaseCharacters) { $MinimumLength += 1 }
    if ($IncludeNumbers) { $MinimumLength += 1 }
    if ($IncludeExclamationMark) { $MinimumLength += 1 }
    if ($Length -lt 1 -or $Length -lt $MinimumLength) { "Length too short."; return $null }

    # Define control variables to make sure at least one of these characters gets inserted into generated password
    if ($IncludeNonAlphaNumericCharacters) { $NonAlphaNumericCharactersNeeded = $true } else { $NonAlphaNumericCharactersNeeded = $false }
    if ($IncludeUpperCaseCharacters) { $UpperCaseCharactersNeeded = $true } else { $UpperCaseCharactersNeeded = $false }
    if ($IncludeLowerCaseCharacters) { $LowerCaseCharactersNeeded = $true } else { $LowerCaseCharactersNeeded = $false }
    if ($IncludeNumbers) { $NumbersNeeded = $true } else { $NumbersNeeded = $false }
    if ($IncludeExclamationMark) { $ExclamationMarkNeeded = $true } else { $ExclamationMarkNeeded = $false }

    for ($i = 0; $i -lt $Length; $i++) {
        # Whenever $NeededCharactersCount is equal to remaining characters to generate, you MUST generate a required character that hasn't yet been generated.
        $NeededCharactersCount = 0
        if ($NonAlphaNumericCharactersNeeded) { $NeededCharactersCount += 1 }
        if ($UpperCaseCharactersNeeded) { $NeededCharactersCount += 1 }
        if ($LowerCaseCharactersNeeded) { $NeededCharactersCount += 1 }
        if ($NumbersNeeded) { $NeededCharactersCount += 1 }
        if ($ExclamationMarkNeeded) { $NeededCharactersCount += 1 }
        $CharactersToChooseFrom = $null
        if ($NeededCharactersCount -eq ($Length - $i)) {
            # Generate a needed character
            if ($IncludeNonAlphaNumericCharacters -and $NonAlphaNumericCharactersNeeded) { $CharactersToChooseFrom += $NonAlphaNumericCharacters }
            if ($IncludeUpperCaseCharacters -and $UpperCaseCharactersNeeded) { $CharactersToChooseFrom += $UpperCaseCharacters }
            if ($IncludeLowerCaseCharacters -and $LowerCaseCharactersNeeded) { $CharactersToChooseFrom += $LowerCaseCharacters }
            if ($IncludeNumbers -and $NumbersNeeded) { $CharactersToChooseFrom += $Numbers }
            if ($IncludeExclamationMark -and $ExclamationMarkNeeded) { $CharactersToChooseFrom += $ExclamationMark }
        }
        else {
            # Generate any character
            if ($IncludeNonAlphaNumericCharacters) { $CharactersToChooseFrom += $NonAlphaNumericCharacters }
            if ($IncludeUpperCaseCharacters) { $CharactersToChooseFrom += $UpperCaseCharacters }
            if ($IncludeLowerCaseCharacters) { $CharactersToChooseFrom += $LowerCaseCharacters }
            if ($IncludeNumbers) { $CharactersToChooseFrom += $Numbers }
            if ($IncludeExclamationMark) { $CharactersToChooseFrom += $ExclamationMark }
        }
        # Remove similar characters
        if ($IncludeSimilarCharacters -eq $false) {
            $NonSimilarCharactersToChooseFrom = @()
            foreach ($character in $CharactersToChooseFrom) {
                if ($SimilarCharacters.Contains($character) -eq $false) { $NonSimilarCharactersToChooseFrom += $character }
            }
            $CharactersToChooseFrom = $NonSimilarCharactersToChooseFrom
        }
        $CharactersToChooseFromLength = $CharactersToChooseFrom.Length
        $CharacterNumberChosen = Get-Random -Minimum 0 -Maximum $CharactersToChooseFromLength
        $CharacterChosen = $CharactersToChooseFrom[$CharacterNumberChosen]
        if ($NonAlphaNumericCharacters.Contains($CharacterChosen)) { $NonAlphaNumericCharactersNeeded = $false }
        if ($UpperCaseCharacters.Contains($CharacterChosen)) { $UpperCaseCharactersNeeded = $false }
        if ($LowerCaseCharacters.Contains($CharacterChosen)) { $LowerCaseCharactersNeeded = $false }
        if ($Numbers.Contains($CharacterChosen)) { $NumbersNeeded = $false }
        if ($ExclamationMark.Contains($CharacterChosen)) { $ExclamationMarkNeeded = $false }
        $GeneratedPassword += $CharacterChosen
    }

    return $GeneratedPassword
}

function Get-RandomIPv6InternalAddress {
    # Generate 64-bit value for IPv6-style output:
    # - First byte fixed to 7D
    # - Remaining 7 bytes random

    # Create 8-byte buffer
    $bytes = New-Object byte[] 8

    # Fill all bytes with cryptographically secure random values
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)

    # Fix the first byte
    $bytes[0] = 0x7D

    # Convert to hex
    $hexString = ($bytes | ForEach-Object { $_.ToString("X2") }) -join ""

    # Group as IPv6-style blocks
    $ipv6Part = ($hexString -split '(.{4})' | Where-Object { $_ -ne "" }) -join ":"

    Write-Output "This string should suffice in creating an IPv6 address for internal use."
    Write-Output "RFC4193 Unique Unicast IP range is fc00::/7, which this script is based upon."
    Write-Output "It defines the first byte as FD and the rest of the 7 bytes randomly."
    Write-Output "Common practice is to append mac address to the last part of the IPv6 address."
    Write-Output "Prefix        : $(-join $hexString[0..1])"
    Write-Output "Global ID     : $(-join $hexString[2..11])"
    Write-Output "Subnet ID     : $(-join $hexString[12..15])"
    Write-Output "Combined/CID  : $($ipv6Part)::/64"
    Write-Output "IPv6 Addresses: $($ipv6Part):xxxx:xxxx:xxxx:xxxx"
}