function TrimLines {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$Lines
    )
    begin {
        [string[]]$AllLines = @()
    }
    process {
        [string[]]$AllLines += $Lines -split "\r?\n"
    }
    end {
        $first = [Array]::FindIndex($AllLines, [Predicate[string]] {![string]::IsNullOrWhiteSpace($args[0])})
        $last = [Array]::FindLastIndex($AllLines, [Predicate[string]] {![string]::IsNullOrWhiteSpace($args[0])})
        $Index = 0
        if ($AllLines[$first+1] -match "^[- ]*$") {
            $AllLines[$first]
            $first += 2
        }
        foreach ($line in $AllLines[$first..$last]) {
            Add-Member -Input $line -MemberType NoteProperty -Name Index -Value $Index -PassThru
            $Index += 1
        }
    }
}