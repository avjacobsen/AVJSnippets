# Source: https://github.com/avjacobsen/AVJSnippets

<#
.SYNOPSIS
    Read-Host enhancements.

    DefaultValue will let you set a default value, in case input is blank.
    Require will force a non-blank value.
#>
function Read-Host2 {
    # https://dev.azure.com/avjformula/Read-HostDefault/
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
    Writes log messages to log file.
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
    if ($Path -eq "" -and $PSCommandPath -ne "") {
        # No path supplied but running from script. Setting path to script name.
        $Path = "$(Get-Date -Format "yyyy")$(Get-Date -Format "MM")$(Get-Date -Format "dd")_$((Get-Item $PSCommandPath).BaseName).log"
    }
    $MessagePrefix = "$(Get-Date -Format "yyyy").$(Get-Date -Format "MM").$(Get-Date -Format "dd") $(Get-Date -Format "HH"):$(Get-Date -Format "mm"):$(Get-Date -Format "ss") "
    if ($Path -ne "") {
        Add-Content -Path $Path -Value "$($MessagePrefix)[$($MessageType)] $($Message)"
    }
    if ($VerbosePreference) {
        Write-Verbose "$($MessagePrefix)[$($MessageType)] $($Message)"
    }
    if ($DebugPreference) {
        Write-Debug "$($MessagePrefix)[$($MessageType)] $($Message)"
    }
}
function Get-AVJSnippetInfo {
    return $MyInvocation.ScriptName
    return $PSCommandPath
}
