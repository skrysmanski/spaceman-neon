param(
    $ThemeColors,

    [String] $OutputFile
)

$script:ErrorActionPreference = 'Stop'

function ConvertTo-Component([int] $Color) {
    $value = [double]$Color / 255.0
    # NOTE: Using "$value" formats $value as invariant culture.
    return "$value"
}

function Get-ColorEntry([string] $Key, $Color) {
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
