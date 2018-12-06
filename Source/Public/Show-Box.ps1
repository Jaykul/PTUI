function Show-Box {
    [CmdletBinding()]
    param (
        [string]$Title,

        [int]$Width = $Host.UI.RawUI.WindowSize.Width,

        [int]$Height = $($Host.UI.RawUI.WindowSize.Height - ($Title -split "\r?\n").Count),

        [RgbColor]$BackgroundColor = $Host.PrivateData.WarningBackgroundColor,

        [RgbColor]$ForegroundColor = $Host.PrivateData.WarningForegroundColor
    )

    end {
        Write-Verbose "Make a box of Width: $Width with background $BackgroundColor"

        $b = $BackgroundColor.ToVtEscapeSequence($true)
        $f = $ForegroundColor.ToVtEscapeSequence()

        # Top Bar
        $b + $f + $BoxChars.TopLeftDouble + ($BoxChars.HorizontalDouble * $Width) + $BoxChars.TopRightDouble

        # Title Bar
        $TitleBar = @(
            if ($Title) {
                foreach ($l in $Title -split "\r?\n") {
                    $TitleLength = ($l -replace $EscapeRegex).Length
                    [int]$TitlePadding = if ($l -match "^\s+") {
                        1
                    } else {
                        (($Width - $TitleLength) / 2) - 1
                    }
                    $b + $f + $BoxChars.VerticalDouble + (" " * $Width) + $BoxChars.VerticalDouble +
                    "$([char]27)[$($TitlePadding)G" + $Fg:Clear + $l
                }
                $b + $f + $BoxChars.VerticalDoubleRightDouble + ($BoxChars.HorizontalDouble * $Width) + $BoxChars.VerticalDoubleLeftDouble
            }
        )
        $TitleBar

        # Main box
        for ($i = 0; $i -lt $Height; $i++) {
            $b + $f + $BoxChars.VerticalDouble + (" " * $Width) + $BoxChars.VerticalDouble
        }

        # Bottom Bar (plus reset)
        $b + $f + $BoxChars.BottomLeftDouble + ($BoxChars.HorizontalDouble * $Width) + $BoxChars.BottomRightDouble +
        $Fg:Clear +
        $Bg:Clear
    }
}
