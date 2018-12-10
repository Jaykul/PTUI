function Select-Interactive {
    [CmdletBinding()]
    param (
        [string]$Title,

        [Parameter(ValueFromPipeline)]
        [PSObject[]]$InputObject,

        [RgbColor]$BackgroundColor = $Host.PrivateData.WarningBackgroundColor,

        [RgbColor]$ForegroundColor = $Host.PrivateData.WarningForegroundColor,

        [switch]$Filterable
    )
    begin {
        [PSObject[]]$Collection = @()
    }
    process {
        [PSObject[]]$Collection += $InputObject
    }
    end {
        $null = $PSBoundParameters.Remove("InputObject")

        $Lines = $Collection | Format-Table -HideTableHeaders -GroupBy {} | Out-String -Stream
        $Lines = TrimLines $Lines

        $LineWidth = $Lines + @($Title) -replace $EscapeRegex | Measure-Object Length -Maximum | Select-Object -ExpandProperty Maximum
        $BorderWidth  = [Math]::Min($Host.UI.RawUI.WindowSize.Width, $LineWidth + 2)

        $LineHeight = $Lines.Count
        $BorderHeight = [Math]::Min($Host.UI.RawUI.WindowSize.Height, $LineHeight + 2)

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

        $MaxHeight = $Host.UI.RawUI.WindowSize.Height - 2 - $TitleHeight
        $Width = [Math]::Min($LineWidth, $Host.UI.RawUI.WindowSize.Width - 2)

        $Left = 2
        $Top = 2 + $TitleHeight


        $Filter = [Text.StringBuilder]::new()
        $Filtered = $Lines

        $Select = @()
        $Active = $Max    = $Filtered.Count - 1
        $Height = [Math]::Min($Filtered.Count, $MaxHeight)
        $Offset = [Math]::Max(0, $Active - $Height)

        $List = @{
            Top = $Top
            Left = $Left
            Width = $Width
            Height = $Height
            BackgroundColor = $BackgroundColor
        }

        Show-List @List -List $Filtered -Active $Active -SelectedItems $Select -Offset $Offset <# -Height $Height #>

        do {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
        } while ($Host.UI.RawUI.KeyAvailable)

        do {
            if (!$Host.UI.RawUI.KeyAvailable) {
                Start-Sleep -Milliseconds 10
                continue
            }
            $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            switch ($Key.VirtualKeyCode) {
                38 {# UP KEY
                    # Ignore the key up because we act on key down
                    # if (!$Key.KeyDown) { continue }

                    if ($Active -le 0) {
                        $Active = $Max
                        $Offset = $Filtered.Count - $Height
                    } else {
                        $Active = [Math]::Max(0, $Active - 1)
                        $Offset = [Math]::Min($Offset, $Active)
                    }

                    # DEBUG:
                    Write-Host (($SetXY -f ($Width - 35), 0) + ("{{UP}} Active: {0:d2} Offset: {1:d2} of {2:d3} ({3:d2})   " -f $Active, $Offset, $Max, $Filtered.Count) ) -NoNewline
                }
                40 {# DOWN KEY
                    # Ignore the key up because we act on key down
                    # if (!$Key.KeyDown) { continue }

                    if ($Active -ge $Max) {
                        $Active = 0
                        $Offset = 0
                    } else {
                        $Active = [Math]::Min($Max, $Active + 1)
                        $Offset = [Math]::Max($Offset, $Active - $Height + 1)
                    }
                    # DEBUG:
                    Write-Host (($SetXY -f ($Width - 35), 0) + ("{{DN}} Active: {0:d2} Offset: {1:d2} of {2:d3}" -f $Active, $Offset, $Filtered.Count) ) -NoNewline
                }
                # alpha numeric (and backspace)
                {$_ -eq 8 -or $_ -ge 48 -and $_ -le 90} {
                    # if (!$Key.KeyDown) { continue }

                    # backspace
                    if ($_ -eq 8) {
                        # Ctrl backspace
                        if ($key.ControlKeyState -match "RightCtrlPressed|LeftCtrlPressed") {
                            while ($Filter.Length -and $Filter[-1] -notmatch "\s") {
                                $null = $Filter.Remove($Filter.Length - 1, 1)
                            }
                        }
                        if ($Filter.Length) {
                            $null = $Filter.Remove($Filter.Length - 1, 1)
                        }
                    } else {
                        $null = $Filter.Append($Key.Character)
                    }

                    if ($Filterable) {
                        # Filter and redraw
                        if ($Filter.Length) {
                            $Filtered = $Lines -match "\b$($Filter.ToString() -split " " -join '.*\b')"
                        } else {
                            $Filtered = $Lines
                        }
                        $Select = @()
                        $Active = $Filtered.Count - 1
                        $Offset = [Math]::Max(0, $Active - $Height + 1)
                    } else {
                        # select
                        $Selected = $Lines -match "\b$($Filter.ToString() -split " " -join '.*\b')"
                        $Active = $Selected | Select-Object -Expand Index -First 1
                        $Offset = [Math]::Max(0, $Selected[-1].Index - $Height + 1)
                    }

                    Write-Host (
                        ($SetXY -f 5, ($Height + 2)) +
                        $Filter.ToString() +
                        $ForegroundColor.ToVtEscapeSequence() +
                        ($BoxChars.HorizontalDouble * ($Width - 5 - $Filter.Length)) +
                        $Fg:Clear
                    ) -NoNewline
                }
                32 { # Space: select
                    # if (!$Key.KeyDown) { continue }

                    if ($Filter.Length -gt 0) {
                        $null = $Filter.Append($Key.Character)
                    }

                    if ($Active -in $Select) {
                        $Select = @($Select -ne $Active)
                    } else {
                        $Select += $Active
                    }
                }
                13 {
                    Write-Host "$Main$Show" -NoNewline
                    if ($Select.Count -eq 0) {
                        $Select = @($Active)
                    }
                    $Collection[$Filtered[$Select].Index]
                    return
                }
            }

            $Max    = $Filtered.Count - 1
            $Height = [Math]::Min($Filtered.Count, $MaxHeight)

            Show-List @List -List $Filtered -SelectedItems $Select -Offset $Offset <# -Height $Height #> -Active $Active
        } while ($true)
    }
}