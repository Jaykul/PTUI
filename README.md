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
  - Draws a box (with an optional title). This might be redundant.
  - Shows a list in the box and lets you select one or more. It uses Format-Table to make the list (for now).
  - Scrolls if there are too many items for the screen
  - Returns the actual selected item(s)!
  - Select by pressing space, or just hit enter to return the current item
  - **Now** Supports type-ahead searching **or** filtering

Things that don't work, for instance:

- There's no way to specify which properties are shown
- You can't re-sort after the display
- Multi-select isn't intuitive enough: you can press Space to toggle selection, but you can't hold SHIFT and press the Up/Down arrows.