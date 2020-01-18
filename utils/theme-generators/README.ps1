param(
    $ThemeColors,

    [String] $OutputFile,

    [String] $RelativeColorBoxesFolder
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

function Write-ColorBox([string] $OutputFile, $Color, [int] $Size = 20) {
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size)

    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    # Border (primarily required for "white")
    $graphics.Clear([System.Drawing.Color]::Black)
    # The color
    $theColor = [System.Drawing.Color]::FromArgb($Color.Red, $Color.Green, $Color.Blue)
    $theBrush = [System.Drawing.SolidBrush]::new($theColor)
    $graphics.FillRectangle($theBrush, 1, 1, $Size - 2, $Size - 2)

    $graphics.Dispose()

    $bitmap.Save($OutputFile, [System.Drawing.Imaging.ImageFormat]::Png)

    $bitmap.Dispose()
}

function Get-ColorColumns($Color, [string] $ColorFileName) {
    $hex = "``$Color``"
    $rgb = "``$($Color.Red) $($Color.Green) $($Color.Blue)``"
    $hsl = "``$(Get-HSLValue($Color))``"

    $relativeColorBoxPath = "$RelativeColorBoxesFolder/$ColorFileName.png"
    $absColorBoxPath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($OutputFile), $relativeColorBoxPath)
    Write-ColorBox $absColorBoxPath $Color
    $colorBoxCode = "![$ColorFileName]($relativeColorBoxPath)"

    return "{0} | {1,-13} | {2,-20} | {3}" -f $hex, $rgb, $hsl, $colorBoxCode
}

$colorPaletteCode = @"
Name         | Hex       | RGB           | HSL                  | Color
---          | ---       | ---           | ---                  | ---
Black        | $(Get-ColorColumns $ThemeColors.Black 'black')
Red          | $(Get-ColorColumns $ThemeColors.Red 'red')
Dark Red     | $(Get-ColorColumns $ThemeColors.DarkRed 'dark-red')
Green        | $(Get-ColorColumns $ThemeColors.Green 'green')
Dark Green   | $(Get-ColorColumns $ThemeColors.DarkGreen 'dark-green')
Yellow       | $(Get-ColorColumns $ThemeColors.Yellow 'yellow')
Dark Yellow  | $(Get-ColorColumns $ThemeColors.DarkYellow 'dark-yellow')
Blue         | $(Get-ColorColumns $ThemeColors.Blue 'blue')
Dark Blue    | $(Get-ColorColumns $ThemeColors.DarkBlue 'dark-blue')
Magenta      | $(Get-ColorColumns $ThemeColors.Magenta 'magenta')
Dark Magenta | $(Get-ColorColumns $ThemeColors.DarkMagenta 'dark-magenta')
Cyan         | $(Get-ColorColumns $ThemeColors.Cyan 'cyan')
Dark Cyan    | $(Get-ColorColumns $ThemeColors.DarkCyan 'dark-cyan')
Gray         | $(Get-ColorColumns $ThemeColors.Gray 'gray')
Dark Gray    | $(Get-ColorColumns $ThemeColors.DarkGray 'dark-gray')
White        | $(Get-ColorColumns $ThemeColors.White 'white')
"@

$readmeContents = $readmeContents.Replace('{{ColorPalette}}', $colorPaletteCode)

$readmeContents | Out-File $OutputFile -Encoding utf8 -NoNewline
