param(
    $ThemeColors,

    [String] $OutputFile
)

$script:ErrorActionPreference = 'Stop'

$readmeContents = Get-Content "$PSScriptRoot/README.template.md" -Raw -Encoding UTF8

function Get-ColorColumns($color) {
    return "``$color`` | ``$($color.Red) $($color.Green) $($color.Blue)``"
}

$colorPaletteCode = @"
Palette      | Hex       | RGB
---          | ---       | ---
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
