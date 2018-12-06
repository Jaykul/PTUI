function Show-List {
    [CmdletBinding()]
    param(
        $Top = 1,
        $Left = 1,
        [string[]]$List,
        [RgbColor]$BackgroundColor = "Black",
        [RgbColor]$HighlightColor  = "Gray",
        [RgbColor]$SelectedColor   = "DarkGray"
    )

    # Write out all the lines
    $X = $Top
    $Background = $BackgroundColor.ToVtEscapeSequence($true)
    $Highlight  = $HighlightColor.ToVtEscapeSequence($true)
    $Selected   = $SelectedColor.ToVtEscapeSequence($true)

    foreach ($l in $List) {
        Write-Host (($SetXY -f $Left, $X++) + $Background + $l.TrimEnd()) -NoNewline
    }

    $Active = $List.Count
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
                if(!$Key.KeyDown -or $Active -eq 0) { continue }

                if($Active -lt $List.Count) {
                    Write-Host -NoNewLine (($SetXY -f $Left, ($Active + $Top)) + $Background + $List[$Active])
                }

                $Active = [Math]::Max(0, $Active - 1)
                # Write-Verbose "Key: $($Key.VirtualKeyCode) $(if($Key.KeyDown){'Down'}else{'Up'}) ($Active)"

                Write-Host -NoNewLine (($SetXY -f $Left, ($Active + $Top)) + $Highlight + $List[$Active])
            }
            40 {# DOWN KEY
                # Ignore the key up because we act on key down
                if(!$Key.KeyDown -or $Active -eq ($List.Count - 1)) { continue }

                if($Active -ge $List.Count) {
                    $Active = -1
                } else {
                    Write-Host -NoNewLine (($SetXY -f $Left, ($Active + $Top)) + $Background + $List[$Active])
                }

                $Active = [Math]::Min($List.Count - 1, $Active + 1)
                # Write-Verbose "Key: $($Key.VirtualKeyCode) $(if($Key.KeyDown){'Down'}else{'Up'}) ($Active)"

                Write-Host -NoNewLine (($SetXY -f $Left, ($Active + $Top)) + $Highlight + $List[$Active])
            }
            13 {
                return $Active
            }
        }
    } while ($true)
}