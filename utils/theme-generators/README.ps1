param(
    $ThemeColors,

    [String] $OutputFile
)

$script:ErrorActionPreference = 'Stop'

$readmeContents = Get-Content "$PSScriptRoot/README.template.md" -Raw -Encoding UTF8

# See formula at: https://www.rapidtables.com/convert/color/rgb-to-hsl.html
# Calculation of $h based on: https://stackoverflow.com/a/9493060/614177
function Get-HSLValue($color) {
    $r = $color.Red
    $g = $color.Green
    $b = $color.Blue

    $r /= 255.0
    $g /= 255.0
    $b /= 255.0

    $max = [Math]::Max($r, [Math]::Max($g, $b))
    $min = [Math]::Min($r, [Math]::Min($g, $b))
    $l = ($max + $min) / 2

    if ($max -eq $min) {
        $h = 0
        $s = 0
    }
    else {
        $d = $max - $min

        $s = $d / (1 - [Math]::Abs(2 * $l - 1))

        if ($max -eq $r) {
            if ($g -lt $b) {
                $tmp = 6
            }
            else {
                $tmp = 0
            }
            $h = ($g - $b) / $d + $tmp
        }
        elseif ($max -eq $g) {
            $h = ($b - $r) / $d + 2
        }
        elseif ($max -eq $b) {
            $h = ($r - $g) / $d + 4
        }
        else {
            # One of the color components must be the max value
            throw 'This should not happen'
        }

        # Effective "60° x $h"
        $h /= 6
    }

    return [string]::Format([Globalization.CultureInfo]::InvariantCulture, "{0:0.}° {1:0.0}% {2:0.0}%", $h * 360, $s * 100, $l * 100)
}

function Get-ColorColumns($color) {
    $hex = "``$color``"
    $rgb = "``$($color.Red) $($color.Green) $($color.Blue)``"
    $hsl = "``$(Get-HSLValue($color))``"
    return "{0} | {1,-13} | {2}" -f $hex, $rgb, $hsl
}

$colorPaletteCode = @"
Palette      | Hex       | RGB           | HSL
---          | ---       | ---           | ---
Black        | $(Get-ColorColumns($ThemeColors.Black))
Red          | $(Get-ColorColumns($ThemeColors.Red))
Dark Red     | $(Get-ColorColumns($ThemeColors.DarkRed))
Green        | $(Get-ColorColumns($ThemeColors.Green))
Dark Green   | $(Get-ColorColumns($ThemeColors.DarkGreen))
Yellow       | $(Get-ColorColumns($ThemeColors.Yellow))
Dark Yellow  | $(Get-ColorColumns($ThemeColors.DarkYellow))
Blue         | $(Get-ColorColumns($ThemeColors.Blue))
Dark Blue    | $(Get-ColorColumns($ThemeColors.DarkBlue))
Magenta      | $(Get-ColorColumns($ThemeColors.Magenta))
Dark Magenta | $(Get-ColorColumns($ThemeColors.DarkMagenta))
Cyan         | $(Get-ColorColumns($ThemeColors.Cyan))
Dark Cyan    | $(Get-ColorColumns($ThemeColors.DarkCyan))
Gray         | $(Get-ColorColumns($ThemeColors.Gray))
Dark Gray    | $(Get-ColorColumns($ThemeColors.DarkGray))
White        | $(Get-ColorColumns($ThemeColors.White))
"@

$readmeContents = $readmeContents.Replace('{{ColorPalette}}', $colorPaletteCode)

$readmeContents | Out-File $OutputFile -Encoding utf8 -NoNewline
