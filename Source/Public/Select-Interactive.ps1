function Select-Interactive {
    <#
        .SYNOPSIS
            Shows Format-Table output in an alternate buffer in the console to allow filtering & selection
        .DESCRIPTION
            Select-Interactive calls Format-Table and displays the output in an alternate buffer.
            In that buffer you can type to select (or filter, with the -Filterable switch) and use the up and down arrows to select items.
            To select multiple items, press space to toggle selection -- otherwise, just hit Enter to return the highlighted item.

            Supports scrolling (or filtering) when there are too many items for one screen.
    #>
    [CmdletBinding()]
    param (
        # A title to show above the items (defaults to no the table header)
        [string]$Title,

        # The items to select from
        [Parameter(ValueFromPipeline)]
        [PSObject[]]$InputObject,

        # An alternate color for the background of the alternate buffer
        [RgbColor]$BackgroundColor = $Host.PrivateData.WarningBackgroundColor,

        # The color of the border (defaults to the Warning foreground color)
        [RgbColor]$BorderColor = $Host.PrivateData.WarningForegroundColor,

        # If set, typing text _filters_ the list rather than moving the selection
        [switch]$Filterable
    )
    begin {
        [PSObject[]]$Collection = @()
    }
    process {
        [PSObject[]]$Collection += $InputObject
    }
    end {
        $DebugPreference = "SilentlyContinue"
        $null = $PSBoundParameters.Remove("InputObject")

        $Header, $Lines = $Lines = $Collection | Format-Table -GroupBy {} | Out-String -Stream | TrimLines
        if (!$Title) {
            $Title = $Header
        }

        $TitleHeight = if ($Title) {
            1 + ($Title -split "\r?\n").Count
        } else {
            0
        }

        $LineWidth = $Lines + @($Title) -replace $EscapeRegex | Measure-Object Length -Maximum | Select-Object -ExpandProperty Maximum
        $BorderWidth  = [Math]::Min($Host.UI.RawUI.WindowSize.Width, $LineWidth + 2)

        $LineHeight = $Lines.Count
        $BorderHeight = [Math]::Min($Host.UI.RawUI.WindowSize.Height, $LineHeight + 2 + $TitleHeight)

        # Use alternate screen buffer, and hide the text cursor
        Write-Host "$Alt$Hide" -NoNewline

        Show-Box -Width $BorderWidth -Height $BorderHeight -Title $Title -BackgroundColor $BackgroundColor -ForegroundColor $BorderColor
        # Make sure the top and bottom borders don't scroll
        Write-Host ("$Freeze" -f ($TitleHeight + 1), ($BorderHeight - 1)) -NoNewline

        # Write-Host "Press Up or Down keys and ENTER to select... $Up" -ForegroundColor $BorderColor -NoNewline

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

        Show-List @List -List $Filtered -Active $Active -SelectedItems $Select -Offset $Offset

        # # This doesn't seem necessary any more, but it was to make sure no keystrokes from before affect this
        # do {
        #     $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
        # } while ($Host.UI.RawUI.KeyAvailable)

        do {
            if (!$Host.UI.RawUI.KeyAvailable) {
                Start-Sleep -Milliseconds 10
                continue
            }
            $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            switch ($Key.VirtualKeyCode) {
                38 {# UP ARROW KEY
                    if (($Key.ControlKeyState -band "ShiftPressed") -eq "ShiftPressed") {
                        if ($Active -notin $Select) {
                            $Select += $Active
                        }
                    }
                    if ($Active -le 0) {
                        $Active = $Max
                        $Offset = $Filtered.Count - $Height
                    } else {
                        $Active = [Math]::Max(0, $Active - 1)
                        $Offset = [Math]::Min($Offset, $Active)
                    }
                    if (($Key.ControlKeyState -band "ShiftPressed") -eq "ShiftPressed") {
                        if ($Active -notin $Select) {
                            $Select += $Active
                        }
                    }
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host (($SetXY -f ($Width - 35), 0) + ("{{UP}} Active: {0:d2} Offset: {1:d2} of {2:d3} ({3:d2})   " -f $Active, $Offset, $Max, $Filtered.Count) ) -NoNewline
                    }
                }
                40 {# DOWN ARROW KEY
                    if (($Key.ControlKeyState -band "ShiftPressed") -eq "ShiftPressed") {
                        if ($Active -notin $Select) {
                            $Select += $Active
                        }
                    }
                    if ($Active -ge $Max) {
                        $Active = 0
                        $Offset = 0
                    } else {
                        $Active = [Math]::Min($Max, $Active + 1)
                        $Offset = [Math]::Max($Offset, $Active - $Height + 1)
                    }
                    if (($Key.ControlKeyState -band "ShiftPressed") -eq "ShiftPressed") {
                        if ($Active -notin $Select) {
                            $Select += $Active
                        }
                    }
                    if ($DebugPreference -ne "SilentlyContinue") {
                        Write-Host (($SetXY -f ($Width - 35), 0) + ("{{DN}} Active: {0:d2} Offset: {1:d2} of {2:d3}" -f $Active, $Offset, $Filtered.Count) ) -NoNewline
                    }
                }
                # alpha numeric keys (and backspace)
                # Should probably allow punctuation, but doesn't yet
                {$_ -eq 8 -or $_ -ge 48 -and $_ -le 90} {
                    # backspace
                    if ($_ -eq 8) {
                        # Ctrl backspace
                        if ($Key.ControlKeyState -match "RightCtrlPressed|LeftCtrlPressed") {
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
                            $Filtered = $Lines | Where-Object { $_ -replace $EscapeRegex -match "\b$($Filter.ToString() -split " " -join '.*\b')" }
                        } else {
                            $Filtered = $Lines
                        }
                        $Select = @()
                        $Active = $Filtered.Count - 1
                        $Offset = [Math]::Max(0, $Active - $Height + 1)
                    } else {
                        # Scroll and highlight
                        $Selected = $Lines | Where-Object { $_  -replace $EscapeRegex -match "\b$($Filter.ToString() -split " " -join '.*\b')" }
                        $Active = $Selected | Select-Object -Expand Index -First 1
                        $Offset = [Math]::Max(0, $Selected[-1].Index - $Height + 1)
                    }

                    Write-Host (
                        ($SetXY -f 4, $Host.UI.RawUI.WindowSize.Height) +
                        $Filter.ToString() +
                        $BorderColor.ToVtEscapeSequence() +
                        ($BoxChars.HorizontalDouble * ($Width - 4 - $Filter.Length)) +
                        $Fg:Clear
                    ) -NoNewline
                }
                32 { # Space: toggle selection
                    if ($Filter.Length -gt 0) {
                        $null = $Filter.Append($Key.Character)
                    }

                    if ($Active -in $Select) {
                        $Select = @($Select -ne $Active)
                    } else {
                        $Select += $Active
                    }
                }
                13 { # Enter: return results
                    Write-Host "$Main$Show" -NoNewline
                    if ($Select.Count -eq 0) {
                        $Select = @($Active)
                    }
                    $Collection[$Filtered[$Select].Index]
                    return
                }
                27 { # ESC: return nothing
                    Write-Host "$Main$Show" -NoNewline
                    $Select = @()
                    return
                }
            }
            $Max    = $Filtered.Count - 1
            $Height = [Math]::Min($Filtered.Count, $MaxHeight)

            Show-List @List -List $Filtered -SelectedItems $Select -Offset $Offset -Active $Active
        } while ($true)
    }
}