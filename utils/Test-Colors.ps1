#!/usr/bin/env pwsh

#
# Allows you to view the 16 default colors that every terminal should support
# - along with their name. Note that the color names are PowerShell names.
# On Linux/Unix terminals, the combo "dark red / red" is usually referred to as
# "red / bright red". But in the end they mean the same colors.
#

function Write-Color([System.ConsoleColor] $color) {
    # Label each color for when it's not readable (e.g. black on black background)
    $alignedLabel = '{0,-12} : ' -f $color
    Write-Host -ForegroundColor White -NoNewline $alignedLabel

    # Output color in its color
    Write-Host -ForegroundColor $color "$color"
}

Write-Host 'Default'
Write-Color Black
Write-Color DarkRed
Write-Color Red
Write-Color DarkGreen
Write-Color Green
Write-Color DarkYellow
Write-Color Yellow
Write-Color DarkBlue
Write-Color Blue
Write-Color DarkMagenta
Write-Color Magenta
Write-Color DarkCyan
Write-Color Cyan
Write-Color DarkGray
Write-Color Gray
Write-Color White
