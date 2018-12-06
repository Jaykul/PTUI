function TrimLines {
    [CmdletBinding()]
    param(
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
        $AllLines[$first..$last]
    }
}