app "AoC"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.2/c7T4Hp8bAdWz3r9ZrhboBzibCjJag8d0IP_ljb42yVc.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Stdin,
        pf.Sleep,
        pf.Tty,
        pf.Task.{ Task },
        ANSI.{ Color },

        # App,
    ]
    provides [main] to pf

State : {
    screen : { width : I32, height : I32 },
    cursor : { row : I32, col : I32 },
}

init : State
init = {
    cursor: { row: 2, col: 2 },
    screen: { width: 0, height: 0 },
}

render : State -> List DrawFn
render = \state ->
    cursorStr = "CURSOR \(Num.toStr state.cursor.row), \(Num.toStr state.cursor.col)"
    screenStr = "SCREEN \(Num.toStr state.screen.height), \(Num.toStr state.screen.width) TOTAL PIXELS \(Num.toStr (state.screen.height * state.screen.width))"
    [
        drawCursor { bg: Green },
        drawText cursorStr { r: state.screen.height - 2, c: 2, fg: Magenta },
        drawText screenStr { r: state.screen.height - 1, c: 2, fg: Cyan },
        drawBox { r: 1, c: 1, w: state.screen.width, h: state.screen.height }, # border
        drawVLine { r: 2, c: state.screen.width // 2, len: state.screen.height, fg: Blue },
        drawHLine { r: state.screen.height // 2, c: 2, len: state.screen.width, fg: Blue },
    ]

main : Task {} *
main = runTask |> Task.onErr \_ -> Stdout.line "ERROR Something went wrong"

runTask : Task {} []
runTask =
    # Enable TTY Raw mode
    {} <- Tty.enableRawMode |> Task.await

    # Run App Loop
    _ <- Task.loop init runLoop |> Task.await

    # Restore TTY Mode
    {} <- Tty.disableRawMode |> Task.await

    Task.ok {}


# TODO ADD PUZZLE STUFF BACK IN
# when App.solvePuzzle { year: 2022, day: 1, puzzle: Part1 } is
#     Ok answer ->
#         header = Color.fg "Advent of Code Solution" Green
#         year = Color.fg "\(Num.toStr 2022)" Green
#         day = Color.fg "\(Num.toStr 1)" Green
#         part = Color.fg "1" Green
#         time = Color.fg "245ms" Green

#         """

#         --- \(header)
#         year: \(year)
#         day: \(day)
#         part: \(part)
#         time: \(time)
#         answer:

#         \(answer)
#         ---
#         """
#         |> Stdout.line

#     Err NotImplemented ->
#         [
#             Color.fg "Advent of Code" Green,
#             ":",
#             Color.fg "\(Num.toStr 2022)-\(Num.toStr 1)-Part 1" Blue,
#             ":",
#             Color.fg "NOT IMPLEMENTED" Red,
#         ]
#         |> Str.joinWith ""
#         |> Stdout.line

#     Err (Error msg) ->
#         [
#             Color.fg "Advent of Code" Green,
#             ":",
#             Color.fg "\(Num.toStr 2022)-\(Num.toStr 1)-Part 1" Blue,
#             ":",
#             Color.fg "ERROR \(msg)" Red,
#         ]
#         |> Str.joinWith ""
#         |> Stdout.line

runLoop : State -> Task [Step State, Done State] []
runLoop = \state ->

    # Update screen size (in case it was resized since last draw)
    terminalSize <- getTerminalSize |> Task.await

    stateWithScreenUpdated = { state & screen: terminalSize }
    drawFns = render stateWithScreenUpdated

    # Sleep to limit frame rate
    {} <- Sleep.millis 10 |> Task.await

    # Clear the screen
    {} <- Stdout.write (ANSI.toStr ClearScreen) |> Task.await

    # Draw the screen
    {} <- drawScreen stateWithScreenUpdated drawFns |> Task.await

    # Get user input
    bytes <- Stdin.bytes |> Task.await

    command =
        when parseRawStdin bytes is
            Key Up -> MoveCursor Up
            Key Down -> MoveCursor Down
            Key Left -> MoveCursor Left
            Key Right -> MoveCursor Right
            Key Escape -> Exit
            Ctrl LetterC -> Exit
            _ -> UnsupportedInput

    # Handle input
    when command is
        MoveCursor direction ->
            # Move the cursor and step the game loop
            Task.ok (Step (updateCursor stateWithScreenUpdated direction))

        Exit ->
            # Exit the game loop
            Task.ok (Done stateWithScreenUpdated)

        UnsupportedInput ->
            # Clear the screen
            {} <- Stdout.write (ANSI.toStr ClearScreen) |> Task.await

            # dbg
            #     "UNSUPPORTED INPUT DETECTED"

            # dbg
            #     bytes

            Task.ok (Done stateWithScreenUpdated)

DrawFn : State, { row : I32, col : I32 } -> Result Pixel {}
Pixel : { char : Str, fg : Color, bg : Color }

# Loop through each pixel in screen and build up a single string to write to stdout
drawScreen : State, List DrawFn -> Task {} []
drawScreen = \state, drawFns ->
    pixels =
        row <- List.range { start: At 1, end: At state.screen.height } |> List.map
        col <- List.range { start: At 1, end: At state.screen.width } |> List.map

        List.walkUntil
            drawFns
            { char: " ", fg: Default, bg: Default }
            \defaultPixel, drawFn ->
                when drawFn state { row, col } is
                    Ok pixel -> Break pixel
                    Err _ -> Continue defaultPixel

    pixels
    |> joinAllPixels
    |> Stdout.write

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
    |> Str.joinWith "\n"

joinPixelRow : { char : Str, fg : Color, bg : Color, lines : List Str }, List Pixel, Nat -> { char : Str, fg : Color, bg : Color, lines : List Str }
joinPixelRow = \{ char, fg, bg, lines }, pixelRow, row ->

    { rowStrs, prev } =
        List.walk
            pixelRow
            { rowStrs: List.withCapacity (List.len pixelRow), prev: { char, fg, bg } }
            joinPixels

    line =
        rowStrs
        |> Str.joinWith ""
        |> Str.withPrefix (ANSI.toStr (SetCursor { row: Num.toI32 (row + 1), col: 1 })) # Set cursor at the start of line

    { char: " ", fg: prev.fg, bg: prev.bg, lines: List.append lines line }

joinPixels : { rowStrs : List Str, prev : Pixel }, Pixel -> { rowStrs : List Str, prev : Pixel }
joinPixels = \{ rowStrs, prev }, curr ->
    pixelStr =
        # If there is a change in colors between pixels then append an ASCII escape
        curr.char
        |> \str -> if curr.fg != prev.fg then "\(ANSI.toStr (SetFgColor curr.fg))\(str)" else str
        |> \str -> if curr.bg != prev.bg then "\(ANSI.toStr (SetBgColor curr.bg))\(str)" else str

    { rowStrs: List.append rowStrs pixelStr, prev: curr }

drawBox : { r : I32, c : I32, w : I32, h : I32, fg ? Color, bg ? Color, char ? Str } -> DrawFn
drawBox = \{ r, c, w, h, fg ? Gray, bg ? Default, char ? "#" } -> \_, { row, col } ->

        startRow = r
        endRow = (r + h)
        startCol = c
        endCol = (c + w)

        if row == r && (col >= startCol && col < endCol) then
            # TOP BORDER
            Ok { char, fg, bg }
        else if row == (r + h - 1) && (col >= startCol && col < endCol) then
            # BOTTOM BORDER
            Ok { char, fg, bg }
        else if col == c && (row >= startRow && row < endRow) then
            # LEFT BORDER
            Ok { char, fg, bg }
        else if col == (c + w - 1) && (row >= startRow && row < endRow) then
            # RIGHT BORDER
            Ok { char, fg, bg }
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
drawCursor = \{ fg ? Default, bg ? Gray, char ? " " } -> \state, { row, col } ->
        if
            (row == state.cursor.row) && (col == state.cursor.col)
        then
            Ok { char, fg, bg }
        else
            Err {}

# NOTE ASSUME ASCII CHARACTERS
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

updateCursor : State, [Up, Down, Left, Right] -> State
updateCursor = \state, direction ->
    when direction is
        Up ->
            { state &
                cursor: {
                    row: ((state.cursor.row - 1 + state.screen.height - 1) % state.screen.height) + 1,
                    col: state.cursor.col,
                },
            }

        Down ->
            { state &
                cursor: {
                    row: ((state.cursor.row + state.screen.height) % state.screen.height) + 1,
                    col: state.cursor.col,
                },
            }

        Left ->
            { state &
                cursor: {
                    row: state.cursor.row,
                    col: ((state.cursor.col - 1 + state.screen.width - 1) % state.screen.width) + 1,
                },
            }

        Right ->
            { state &
                cursor: {
                    row: state.cursor.row,
                    col: ((state.cursor.col + state.screen.width) % state.screen.width) + 1,
                },
            }

expect updateCursor { cursor: { row: 0, col: 1 }, screen: { width: 10, height: 10 } } Up == { cursor: { row: 9, col: 1 }, screen: { width: 10, height: 10 } }
expect updateCursor { cursor: { row: 1, col: 1 }, screen: { width: 10, height: 10 } } Up == { cursor: { row: 10, col: 1 }, screen: { width: 10, height: 10 } }
expect updateCursor { cursor: { row: 0, col: 1 }, screen: { width: 10, height: 10 } } Up == { cursor: { row: 9, col: 1 }, screen: { width: 10, height: 10 } }
expect updateCursor { cursor: { row: 5, col: 5 }, screen: { width: 10, height: 10 } } Down == { cursor: { row: 6, col: 5 }, screen: { width: 10, height: 10 } }
expect updateCursor { cursor: { row: 9, col: 5 }, screen: { width: 10, height: 10 } } Down == { cursor: { row: 10, col: 5 }, screen: { width: 10, height: 10 } }
expect updateCursor { cursor: { row: 5, col: 5 }, screen: { width: 10, height: 10 } } Left == { cursor: { row: 5, col: 4 }, screen: { width: 10, height: 10 } }
expect updateCursor { cursor: { row: 5, col: 0 }, screen: { width: 10, height: 10 } } Left == { cursor: { row: 5, col: 9 }, screen: { width: 10, height: 10 } }
expect updateCursor { cursor: { row: 5, col: 5 }, screen: { width: 10, height: 10 } } Right == { cursor: { row: 5, col: 6 }, screen: { width: 10, height: 10 } }
expect updateCursor { cursor: { row: 5, col: 9 }, screen: { width: 10, height: 10 } } Right == { cursor: { row: 5, col: 10 }, screen: { width: 10, height: 10 } }
expect updateCursor { cursor: { row: 2, col: 0 }, screen: { width: 10, height: 10 } } Left == { cursor: { row: 2, col: 9 }, screen: { width: 10, height: 10 } }

parseCursorPosition : List U8 -> { row : I32, col : I32 }
parseCursorPosition = \bytes ->
    { val: row, rest: afterFirst } = takeNumber { val: 0, rest: List.dropFirst bytes 2 }
    { val: col } = takeNumber { val: 0, rest: List.dropFirst afterFirst 1 }

    { row, col }

# test "ESC[33;1R"
expect parseCursorPosition [27, 91, 51, 51, 59, 49, 82] == { col: 1, row: 33 }

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

# Requires TTY Raw Mode
# Set the cursor to 999,999
# Read the cursor position
# Leaves cursor in bottom right corner
getTerminalSize : Task { width : I32, height : I32 } []
getTerminalSize =
    [
        SetCursor { row: 999, col: 999 },
        GetCursor,
    ]
    |> List.map ANSI.toStr
    |> Str.joinWith ""
    |> Stdout.write
    |> Task.await \{} -> Stdin.bytes
    |> Task.map parseCursorPosition
    |> Task.map \{ row, col } -> { width: col, height: row }

parseRawStdin : List U8 -> _
parseRawStdin = \bytes ->
    when bytes is
        [27, 91, 65, ..] -> Key Up
        [27, 91, 66, ..] -> Key Down
        [27, 91, 67, ..] -> Key Right
        [27, 91, 68, ..] -> Key Left
        [27, ..] -> Key Escape
        [3, ..] -> Ctrl LetterC
        _ -> Key Unsupported

expect parseRawStdin [27, 91, 65] == Key Up
expect parseRawStdin [27] == Key Escape
