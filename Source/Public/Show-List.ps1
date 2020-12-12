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
        $Bg = if ($i -eq $ActiveIndex) {
            $HighlightColor.ToVtEscapeSequence($true)
        } elseif ($i -in $SelectedItems) {
            $SelectionColor.ToVtEscapeSequence($true)
        } else {
            $BackgroundColor.ToVtEscapeSequence($true)
        }
        $item = $List[$i].TrimEnd()
        $plainItem = $item -replace $EscapeRegex

        $item = $item.PadRight($Width)
        if ($plainItem.Length -gt $Width) {
            $trimable = $plainItem.Substring($Width)
            $item = $item -replace ([regex]::Escape($trimable))
            $plainItem = $item -replace $EscapeRegex
        }

        Write-Host (($SetXY -f $Left, $Line++) + $Bg + $item + $Bg:Clear) -NoNewline
    }

    # if they filter, we're going to need to blank the rest of the lines
    $item = " " * $Width
    while ($Line -le $Height + 1) {
        Write-Host (($SetXY -f $Left, $Line++) + $BackgroundColor.ToVtEscapeSequence($true) + $item + $Bg:Clear) -NoNewline
    }
}