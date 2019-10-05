#!/usr/bin/env pwsh

$script:ErrorActionPreference = 'Stop'

function Get-ThemeColors($ColorsFile) {
    return Get-Content $ColorsFile -Encoding utf8 | ConvertFrom-Json
}

function Write-WindowsTerminalTheme($ThemeColors, [String] $OutputFile) {
    # NOTE: We use a string here rather than an object (in conjunction with ConvertTo-Json) because
    #   with an object we can't control the order of the properties (neither can we add comments)
    #   to the output.
    $windowsTerminalTheme = @"
{
    // From: https://github.com/skrysmanski/spaceman-neon
    "name" : "Spaceman Neon",

    "background" : "$($ThemeColors.Black)",
    "foreground" : "$($ThemeColors.Gray)",

    "black" : "$($ThemeColors.Black)",
    "brightBlack" : "$($ThemeColors.DarkGray)",
    "blue" : "$($ThemeColors.DarkBlue)",
    "brightBlue" : "$($ThemeColors.Blue)",
    "cyan" : "$($ThemeColors.DarkCyan)",
    "brightCyan" : "$($ThemeColors.Cyan)",
    "green" : "$($ThemeColors.DarkGreen)",
    "brightGreen" : "$($ThemeColors.Green)",
    "purple" : "$($ThemeColors.DarkMagenta)",
    "brightPurple" : "$($ThemeColors.Magenta)",
    "red" : "$($ThemeColors.DarkRed)",
    "brightRed" : "$($ThemeColors.Red)",
    "yellow" : "$($ThemeColors.DarkYellow)",
    "brightYellow" : "$($ThemeColors.Yellow)",
    "white" : "$($ThemeColors.Gray)",
    "brightWhite" : "$($ThemeColors.White)"
}

"@

    # NOTE: -NewLine prevent Out-File from appending a system-dependent newline at the end of the file.
    $windowsTerminalTheme | Out-File $OutputFile -Encoding utf8 -NoNewline
}

$baseDir = "$PSScriptRoot/.."

$themeColors = Get-ThemeColors "$baseDir/colors.json"

Write-WindowsTerminalTheme $themeColors "$baseDir/WindowsTerminal.json"
