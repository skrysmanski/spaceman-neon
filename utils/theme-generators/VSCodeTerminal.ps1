param(
    $ThemeColors,

    [String] $OutputFile
)

$script:ErrorActionPreference = 'Stop'

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
