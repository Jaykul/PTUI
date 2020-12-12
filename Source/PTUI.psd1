@{
    ModuleVersion     = '1.0.0'
    PrivateData       = @{
        PSData = @{
            # Prerelease string should be here, so we can set it
            PreRelease   = ''
            # Release Notes have to be here, so we can update them
            ReleaseNotes = '
            Working on boxes and menus for the cross-platform console
            '
            Tags = @()
            # LicenseUri = ''
            # ProjectUri = ''
            # IconUri = ''
        } # PSData
    } # PrivateData
    RequiredModules   = @('PANSIES')

    RootModule        = 'PTUI.psm1'
    GUID              = 'bbf3ac6d-574e-49c1-891b-9064163b84c1'
    Description       = 'A PowerShell module for cross-platform TUI experiments'

    Author            = 'Joel "Jaykul" Bennett'
    CompanyName       = 'HuddledMasses.org'
    Copyright         = '(c) 2018 Joel Bennett. All rights reserved.'

    # Do not delete the entry, use an empty array if there are no cmdlets to export.
    FunctionsToExport = @()
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    FileList          = @()

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'
    CompatiblePSEditions = @('Core', 'Desktop')
}

