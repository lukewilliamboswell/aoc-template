# TODO move this back into [lukewilliamboswell/roc-ansi](https://github.com/lukewilliamboswell/roc-ansi)
# for now this is quicker to iterate on designs
interface ANSI
    exposes [
        # ANSI
        Code,
        toStr,
        
        # Color
        Color,
        withFg,
        withBg,
        withColor,

        # TUI
        DrawFn,
        Pixel,
        ScreenSize,
        Position,
        Input,
        parseCursor,
        updateCursor,
        inputToStr,
        parseRawStdin,
        drawScreen,
        drawText,
        drawVLine,
        drawHLine,
        drawBox,
        drawCursor,
    ]
    imports []

## [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code)
Code : [
    Reset,
    ClearScreen,
    GetCursor,
    SetCursor { row : I32, col : I32 },
    SetFgColor Color,
    SetBgColor Color,
    EraseToEnd,
    EraseFromStart,
    EraseLine,
    MoveCursorHome,
    MoveCursor [Up, Down, Left, Right] I32,
    MoveCursorNextLine,
    MoveCursorPrevLine,
]

## 8-bit colors supported on *most* modern terminal emulators
Color : [
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    Gray,
    BrightBlack, # for terminals which support axiterm specification
    BrightRed, # for terminals which support axiterm specification
    BrightGreen, # for terminals which support axiterm specification
    BrightYellow, # for terminals which support axiterm specification
    BrightBlue, # for terminals which support axiterm specification
    BrightMagenta, # for terminals which support axiterm specification
    BrightCyan, # for terminals which support axiterm specification
    BrightWhite, # for terminals which support axiterm specification
    Default,
]

# ESC character
esc : Str
esc = "\u(001b)"

toStr : Code -> Str
toStr = \code ->
    when code is
        Reset -> "\(esc)c"
        ClearScreen -> "\(esc)[3J"
        GetCursor -> "\(esc)[6n"
        SetCursor { row, col } -> "\(esc)[\(Num.toStr row);\(Num.toStr col)H"
        SetFgColor color -> fromFgColor color
        SetBgColor color -> fromBgColor color
        EraseToEnd -> "\(esc)[0K"
        EraseFromStart -> "\(esc)[1K"
        EraseLine -> "\(esc)[2K"
        MoveCursorHome -> "\(esc)[H"
        MoveCursorNextLine -> "\(esc)[1E"
        MoveCursorPrevLine -> "\(esc)[1F"
        MoveCursor direction steps ->
            when direction is
                Up -> "\(esc)[\(Num.toStr steps)A"
                Down -> "\(esc)[\(Num.toStr steps)B"
                Right -> "\(esc)[\(Num.toStr steps)C"
                Left -> "\(esc)[\(Num.toStr steps)D"

fromFgColor : Color -> Str
fromFgColor = \color ->
    when color is
        Black -> "\(esc)[30m"
        Red -> "\(esc)[31m"
        Green -> "\(esc)[32m"
        Yellow -> "\(esc)[33m"
        Blue -> "\(esc)[34m"
        Magenta -> "\(esc)[35m"
        Cyan -> "\(esc)[36m"
        Gray -> "\(esc)[37m"
        Default -> "\(esc)[39m"
        BrightBlack -> "\(esc)[90m"
        BrightRed -> "\(esc)[91m"
        BrightGreen -> "\(esc)[92m"
        BrightYellow -> "\(esc)[93m"
        BrightBlue -> "\(esc)[94m"
        BrightMagenta -> "\(esc)[95m"
        BrightCyan -> "\(esc)[96m"
        BrightWhite -> "\(esc)[97m"

