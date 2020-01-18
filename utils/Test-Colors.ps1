#!/usr/bin/env pwsh

#
# Allows you to view the 16 default colors that every terminal should support
# - along with their name. Note that the color names are PowerShell names.
# On Linux/Unix terminals, the combo "dark red / red" is usually referred to as
# "red / bright red". But in the end they mean the same colors.
#

function Write-Color([System.ConsoleColor] $Color, [switch] $NoNewLine) {
    # Output color in its color
    Write-Host -ForegroundColor $Color -NoNewline:$NoNewLine "$Color"
}

function Write-ColorAndLabel([System.ConsoleColor] $Color) {
    # Label each color for when it's not readable (e.g. black on black background)
    $alignedLabel = '{0,-12} : ' -f $Color
    Write-Host -ForegroundColor White -NoNewline $alignedLabel

    # Output color in its color
    Write-Color $Color
}

#
# Print colors
#
Write-Host 'Default'
Write-ColorAndLabel Black
Write-ColorAndLabel DarkRed
Write-ColorAndLabel Red
Write-ColorAndLabel DarkGreen
Write-ColorAndLabel Green
Write-ColorAndLabel DarkYellow
Write-ColorAndLabel Yellow
Write-ColorAndLabel DarkBlue
Write-ColorAndLabel Blue
Write-ColorAndLabel DarkMagenta
Write-ColorAndLabel Magenta
Write-ColorAndLabel DarkCyan
Write-ColorAndLabel Cyan
Write-ColorAndLabel DarkGray
Write-ColorAndLabel Gray
Write-ColorAndLabel White

#
# Print potentially problematic color combos. Let's us view the "contrast"
# differences between the individual colors.
#
Write-Host

Write-Color Blue -NoNewLine
Write-Color Cyan -NoNewLine
Write-Color Gray -NoNewLine
Write-Host
Write-Host

Write-Color Cyan -NoNewLine
Write-Color Gray -NoNewLine
Write-Color White -NoNewLine
Write-Host
Write-Host

Write-Color DarkRed -NoNewLine
Write-Color Magenta -NoNewLine
Write-Color Red -NoNewLine
Write-Host
Write-Host
