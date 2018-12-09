function Show-List {
    [CmdletBinding()]
    param(
        [int]$Top = 1,
        [int]$Left = 1,
        [int]$Height = $Host.UI.RawUI.WindowSize.Height,
        [int]$Width = $Host.UI.RawUI.WindowSize.Width,
        [string[]]$List,
        [RgbColor]$BackgroundColor = "Black",
        [RgbColor]$HighlightColor  = "Gray",
        [RgbColor]$SelectionColor   = "DarkGray",
        [int[]]$SelectedItems,
        [int]$ActiveIndex = $($List.Count - 1),
        [int]$Offset = $([Math]::Max(0, $ActiveIndex - $Height))
    )
    $ActualHeight = [Math]::Min(($Host.UI.RawUI.WindowSize.Height - ($Top - 1)), $Height)
    $ActualHeight = [Math]::Min($ActualHeight, $List.Count)
    $Width  = [Math]::Min(($Host.UI.RawUI.WindowSize.Width - ($Left - 1)), $Width)

    # Fix the offset
    if ($ActiveIndex -lt $Offset) {
        $Offset = $ActiveIndex
    } elseif ($ActiveIndex -gt ($Offset + $ActualHeight)) {
        $Offset = $ActiveIndex - $ActualHeight
    }

    $Last = [Math]::Min($List.Count, $Offset + $ActualHeight)

    # Write out all the lines
    $Line   = $Top
    for ($i = $Offset; $i -lt $Last; $i++) {
        $Bg = if ($i -in $SelectedItems) {
            $SelectionColor.ToVtEscapeSequence($true)
        } elseif ($i -eq $ActiveIndex) {
            $HighlightColor.ToVtEscapeSequence($true)
        } else {
            $BackgroundColor.ToVtEscapeSequence($true)
        }
        $item = $List[$i].TrimEnd().PadRight($Width).Substring(0,$Width)
        Write-Host (($SetXY -f $Left, $Line++) + $Bg + $item + $Bg:Clear) -NoNewline
    }

    # if they filter, we're going to need to blank the rest of the lines
    while ($Line -lt $Height) {
        $item = " " * $Width
        Write-Host (($SetXY -f $Left, $Line++) + $HighlightColor.ToVtEscapeSequence($true) + $item + $Bg:Clear) -NoNewline
    }

}