fromBgColor : Color -> Str
fromBgColor = \color ->
    when color is
        Black -> "\(esc)[40m"
        Red -> "\(esc)[41m"
        Green -> "\(esc)[42m"
        Yellow -> "\(esc)[43m"
        Blue -> "\(esc)[44m"
        Magenta -> "\(esc)[45m"
        Cyan -> "\(esc)[46m"
        Gray -> "\(esc)[47m"
        Default -> "\(esc)[49m"
        BrightBlack -> "\(esc)[100m"
        BrightRed -> "\(esc)[101m"
        BrightGreen -> "\(esc)[102m"
        BrightYellow -> "\(esc)[103m"
        BrightBlue -> "\(esc)[104m"
        BrightMagenta -> "\(esc)[105m"
        BrightCyan -> "\(esc)[106m"
        BrightWhite -> "\(esc)[107m"

## Adds foreground color formatting to a Str and then resets to Default
withFg : Str, Color -> Str
withFg = \str, color -> "\(toStr (SetFgColor color))\(str)\(esc)[0m"

## Adds background color formatting to a Str and then resets to Default
withBg : Str, Color -> Str
withBg = \str, color -> "\(toStr (SetBgColor color))\(str)\(esc)[0m"

## Adds color formatting to a Str and then resets to Default
withColor : Str, { fg : Color, bg : Color } -> Str
withColor = \str, colors -> "\(toStr (SetFgColor colors.fg))\(toStr (SetBgColor colors.bg))\(str)\(esc)[0m"

Key : [
    Up,
    Down,
    Left,
    Right,
    Escape,
    Enter,
    LowerA,
    UpperA,
    UpperB,
    LowerB,
    UpperC,
    LowerC,
    UpperD,
    LowerD,
    UpperE,
    LowerE,
    UpperF,
    LowerF,
    UpperG,
    LowerG,
    UpperH,
    LowerH,
    UpperI,
    LowerI,
    UpperJ,
    LowerJ,
    UpperK,
    LowerK,
    UpperL,
    LowerL,
    UpperM,
    LowerM,
    UpperN,
    LowerN,
    UpperO,
    LowerO,
    UpperP,
    LowerP,
    UpperQ,
    LowerQ,
    UpperR,
    LowerR,
    UpperS,
    LowerS,
    UpperT,
    LowerT,
    UpperU,
    LowerU,
    UpperV,
    LowerV,
    UpperW,
    LowerW,
    UpperX,
    LowerX,
    UpperY,
    LowerY,
    UpperZ,
    LowerZ,
    Space,
    ExclamationMark,
    QuotationMark,
    NumberSign,
    DollarSign,
    PercentSign,
    Ampersand,
    Apostrophe,
    RoundOpenBracket,
    RoundCloseBracket,
    Asterisk,
    PlusSign,
    Comma,
    Hyphen,
    FullStop,
    ForwardSlash,
    Colon,
    SemiColon,
    LessThanSign,
    EqualsSign,
    GreaterThanSign,
    QuestionMark,
    AtSign,
    SquareOpenBracket,
    Backslash,
    SquareCloseBracket,
    Caret,
    Underscore,
    GraveAccent,
    CurlyOpenBrace,
    VerticalBar,
    CurlyCloseBrace,
    Tilde,
    Number0,
    Number1,
    Number2,
    Number3,
    Number4,
    Number5,
    Number6,
    Number7,
    Number8,
    Number9,
]

Input : [
    KeyPress Key,
    CtrlC,
    Unsupported (List U8),
]

