function Show-Box {
    [CmdletBinding()]
    param (
        [string]$Title,

        [switch]$CenterTitle,

        [int]$Width = $($Host.UI.RawUI.WindowSize.Width),

        [int]$Height = $($Host.UI.RawUI.WindowSize.Height),

        [RgbColor]$BackgroundColor = $Host.PrivateData.WarningBackgroundColor,

        [RgbColor]$ForegroundColor = $Host.PrivateData.WarningForegroundColor
    )

    end {
        # Write-Verbose "Make a box of Width: $Width with background $BackgroundColor"
        $Height = [Math]::Min($Host.UI.RawUI.WindowSize.Height, $Height)
        $Width  = [Math]::Min($Host.UI.RawUI.WindowSize.Width, $Width)
        # Subtract the border cell
        $Width -= 2
        $Height -= 2

        $b = $BackgroundColor.ToVtEscapeSequence($true)
        $f = $ForegroundColor.ToVtEscapeSequence()

        # Top Bar
        Write-Host -NoNewline (
            $b + $f + $BoxChars.TopLeftDouble + ($BoxChars.HorizontalDouble * $Width) + $BoxChars.TopRightDouble
        )

        # Title Bar
        $TitleBar = @(
            if ($Title) {
                foreach ($l in $Title -split "\r?\n") {
                    $TitleLength = ($l -replace $EscapeRegex).Length
                    [int]$TitlePadding = if (!$CenterTitle) {
                        2
                    } else {
                        (($Width - $TitleLength) / 2) - 1
                    }
                    Write-Host -NoNewline (
                        "`n" + $b + $f + $BoxChars.VerticalDouble + (" " * $Width) + $BoxChars.VerticalDouble +
                        "$([char]27)[$($TitlePadding)G" + $Fg:Clear + $l
                    )
                }
                Write-Host -NoNewline (
                    "`n" + $b + $f + $BoxChars.VerticalDoubleRightDouble + ($BoxChars.HorizontalDouble * $Width) + $BoxChars.VerticalDoubleLeftDouble
                )
            }
        )
        $TitleBar
        # Main box
        for ($i = 0; $i -lt ($Height - $TitleHeight); $i++) {
            Write-Host -NoNewline ("`n" + $b + $f + $BoxChars.VerticalDouble + (" " * $Width) + $BoxChars.VerticalDouble)
        }

        # Bottom Bar (plus reset)
        Write-Host -NoNewline (
            "`n" + $b + $f + $BoxChars.BottomLeftDouble + ($BoxChars.HorizontalDouble * $Width) + $BoxChars.BottomRightDouble +
            $Fg:Clear +
            $Bg:Clear
        )
    }
}
