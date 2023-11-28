interface ANSI
    exposes [Color, toStr, Code, fg, bg, with, Input, inputToStr, parseRawStdin]
    imports []

## [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code)
Code : [
    Reset,
    ClearScreen,
    GetCursor,
    SetCursor { row : I32, col : I32 },
    SetFgColor Color,
    SetBgColor Color,
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
fg : Str, Color -> Str
fg = \str, color -> "\(toStr (SetFgColor color))\(str)\(esc)[0m"

## Adds background color formatting to a Str and then resets to Default
bg : Str, Color -> Str
bg = \str, color -> "\(toStr (SetBgColor color))\(str)\(esc)[0m"

## Adds color formatting to a Str and then resets to Default
with : Str, { fg : Color, bg : Color } -> Str
with = \str, colors -> "\(toStr (SetFgColor colors.fg))\(toStr (SetBgColor colors.bg))\(str)\(esc)[0m"

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