parseRawStdin : List U8 -> Input
parseRawStdin = \bytes ->
    when bytes is
        [27, 91, 'A', ..] -> KeyPress Up
        [27, 91, 'B', ..] -> KeyPress Down
        [27, 91, 'C', ..] -> KeyPress Right
        [27, 91, 'D', ..] -> KeyPress Left
        [27, ..] -> KeyPress Escape
        [13, ..] -> KeyPress Enter
        [32, ..] -> KeyPress Space
        ['A', ..] -> KeyPress UpperA
        ['a', ..] -> KeyPress LowerA
        ['B', ..] -> KeyPress UpperB
        ['b', ..] -> KeyPress LowerB
        ['C', ..] -> KeyPress UpperC
        ['c', ..] -> KeyPress LowerC
        ['D', ..] -> KeyPress UpperD
        ['d', ..] -> KeyPress LowerD
        ['E', ..] -> KeyPress UpperE
        ['e', ..] -> KeyPress LowerE
        ['F', ..] -> KeyPress UpperF
        ['f', ..] -> KeyPress LowerF
        ['G', ..] -> KeyPress UpperG
        ['g', ..] -> KeyPress LowerG
        ['H', ..] -> KeyPress UpperH
        ['h', ..] -> KeyPress LowerH
        ['I', ..] -> KeyPress UpperI
        ['i', ..] -> KeyPress LowerI
        ['J', ..] -> KeyPress UpperJ
        ['j', ..] -> KeyPress LowerJ
        ['K', ..] -> KeyPress UpperK
        ['k', ..] -> KeyPress LowerK
        ['L', ..] -> KeyPress UpperL
        ['l', ..] -> KeyPress LowerL
        ['M', ..] -> KeyPress UpperM
        ['m', ..] -> KeyPress LowerM
        ['N', ..] -> KeyPress UpperN
        ['n', ..] -> KeyPress LowerN
        ['O', ..] -> KeyPress UpperO
        ['o', ..] -> KeyPress LowerO
        ['P', ..] -> KeyPress UpperP
        ['p', ..] -> KeyPress LowerP
        ['Q', ..] -> KeyPress UpperQ
        ['q', ..] -> KeyPress LowerQ
        ['R', ..] -> KeyPress UpperR
        ['r', ..] -> KeyPress LowerR
        ['S', ..] -> KeyPress UpperS
        ['s', ..] -> KeyPress LowerS
        ['T', ..] -> KeyPress UpperT
        ['t', ..] -> KeyPress LowerT
        ['U', ..] -> KeyPress UpperU
        ['u', ..] -> KeyPress LowerU
        ['V', ..] -> KeyPress UpperV
        ['v', ..] -> KeyPress LowerV
        ['W', ..] -> KeyPress UpperW
        ['w', ..] -> KeyPress LowerW
        ['X', ..] -> KeyPress UpperX
        ['x', ..] -> KeyPress LowerX
        ['Y', ..] -> KeyPress UpperY
        ['y', ..] -> KeyPress LowerY
        ['Z', ..] -> KeyPress UpperZ
        ['z', ..] -> KeyPress LowerZ
        ['!', ..] -> KeyPress ExclamationMark
        ['"', ..] -> KeyPress QuotationMark
        ['#', ..] -> KeyPress NumberSign
        ['$', ..] -> KeyPress DollarSign
        ['%', ..] -> KeyPress PercentSign
        ['&', ..] -> KeyPress Ampersand
        ['\'', ..] -> KeyPress Apostrophe
        ['(', ..] -> KeyPress RoundOpenBracket
        [')', ..] -> KeyPress RoundCloseBracket
        ['*', ..] -> KeyPress Asterisk
        ['+', ..] -> KeyPress PlusSign
        [',', ..] -> KeyPress Comma
        ['-', ..] -> KeyPress Hyphen
        ['.', ..] -> KeyPress FullStop
        ['/', ..] -> KeyPress ForwardSlash
        [':', ..] -> KeyPress Colon
        [';', ..] -> KeyPress SemiColon
        ['<', ..] -> KeyPress LessThanSign
        ['=', ..] -> KeyPress EqualsSign
        ['>', ..] -> KeyPress GreaterThanSign
        ['?', ..] -> KeyPress QuestionMark
        ['@', ..] -> KeyPress AtSign
        ['[', ..] -> KeyPress SquareOpenBracket
        ['\\', ..] -> KeyPress Backslash
        [']', ..] -> KeyPress SquareCloseBracket
        ['^', ..] -> KeyPress Caret
        ['_', ..] -> KeyPress Underscore
        ['`', ..] -> KeyPress GraveAccent
        ['{', ..] -> KeyPress CurlyOpenBrace
        ['|', ..] -> KeyPress VerticalBar
        ['}', ..] -> KeyPress CurlyCloseBrace
        ['~', ..] -> KeyPress Tilde
        ['0', ..] -> KeyPress Number0
        ['1', ..] -> KeyPress Number1
        ['2', ..] -> KeyPress Number2
        ['3', ..] -> KeyPress Number3
        ['4', ..] -> KeyPress Number4
        ['5', ..] -> KeyPress Number5
        ['6', ..] -> KeyPress Number6
        ['7', ..] -> KeyPress Number7
        ['8', ..] -> KeyPress Number8
        ['9', ..] -> KeyPress Number9
        [3, ..] -> CtrlC
        _ -> Unsupported bytes

