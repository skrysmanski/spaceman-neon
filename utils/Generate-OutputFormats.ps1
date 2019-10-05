#!/usr/bin/env pwsh

$script:ErrorActionPreference = 'Stop'

function Get-ThemeColors($ColorsFile) {
    return Get-Content $ColorsFile -Encoding utf8 | ConvertFrom-Json
}

function ConvertFrom-HtmlColor($HtmlColor) {
    if ($HtmlColor -match '^#([a-z0-9]{2})([a-z0-9]{2})([a-z0-9]{2})$') {
        return @{
            Red   = [int] "0x$($Matches[1])"
            Green = [int] "0x$($Matches[2])"
            Blue  = [int] "0x$($Matches[3])"
        }
    }
    else {
        throw "Invalid HTML color: $HtmlColor"
    }
}

function Write-WindowsTerminalTheme($ThemeColors, [String] $OutputFile) {
    # NOTE: We use a string here rather than an object (in conjunction with ConvertTo-Json) because
    #   with an object we can't control the order of the properties (neither can we add comments)
    #   to the output.
    $output = @"
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
    $output | Out-File $OutputFile -Encoding utf8 -NoNewline
}

function Write-WindowsConsoleRegFile($ThemeColors, [String] $OutputFile) {
    function ConvertTo-RegValue($HtmlColor) {
        $rgbColor = ConvertFrom-HtmlColor $HtmlColor

        $red = $rgbColor.Red.ToString('x2')
        $green = $rgbColor.Green.ToString('x2')
        $blue = $rgbColor.Blue.ToString('x2')

        return "dword:00$blue$green$red"
    }

    $output = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Console]
"ColorTable00"=$(ConvertTo-RegValue $ThemeColors.Black)
"ColorTable01"=$(ConvertTo-RegValue $ThemeColors.DarkBlue)
"ColorTable02"=$(ConvertTo-RegValue $ThemeColors.DarkGreen)
"ColorTable03"=$(ConvertTo-RegValue $ThemeColors.DarkCyan)
"ColorTable04"=$(ConvertTo-RegValue $ThemeColors.DarkRed)
"ColorTable05"=$(ConvertTo-RegValue $ThemeColors.DarkMagenta)
"ColorTable06"=$(ConvertTo-RegValue $ThemeColors.DarkYellow)
"ColorTable07"=$(ConvertTo-RegValue $ThemeColors.Gray)
"ColorTable08"=$(ConvertTo-RegValue $ThemeColors.DarkGray)
"ColorTable09"=$(ConvertTo-RegValue $ThemeColors.Blue)
"ColorTable10"=$(ConvertTo-RegValue $ThemeColors.Green)
"ColorTable11"=$(ConvertTo-RegValue $ThemeColors.Cyan)
"ColorTable12"=$(ConvertTo-RegValue $ThemeColors.Red)
"ColorTable13"=$(ConvertTo-RegValue $ThemeColors.Magenta)
"ColorTable14"=$(ConvertTo-RegValue $ThemeColors.Yellow)
"ColorTable15"=$(ConvertTo-RegValue $ThemeColors.White)
"ScreenColors"=dword:00000007
"@

    $output.Replace("`n", "`r`n") | Out-File $OutputFile -Encoding unicode
}

$baseDir = "$PSScriptRoot/.."

$themeColors = Get-ThemeColors "$baseDir/colors.json"

Write-WindowsTerminalTheme $themeColors "$baseDir/WindowsTerminal.json"

Write-WindowsConsoleRegFile $themeColors "$baseDir/WindowsConsole.reg"
