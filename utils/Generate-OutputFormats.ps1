#!/usr/bin/env pwsh

$script:ErrorActionPreference = 'Stop'

try {
    class Color {
        [int] $Red
        [int] $Green
        [int] $Blue

        Color([string] $HtmlColor) {
            if ($HtmlColor -match '^#([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})$') {
                $this.Red   = [int] "0x$($Matches[1])"
                $this.Green = [int] "0x$($Matches[2])"
                $this.Blue  = [int] "0x$($Matches[3])"
            }
            else {
                throw "Invalid HTML color: $HtmlColor"
            }
        }

        [string] ToString() {
            return ("#{0:x2}{1:x2}{2:x2}" -f $this.Red, $this.Green, $this.Blue)
        }
    }

    class TerminalColors {
        [Color] $Black
        [Color] $Red
        [Color] $DarkRed
        [Color] $Green
        [Color] $DarkGreen
        [Color] $Yellow
        [Color] $DarkYellow
        [Color] $Blue
        [Color] $DarkBlue
        [Color] $Magenta
        [Color] $DarkMagenta
        [Color] $Cyan
        [Color] $DarkCyan
        [Color] $Gray
        [Color] $DarkGray
        [Color] $White
    }

    function Get-ThemeColors([string] $ColorsFile) {
        $themeColorsAsStrings = Get-Content $ColorsFile -Encoding utf8 | ConvertFrom-Json

        $terminalColors = [TerminalColors]::new()

        $terminalColors.Black       = [Color]::new($themeColorsAsStrings.Black)
        $terminalColors.Red         = [Color]::new($themeColorsAsStrings.Red)
        $terminalColors.DarkRed     = [Color]::new($themeColorsAsStrings.DarkRed)
        $terminalColors.Green       = [Color]::new($themeColorsAsStrings.Green)
        $terminalColors.DarkGreen   = [Color]::new($themeColorsAsStrings.DarkGreen)
        $terminalColors.Yellow      = [Color]::new($themeColorsAsStrings.Yellow)
        $terminalColors.DarkYellow  = [Color]::new($themeColorsAsStrings.DarkYellow)
        $terminalColors.Blue        = [Color]::new($themeColorsAsStrings.Blue)
        $terminalColors.DarkBlue    = [Color]::new($themeColorsAsStrings.DarkBlue)
        $terminalColors.Magenta     = [Color]::new($themeColorsAsStrings.Magenta)
        $terminalColors.DarkMagenta = [Color]::new($themeColorsAsStrings.DarkMagenta)
        $terminalColors.Cyan        = [Color]::new($themeColorsAsStrings.Cyan)
        $terminalColors.DarkCyan    = [Color]::new($themeColorsAsStrings.DarkCyan)
        $terminalColors.Gray        = [Color]::new($themeColorsAsStrings.Gray)
        $terminalColors.DarkGray    = [Color]::new($themeColorsAsStrings.DarkGray)
        $terminalColors.White       = [Color]::new($themeColorsAsStrings.White)

        return $terminalColors
    }

    $baseDir = "$PSScriptRoot/.."
    $outDir = "$baseDir/themes"

    $themeColors = Get-ThemeColors "$baseDir/colors.json"

    & $PSScriptRoot/theme-generators/README.ps1 $themeColors -OutputFile "$baseDir/README.md" -RelativeColorBoxesFolder 'themes/color-boxes'

    & $PSScriptRoot/theme-generators/WindowsTerminal.ps1 $themeColors -OutputFile "$outDir/WindowsTerminal.json"

    & $PSScriptRoot/theme-generators/WindowsConsoleRegFile.ps1 $themeColors -OutputFile "$outDir/WindowsConsole.reg"

    & $PSScriptRoot/theme-generators/iTerm2.ps1 $themeColors -OutputFile "$outDir/SpacemanNeon.itermcolors"

    & $PSScriptRoot/theme-generators/VSCodeTerminal.ps1 $themeColors -OutputFile "$outDir/VSCodeTerminal.json"
}
catch {
    function LogError([string] $exception) {
        Write-Host -ForegroundColor Red $exception
    }

    # Type of $_: System.Management.Automation.ErrorRecord

    # NOTE: According to https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/windows-powershell-error-records
    #   we should always use '$_.ErrorDetails.Message' instead of '$_.Exception.Message' for displaying the message.
    #   In fact, there are cases where '$_.ErrorDetails.Message' actually contains more/better information than '$_.Exception.Message'.
    if ($_.ErrorDetails -And $_.ErrorDetails.Message) {
        $unhandledExceptionMessage = $_.ErrorDetails.Message
    }
    elseif ($_.Exception -And $_.Exception.Message) {
        $unhandledExceptionMessage = $_.Exception.Message
    }
    else {
        $unhandledExceptionMessage = 'Could not determine error message from ErrorRecord'
    }

    # IMPORTANT: We compare type names(!) here - not actual types. This is important because - for example -
    #   the type 'Microsoft.PowerShell.Commands.WriteErrorException' is not always available (most likely
    #   when Write-Error has never been called).
    if ($_.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.WriteErrorException') {
        # Print error messages (without stacktrace)
        LogError $unhandledExceptionMessage
    }
    else {
        # Print proper exception message (including stack trace)
        # NOTE: We can't create a catch block for "RuntimeException" as every exception
        #   seems to be interpreted as RuntimeException.
        if ($_.Exception.GetType().FullName -eq 'System.Management.Automation.RuntimeException') {
            LogError "$unhandledExceptionMessage$([Environment]::NewLine)$($_.ScriptStackTrace)"
        }
        else {
            LogError "$($_.Exception.GetType().Name): $unhandledExceptionMessage$([Environment]::NewLine)$($_.ScriptStackTrace)"
        }
    }

    exit 1
}
