param(
    $ThemeColors,

    [String] $OutputFile
)

$script:ErrorActionPreference = 'Stop'

function ConvertTo-RegValue($Color) {
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

[IO.File]::WriteAllText($OutputFile, $output.Replace("`n", "`r`n"), [System.Text.Encoding]::Unicode)
