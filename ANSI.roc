interface ANSI
    exposes [Color, toStr, Code, fg, bg, with]
    imports []

## [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code)
Code : [
    ClearScreen,
    GetCursor,
    SetCursor { row : I32, col : I32 },
    SetFgColor Color,
    SetBgColor Color,
    MoveCursor [Up, Down, Left, Right] I32,
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
    White,
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
        ClearScreen -> "\(esc)c" 
        GetCursor -> "\(esc)[6n"
        SetCursor {row, col} -> "\(esc)[\(Num.toStr row);\(Num.toStr col)H"
        SetFgColor color -> fromFgColor color
        SetBgColor color -> fromBgColor color
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
        White -> "\(esc)[37m"
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
        White -> "\(esc)[47m"
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
with : Str, {fg: Color, bg: Color} -> Str
with = \str, colors -> "\(toStr (SetFgColor colors.fg))\(toStr (SetBgColor colors.bg))\(str)\(esc)[0m"