expect parseRawStdin [27, 91, 65] == KeyPress Up
expect parseRawStdin [27] == KeyPress Escape

inputToStr : Input -> Str
inputToStr = \input ->
    when input is
        KeyPress key -> "Key \(keyToStr key)"
        CtrlC -> "Ctrl-C"
        Unsupported bytes ->
            bytesStr = bytes |> List.map Num.toStr |> Str.joinWith ","
            "Unsupported [\(bytesStr)]"

keyToStr : Key -> Str
keyToStr = \key ->
    when key is
        Up -> "Up"
        Down -> "Down"
        Left -> "Left"
        Right -> "Right"
        Escape -> "Escape"
        Enter -> "Enter"
        Space -> "Space"
        UpperA -> "A"
        LowerA -> "a"
        UpperB -> "B"
        LowerB -> "b"
        UpperC -> "C"
        LowerC -> "c"
        UpperD -> "D"
        LowerD -> "d"
        UpperE -> "E"
        LowerE -> "e"
        UpperF -> "F"
        LowerF -> "f"
        UpperG -> "G"
        LowerG -> "g"
        UpperH -> "H"
        LowerH -> "h"
        UpperI -> "I"
        LowerI -> "i"
        UpperJ -> "J"
        LowerJ -> "j"
        UpperK -> "K"
        LowerK -> "k"
        UpperL -> "L"
        LowerL -> "l"
        UpperM -> "M"
        LowerM -> "m"
        UpperN -> "N"
        LowerN -> "n"
        UpperO -> "O"
        LowerO -> "o"
        UpperP -> "P"
        LowerP -> "p"
        UpperQ -> "Q"
        LowerQ -> "q"
        UpperR -> "R"
        LowerR -> "r"
        UpperS -> "S"
        LowerS -> "s"
        UpperT -> "T"
        LowerT -> "t"
        UpperU -> "U"
        LowerU -> "u"
        UpperV -> "V"
        LowerV -> "v"
        UpperW -> "W"
        LowerW -> "w"
        UpperX -> "X"
        LowerX -> "x"
        UpperY -> "Y"
        LowerY -> "y"
        UpperZ -> "Z"
        LowerZ -> "z"
        ExclamationMark -> "!"
        QuotationMark -> "\""
        NumberSign -> "#"
        DollarSign -> "$"
        PercentSign -> "%"
        Ampersand -> "&"
        Apostrophe -> "\\"
        RoundOpenBracket -> "("
        RoundCloseBracket -> ")"
        Asterisk -> "*"
        PlusSign -> "+"
        Comma -> ","
        Hyphen -> "-"
        FullStop -> "."
        ForwardSlash -> "/"
        Colon -> ":"
        SemiColon -> ";"
        LessThanSign -> "<"
        EqualsSign -> "="
        GreaterThanSign -> ">"
        QuestionMark -> "?"
        AtSign -> "@"
        SquareOpenBracket -> "["
        Backslash -> "\\"
        SquareCloseBracket -> "]"
        Caret -> "^"
        Underscore -> "_"
        GraveAccent -> "`"
        CurlyOpenBrace -> "{"
        VerticalBar -> "|"
        CurlyCloseBrace -> "}"
        Tilde -> "~"
        Number0 -> "0"
        Number1 -> "1"
        Number2 -> "2"
        Number3 -> "3"
        Number4 -> "4"
        Number5 -> "5"
        Number6 -> "6"
        Number7 -> "7"
        Number8 -> "8"
        Number9 -> "9"

