[CmdletBinding()]
param(
    # A specific folder to build into
    $OutputDirectory,

    # The version of the output module
    [Alias("ModuleVersion")]
    [string]$SemVer
)
Push-Location $PSScriptRoot -StackName BuildModule
try {
    ## Build the actual module
    Build-Module .\Source @PSBoundParameters -Prefix .\Init\0.ps1
} finally {
    Pop-Location -StackName BuildModule
}