# Terminal User Interfaces

I'm experimenting with building a few user interfaces in the terminal.

Right now, I'm playing, and using nothing but VT escape sequences.

Long term, I'll probably use [ConsoleFramework](https://github.com/elw00d/consoleframework) or something similar (i.e. based on nCurses and pdCurses), and build some PowerShell cmdlets and even a DSL for it.

# Current State

I just started playing. I have created:

- `Show-List` which allows creating a list anywhere on the console and selecting an item from it with up/down arrow keys and returns the index of the selected item when you hit Enter.
- `Show-Box` which allows drawing a box, with an optional title.
- `Select-Interactive` which combines the two and:
  - Switches to the alternate buffer and back
  - Draws a box (with an optional title)
  - Shows a list in the box and lets you select one. It uses Format-Table to make the list (for now).
  - Returns the actual selected item!

Things that don't work, for instance:

- `Show-List` (and therefore, `Select-Interactive`) doesn't scroll (if there's more items than fit on a screen height). That means it basically doesn't work if there are more items than `$Host.UI.RawUI.WindowSize.Height - 2`
- The highlights on `Show-List` don't have a "width" so they're only as wide as the text of the item
- There's no multi-select option
- There's no way to specify which properties are shown
- You can't type text to select matching items
- There's no filtering