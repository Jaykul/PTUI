class Padding {
    [int]$Left = 0
    [int]$Right = 0
    [int]$Top = 0
    [int]$Bottom = 0

    [void]SetFromIntArray([int[]]$padding) {
        if ($padding.Count -ge 1) {
            $this.Left = $padding[0]
            $this.Right = $padding[0]
        }
        if ($padding.Count -ge 2) {
            $this.Right = $padding[1]
        }
        if ($padding.Count -ge 3) {
            $this.Top = $padding[2]
        }
        if ($padding.Count -ge 4) {
            $this.Bottom = $padding[3]
        }
    }

    [string]ToString() {
        return "{$($this.Left), $($this.Right), $($this.Top), $($this.Bottom)}"
    }

    Padding([int[]]$padding) {
        $this.SetFromIntArray($padding)
    }
    Padding([object[]]$padding) {
        $this.SetFromIntArray($padding)
    }
}
