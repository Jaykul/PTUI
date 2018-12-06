function Select-Interactive {
    [CmdletBinding()]
    param (
        [string]$Title,

        [Parameter(ValueFromPipeline)]
        [PSObject[]]$InputObject,

        [Padding]$Padding = @(0,0,0,0),

        [RgbColor]$BackgroundColor = $Host.PrivateData.WarningBackgroundColor,

        [RgbColor]$ForegroundColor = $Host.PrivateData.WarningForegroundColor
    )
    begin {
        [PSObject[]]$Collection = @()
    }
    process {
        [PSObject[]]$Collection += $InputObject
    }
    end {
        $null = $PSBoundParameters.Remove("InputObject")

        [string[]]$Lines = $Collection | Format-Table -HideTableHeaders -GroupBy {} | Out-String -Stream
        $Lines = TrimLines $Lines

        $Width = $Lines + @($Title) -replace $EscapeRegex | Measure-Object Length -Maximum | Select-Object -ExpandProperty Maximum
        $Width += $Padding.Left + $Padding.Right

        $Height = $Lines.Count + $Padding.Top + $Padding.Bottom
        $Height = [Math]::Min($Height, $Host.Ui.RawUI.WindowSize.Height)
        $Top = 2
        if($Title) {
            $Top += 1 + ($Title -split "\r?\n").Count
        }
        $Left = 2 + $Padding.Left

        # Use alternate screen buffer, and
        # Make sure the title doesn't scroll off
        # DEBUG: Write-Host "$($SetXY -f 4, 55)Show: $Width x $Height at $Left, $Top"

        Write-Host "$Alt$Hide" -NoNewline
        # Write-Host ("$Freeze" -f $TitleHeight, ($Height - 1)) -NoNewline

        Show-Box -Width $Width -Height $Height -Title $Title -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor
        Write-Host "Press Up or Down keys and ENTER to select... $Up" -ForegroundColor $ForegroundColor -NoNewline

        $Selected = Show-List -Top $Top -Left $Left -List $Lines -BackgroundColor $BackgroundColor

        Write-Host "$Main$Show" -NoNewline

        $Collection[$Selected]
    }
}

<#
function New-Box {
    [CmdletBinding()]
    param (
        # Width of the box
        [ValidateRange(4,1024)]
        [Parameter()]
        [int]$Width = $Host.UI.RawUI.WindowSize.Width,

        # Width of the box
        [ValidateRange(4, 1024)]
        [Parameter()]
        [int]$Height = $($Host.UI.RawUI.WindowSize.Height - 6),

        [RgbColor]$BackgroundColor = $Host.PrivateData.WarningBackgroundColor,

        [RgbColor]$ForegroundColor = $Host.PrivateData.WarningForegroundColor
    )
    begin {
    }
    process {
    }
    end {
        $BackgroundColor.ToVtEscapeSequence()
        $ForegroundColor.ToVtEscapeSequence()
        $BoxChars.TopLeftDouble + ($BoxChars.HorizontalDouble * ($Width - 2)) + $BoxChars.TopRightDouble
        ($BoxChars.VerticalDouble + (" " * ($Width - 2)) + $BoxChars.VerticalDouble) * $Height
        $BoxChars.BottomLeftDouble + ($BoxChars.HorizontalDouble * ($Width - 2)) + $BoxChars.BottomRightDouble
        $Fg:Clear
        $Bg:Clear
    }
}
#>