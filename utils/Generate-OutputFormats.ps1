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

function Write-WindowsTerminalTheme([TerminalColors] $ThemeColors, [String] $OutputFile) {
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

function Write-WindowsConsoleRegFile([TerminalColors] $ThemeColors, [String] $OutputFile) {
    function ConvertTo-RegValue([Color] $Color) {

        $red = $Color.Red.ToString('x2')
        $green = $Color.Green.ToString('x2')
        $blue = $Color.Blue.ToString('x2')

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

function Write-ItermColorsFile([TerminalColors] $ThemeColors, [String] $OutputFile) {
    function ConvertTo-Component([int] $Color) {
        $value = [double]$Color / 255.0
        # NOTE: Using "$value" formats $value as invariant culture.
        return "$value"
    }

    function Get-ColorEntry([string] $Key, [Color] $Color) {
        return @"
    <key>$Key</key>
    <dict>
        <key>Alpha Component</key>
        <real>1</real>
        <key>Blue Component</key>
        <real>$(ConvertTo-Component $Color.Blue)</real>
        <key>Color Space</key>
        <string>sRGB</string>
        <key>Green Component</key>
        <real>$(ConvertTo-Component $Color.Green)</real>
        <key>Red Component</key>
        <real>$(ConvertTo-Component $Color.Red)</real>
    </dict>
"@
    }

    $output = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
$(Get-ColorEntry 'Ansi 0 Color' $ThemeColors.Black)
$(Get-ColorEntry 'Ansi 1 Color' $ThemeColors.DarkRed)
$(Get-ColorEntry 'Ansi 10 Color' $ThemeColors.Green)
$(Get-ColorEntry 'Ansi 11 Color' $ThemeColors.Yellow)
$(Get-ColorEntry 'Ansi 12 Color' $ThemeColors.Blue)
$(Get-ColorEntry 'Ansi 13 Color' $ThemeColors.Magenta)
$(Get-ColorEntry 'Ansi 14 Color' $ThemeColors.Cyan)
$(Get-ColorEntry 'Ansi 15 Color' $ThemeColors.White)
$(Get-ColorEntry 'Ansi 2 Color' $ThemeColors.DarkGreen)
$(Get-ColorEntry 'Ansi 3 Color' $ThemeColors.DarkYellow)
$(Get-ColorEntry 'Ansi 4 Color' $ThemeColors.DarkBlue)
$(Get-ColorEntry 'Ansi 5 Color' $ThemeColors.DarkMagenta)
$(Get-ColorEntry 'Ansi 6 Color' $ThemeColors.DarkCyan)
$(Get-ColorEntry 'Ansi 7 Color' $ThemeColors.Gray)
$(Get-ColorEntry 'Ansi 8 Color' $ThemeColors.DarkGray)
$(Get-ColorEntry 'Ansi 9 Color' $ThemeColors.Red)
$(Get-ColorEntry 'Background Color' $ThemeColors.Black)
    <key>Badge Color</key>
    <dict>
        <key>Alpha Component</key>
        <real>0.5</real>
        <key>Blue Component</key>
        <real>0.0</real>
        <key>Color Space</key>
        <string>sRGB</string>
        <key>Green Component</key>
        <real>0.1491314172744751</real>
        <key>Red Component</key>
        <real>1</real>
    </dict>
    <key>Bold Color</key>
    <dict>
        <key>Alpha Component</key>
        <real>1</real>
        <key>Blue Component</key>
        <real>0.968353271484375</real>
        <key>Color Space</key>
        <string>sRGB</string>
        <key>Green Component</key>
        <real>0.90144157409667969</real>
        <key>Red Component</key>
        <real>0.71185845136642456</real>
    </dict>
    <key>Cursor Color</key>
    <dict>
        <key>Alpha Component</key>
        <real>1</real>
        <key>Blue Component</key>
        <real>0.98823529481887817</real>
        <key>Color Space</key>
        <string>sRGB</string>
        <key>Green Component</key>
        <real>0.98823529481887817</real>
        <key>Red Component</key>
        <real>0.9843137264251709</real>
    </dict>
    <key>Cursor Guide Color</key>
    <dict>
        <key>Alpha Component</key>
        <real>0.25</real>
        <key>Blue Component</key>
        <real>1</real>
        <key>Color Space</key>
        <string>sRGB</string>
        <key>Green Component</key>
        <real>0.9268307089805603</real>
        <key>Red Component</key>
        <real>0.70213186740875244</real>
    </dict>
    <key>Cursor Text Color</key>
    <dict>
        <key>Alpha Component</key>
        <real>1</real>
        <key>Blue Component</key>
        <real>0.11473541706800461</real>
        <key>Color Space</key>
        <string>sRGB</string>
        <key>Green Component</key>
        <real>0.15114313364028931</real>
        <key>Red Component</key>
        <real>1</real>
    </dict>
$(Get-ColorEntry 'Foreground Color' $ThemeColors.Gray)
$(Get-ColorEntry 'Link Color' $ThemeColors.Blue)
    <key>Selected Text Color</key>
    <dict>
        <key>Alpha Component</key>
        <real>1</real>
        <key>Blue Component</key>
        <real>0.19215686619281769</real>
        <key>Color Space</key>
        <string>sRGB</string>
        <key>Green Component</key>
        <real>0.10980392247438431</real>
        <key>Red Component</key>
        <real>0.11764705926179886</real>
    </dict>
    <key>Selection Color</key>
    <dict>
        <key>Alpha Component</key>
        <real>1</real>
        <key>Blue Component</key>
        <real>0.90588235855102539</real>
        <key>Color Space</key>
        <string>sRGB</string>
        <key>Green Component</key>
        <real>0.88235294818878174</real>
        <key>Red Component</key>
        <real>0.79607844352722168</real>
    </dict>
    <key>Tab Color</key>
    <dict>
        <key>Alpha Component</key>
        <real>1</real>
        <key>Blue Component</key>
        <real>0.32156860828399658</real>
        <key>Color Space</key>
        <string>sRGB</string>
        <key>Green Component</key>
        <real>0.25882357358932495</real>
        <key>Red Component</key>
        <real>0.23137256503105164</real>
    </dict>
</dict>
</plist>

"@

    # NOTE: -NewLine prevent Out-File from appending a system-dependent newline at the end of the file.
    $output.Replace('    ', "`t") | Out-File $OutputFile -Encoding ascii -NoNewline
}

function Write-VSCodeTerminalTheme([TerminalColors] $ThemeColors, [String] $OutputFile) {
    # NOTE: We use a string here rather than an object (in conjunction with ConvertTo-Json) because
    #   with an object we can't control the order of the properties (neither can we add comments)
    #   to the output.
    $output = @"
    // put in your user settings
    "workbench.colorCustomizations": {
        "terminal.background":"$($ThemeColors.Black)",
        "terminal.foreground":"$($ThemeColors.Gray)",
        "terminalCursor.background":"$($ThemeColors.Gray)",
        "terminalCursor.foreground":"$($ThemeColors.Gray)",
        "terminal.ansiBlack":"$($ThemeColors.Black)",
        "terminal.ansiBlue":"$($ThemeColors.DarkBlue)",
        "terminal.ansiBrightBlack":"$($ThemeColors.DarkGray)",
        "terminal.ansiBrightBlue":"$($ThemeColors.Blue)",
        "terminal.ansiBrightCyan":"$($ThemeColors.Cyan)",
        "terminal.ansiBrightGreen":"$($ThemeColors.Green)",
        "terminal.ansiBrightMagenta":"$($ThemeColors.Magenta)",
        "terminal.ansiBrightRed":"$($ThemeColors.Red)",
        "terminal.ansiBrightWhite":"$($ThemeColors.White)",
        "terminal.ansiBrightYellow":"$($ThemeColors.Yellow)",
        "terminal.ansiCyan":"$($ThemeColors.DarkCyan)",
        "terminal.ansiGreen":"$($ThemeColors.DarkGreen)",
        "terminal.ansiMagenta":"$($ThemeColors.DarkMagenta)",
        "terminal.ansiRed":"$($ThemeColors.DarkRed)",
        "terminal.ansiWhite":"$($ThemeColors.Gray)",
        "terminal.ansiYellow":"$($ThemeColors.DarkYellow)"
    }

"@

    # NOTE: -NewLine prevent Out-File from appending a system-dependent newline at the end of the file.
    $output | Out-File $OutputFile -Encoding utf8 -NoNewline
}

$baseDir = "$PSScriptRoot/.."
$outDir = "$baseDir/themes"

$themeColors = Get-ThemeColors "$baseDir/colors.json"

Write-WindowsTerminalTheme $themeColors "$outDir/WindowsTerminal.json"

Write-WindowsConsoleRegFile $themeColors "$outDir/WindowsConsole.reg"

Write-ItermColorsFile $themeColors "$outDir/SpacemanNeon.itermcolors"

Write-VSCodeTerminalTheme $themeColors "$outDir/VSCodeTerminal.json"
