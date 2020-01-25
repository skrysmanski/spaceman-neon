#!/usr/bin/env pwsh

$script:ErrorActionPreference = 'Stop'

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
