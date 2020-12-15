using namespace PoshCode.Pansies

$BoxChars = [PSCustomObject]@{
    'HorizontalDouble'           = ([char]9552).ToString()
    'VerticalDouble'             = ([char]9553).ToString()
    'TopLeftDouble'              = ([char]9556).ToString()
    'TopRightDouble'             = ([char]9559).ToString()
    'BottomLeftDouble'           = ([char]9562).ToString()
    'BottomRightDouble'          = ([char]9565).ToString()
    'HorizontalDoubleSingleDown' = ([char]9572).ToString()
    'HorizontalDoubleSingleUp'   = ([char]9575).ToString()
    'Horizontal'                 = ([char]9472).ToString()
    'Vertical'                   = ([char]9474).ToString()
    'TopLeft'                    = ([char]9484).ToString()
    'TopRight'                   = ([char]9488).ToString()
    'BottomLeft'                 = ([char]9492).ToString()
    'BottomRight'                = ([char]9496).ToString()
    'Cross'                      = ([char]9532).ToString()
    'VerticalDoubleRightSingle'  = ([char]9567).ToString()
    'VerticalDoubleRightDouble'  = ([char]9568).ToString()
    'VerticalDoubleLeftSingle'   = ([char]9570).ToString()
    'VerticalDoubleLeftDouble'   = ([char]9571).ToString()
}

$EscapeRegex = [Regex]::new("[\u001B\u009B][[\]()#;?]*(?:(?:(?:[a-zA-Z\d]*(?:;[a-zA-Z\d]*)*)?\u0007)|(?:(?:\d{1,4}(?:;\d{0,4})*)?[\dA-PRZcf-ntqry=><~]))")

$e = "$([char]27)"

$Up    = "$e[A"         # Cursor Up 	Cursor up by {0}
$Down  = "$e[B"         # Cursor Down 	Cursor down by {0}
$Right = "$e[C"         # Cursor Forward 	Cursor forward (Right) by {0}
$Left  = "$e[D"         # Cursor Backward 	Cursor backward (Left) by {0}

$UpN   = "$e[{0}A"      # Cursor Up 	Cursor up by {0}
$DownN = "$e[{0}B"      # Cursor Down 	Cursor down by {0}
$RightN= "$e[{0}C"      # Cursor Forward 	Cursor forward (Right) by {0}
$LeftN = "$e[{0}D"      # Cursor Backward 	Cursor backward (Left) by {0}

$CRF   = "$e[{0}E"      # Cursor Next Line 	Cursor down to beginning of {0}th line in the viewport
$CRB   = "$e[{0}F"      # Cursor Previous Line 	Cursor up to beginning of {0}th line in the viewport
$SetX  = "$e[{0}G"      # Cursor Horizontal Absolute 	Cursor moves to {0}th position horizontally in the current line
$SetY  = "$e[{0}d"      # Vertical Line Position Absolute 	Cursor moves to the {0}th position vertically in the current column
$SetXY = "$e[{1};{0}H"  # Cursor Position 	*Cursor moves to {1}; {0} coordinate within the viewport, where {0} is the column of the {1} line
# $SetXY = "$e[{0};{1}f"  # Horizontal Vertical Position 	*Cursor moves to {1}; {0} coordinate within the viewport, where {1} is the column of the {0} line
$Save  = "$e[s"         # Save Cursor - Ansi.sys emulation 	**With no parameters, performs a save cursor operation like DECSC
$Load  = "$e[u"         # Restore Cursor - Ansi.sys emulation 	**With no parameters, performs a restore cursor operation like DECRC
$Show  = "$e[?25h"      # Text Cursor Enable Mode Show 	Show the cursor
$Hide  = "$e[?25l"      # Text Cursor Enable Mode Hide 	Hide the cursor
$Alt   = "$e[?1049h"
$Main  = "$e[?1049l"

$ICH = "$e[{0}@" # Insert Character 	Insert <n> spaces at the current cursor position, shifting all existing text to the right. Text exiting the screen to the right is removed.
$DCH = "$e[{0}P" # Delete Character 	Delete <n> characters at the current cursor position, shifting in space characters from the right edge of the screen.
$ECH = "$e[{0}X" # Erase Character 	Erase <n> characters from the current cursor position by overwriting them with a space character.
$IL = "$e[{0}L" # Insert Line 	Inserts <n> lines into the buffer at the cursor position. The line the cursor is on, and lines below it, will be shifted downwards.
$DL = "$e[{0}M" # Delete Line 	Deletes <n> lines from the buffer, starting with the row the cursor is on.

$Freeze= "$e[{0};{1}r"