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
        [System.IO.File]::AppendAllText($Path,"$($MessagePrefix)[$($MessageType)] $($Message)`n")
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