ScreenSize : { width : I32, height : I32 }
Position : { row : I32, col : I32 }
DrawFn : Position, Position -> Result Pixel {}
Pixel : { char : Str, fg : Color, bg : Color }

parseCursor : List U8 -> Position
parseCursor = \bytes ->
    { val: row, rest: afterFirst } = takeNumber { val: 0, rest: List.dropFirst bytes 2 }
    { val: col } = takeNumber { val: 0, rest: List.dropFirst afterFirst 1 }

    { row, col }

# test "ESC[33;1R"
expect parseCursor [27, 91, 51, 51, 59, 49, 82] == { col: 1, row: 33 }

takeNumber : { val : I32, rest : List U8 } -> { val : I32, rest : List U8 }
takeNumber = \in ->
    when in.rest is
        [a, ..] if a == '0' -> takeNumber { val: in.val * 10 + 0, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '1' -> takeNumber { val: in.val * 10 + 1, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '2' -> takeNumber { val: in.val * 10 + 2, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '3' -> takeNumber { val: in.val * 10 + 3, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '4' -> takeNumber { val: in.val * 10 + 4, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '5' -> takeNumber { val: in.val * 10 + 5, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '6' -> takeNumber { val: in.val * 10 + 6, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '7' -> takeNumber { val: in.val * 10 + 7, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '8' -> takeNumber { val: in.val * 10 + 8, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '9' -> takeNumber { val: in.val * 10 + 9, rest: List.dropFirst in.rest 1 }
        _ -> in

expect takeNumber { val: 0, rest: [27, 91, 51, 51, 59, 49, 82] } == { val: 0, rest: [27, 91, 51, 51, 59, 49, 82] }
expect takeNumber { val: 0, rest: [51, 51, 59, 49, 82] } == { val: 33, rest: [59, 49, 82] }
expect takeNumber { val: 0, rest: [49, 82] } == { val: 1, rest: [82] }

updateCursor : { cursor : Position, screen : ScreenSize }a, [Up, Down, Left, Right] -> { cursor : Position, screen : ScreenSize }a
updateCursor = \state, direction ->
    when direction is
        Up ->
            { state &
                cursor: {
                    row: ((state.cursor.row + state.screen.height - 1) % state.screen.height),
                    col: state.cursor.col,
                },
            }

        Down ->
            { state &
                cursor: {
                    row: ((state.cursor.row + 1) % state.screen.height),
                    col: state.cursor.col,
                },
            }

        Left ->
            { state &
                cursor: {
                    row: state.cursor.row,
                    col: ((state.cursor.col + state.screen.width - 1) % state.screen.width),
                },
            }

        Right ->
            { state &
                cursor: {
                    row: state.cursor.row,
                    col: ((state.cursor.col + 1) % state.screen.width),
                },
            }

## Loop through each pixel in screen and build up a single string to write to stdout
drawScreen : { cursor : Position, screen : ScreenSize }*, List DrawFn -> Str
drawScreen = \{ cursor, screen }, drawFns ->
    pixels =
        row <- List.range { start: At 0, end: Before screen.height } |> List.map
        col <- List.range { start: At 0, end: Before screen.width } |> List.map

        List.walkUntil
            drawFns
            { char: " ", fg: Default, bg: Default }
            \defaultPixel, drawFn ->
                when drawFn cursor { row, col } is
                    Ok pixel -> Break pixel
                    Err _ -> Continue defaultPixel

    pixels
    |> joinAllPixels

joinAllPixels : List (List Pixel) -> Str
joinAllPixels = \rows ->
    List.walkWithIndex
        rows
        {
            char: " ",
            fg: Default,
            bg: Default,
            lines: List.withCapacity (List.len rows),
        }
        joinPixelRow
    |> .lines
    |> Str.joinWith ""

joinPixelRow : { char : Str, fg : Color, bg : Color, lines : List Str }, List Pixel, Nat -> { char : Str, fg : Color, bg : Color, lines : List Str }
joinPixelRow = \{ char, fg, bg, lines }, pixelRow, row ->

    { rowStrs, prev } =
        List.walk
            pixelRow
            { rowStrs: List.withCapacity (List.len pixelRow), prev: { char, fg, bg } }
            joinPixels

    line =
        rowStrs
        |> Str.joinWith "" # Set cursor at the start of line we want to draw
        |> Str.withPrefix (toStr (SetCursor { row: Num.toI32 (row + 1), col: 0 }))

    { char: " ", fg: prev.fg, bg: prev.bg, lines: List.append lines line }

joinPixels : { rowStrs : List Str, prev : Pixel }, Pixel -> { rowStrs : List Str, prev : Pixel }
joinPixels = \{ rowStrs, prev }, curr ->
    pixelStr =
        # Prepend an ASCII escape ONLY if there is a change between pixels
        curr.char
        |> \str -> if curr.fg != prev.fg then Str.concat (toStr (SetFgColor curr.fg)) str else str
        |> \str -> if curr.bg != prev.bg then Str.concat (toStr (SetBgColor curr.bg)) str else str

    { rowStrs: List.append rowStrs pixelStr, prev: curr }

drawBox : { r : I32, c : I32, w : I32, h : I32, fg ? Color, bg ? Color, char ? Str } -> DrawFn
drawBox = \{ r, c, w, h, fg ? Gray, bg ? Default, char ? "#" } -> \_, { row, col } ->

        startRow = r
        endRow = (r + h)
        startCol = c
        endCol = (c + w)

        if row == r && (col >= startCol && col < endCol) then
            Ok { char, fg, bg } # TOP BORDER
        else if row == (r + h - 1) && (col >= startCol && col < endCol) then
            Ok { char, fg, bg } # BOTTOM BORDER
        else if col == c && (row >= startRow && row < endRow) then
            Ok { char, fg, bg } # LEFT BORDER
        else if col == (c + w - 1) && (row >= startRow && row < endRow) then
            Ok { char, fg, bg } # RIGHT BORDER
        else
            Err {}

drawVLine : { r : I32, c : I32, len : I32, fg ? Color, bg ? Color, char ? Str } -> DrawFn
drawVLine = \{ r, c, len, fg ? Default, bg ? Default, char ? "|" } -> \_, { row, col } ->
        if col == c && (row >= r && row < (r + len)) then
            Ok { char, fg, bg }
        else
            Err {}

drawHLine : { r : I32, c : I32, len : I32, fg ? Color, bg ? Color, char ? Str } -> DrawFn
drawHLine = \{ r, c, len, fg ? Default, bg ? Default, char ? "-" } -> \_, { row, col } ->
        if row == r && (col >= c && col < (c + len)) then
            Ok { char, fg, bg }
        else
            Err {}

drawCursor : { fg ? Color, bg ? Color, char ? Str } -> DrawFn
drawCursor = \{ fg ? Default, bg ? Gray, char ? " " } -> \cursor, { row, col } ->
        if
            (row == cursor.row) && (col == cursor.col)
        then
            Ok { char, fg, bg }
        else
            Err {}

drawText : Str, { r : I32, c : I32, fg ? Color, bg ? Color } -> DrawFn
drawText = \text, { r, c, fg ? Default, bg ? Default } -> \_, pixel ->
        bytes = Str.toUtf8 text
        len = text |> Str.toUtf8 |> List.len |> Num.toI32
        if pixel.row == r && pixel.col >= c && pixel.col < (c + len) then
            bytes
            |> List.get (Num.toNat (pixel.col - c))
            |> Result.try \b -> Str.fromUtf8 [b]
            |> Result.map \char -> { char, fg, bg }
            |> Result.mapErr \_ -> {}
        else
            Err {}
