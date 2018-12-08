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
        $Lines  = TrimLines $Lines

        $LineWidth = $Lines + @($Title) -replace $EscapeRegex | Measure-Object Length -Maximum | Select-Object -ExpandProperty Maximum
        $BorderWidth  = [Math]::Min($Host.UI.RawUI.WindowSize.Width, $LineWidth + $Padding.Left + $Padding.Right + 2)

        $LineHeight = $Lines.Count
        $BorderHeight = [Math]::Min($Host.UI.RawUI.WindowSize.Height, $LineHeight + $Padding.Top + $Padding.Bottom + 2)

        # Use alternate screen buffer, and
        Write-Host "$Alt$Hide" -NoNewline
        # Make sure the title doesn't scroll off
        # Write-Host ("$Freeze" -f $TitleHeight, ($BorderHeight - 1)) -NoNewline

        Show-Box -Width $BorderWidth -Height $BorderHeight -Title $Title -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor
        # Write-Host "Press Up or Down keys and ENTER to select... $Up" -ForegroundColor $ForegroundColor -NoNewline

        $TitleHeight = if($Title) {
            1 + ($Title -split "\r?\n").Count
        } else {
            0
        }

        $Width = [Math]::Min($LineWidth, $Host.UI.RawUI.WindowSize.Width - 2 - $Padding.Left - $Padding.Right)
        $Height = [Math]::Min($LineHeight, $Host.UI.RawUI.WindowSize.Height - 2 - $TitleHeight - $Padding.Top - $Padding.Bottom)

        $Left = 2 + $Padding.Left
        $Top = 2 + $Padding.Top + $TitleHeight

        $List = @{
            Top = $Top
            Left = $Left
            Width = $Width
            Height = $Height
            List = $Lines
            BackgroundColor = $BackgroundColor
        }

        $Selected = @()
        $Active = $Lines.Count - 1
        $Max = $Lines.Count - 1
        $Offset = [Math]::Max(0, $Active - $Height)

        Show-List @List -SelectedItems $Selected -Offset $Offset

        do {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
        } while ($Host.UI.RawUI.KeyAvailable)

        do {
            if (!$Host.UI.RawUI.KeyAvailable) {
                Start-Sleep -Milliseconds 10
                continue
            }
            $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
            switch ($Key.VirtualKeyCode) {
                38 {# UP KEY
                    # Ignore the key up because we act on key down
                    if (!$Key.KeyDown) { continue }

                    if ($Active -le 0) {
                        $Active = $Lines.Count
                        $Offset = $Lines.Count - $Height
                    }

                    $Active = [Math]::Max(0, $Active - 1)
                    $Offset = [Math]::Min($Offset, $Active)
                }
                40 {# DOWN KEY
                    # Ignore the key up because we act on key down
                    if (!$Key.KeyDown) { continue }

                    if ($Active -ge $Max) {
                        $Active = -1
                        $Offset = 0
                    }
                    $Active = [Math]::Min($Max, $Active + 1)
                    $Offset = [Math]::Max($Offset, $Active - $Height)
                }
                32 { # Space: select
                    if(!$Key.KeyDown -or $Active -gt $Max) { continue }

                    if ($Active -in $Selected) {
                        $Selected = @($Selected -ne $Active)
                    } else {
                        $Selected += $Active
                    }
                }
                13 {
                    Write-Host "$Main$Show" -NoNewline
                    if($Selected.Count -eq 0) {
                        $Selected = @($Active)
                    }
                    $Collection[$Selected]
                    return
                }
            }
            Show-List @List -SelectedItems $Selected -Active $Active -Offset $Offset
        } while ($true)
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