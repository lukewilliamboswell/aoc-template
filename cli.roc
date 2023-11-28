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
        pf.Utc.{ Utc },
        # App,
    ]
    provides [main] to pf

ScreenSize : { width : I32, height : I32 }
Position : { row : I32, col : I32 }

Model : {
    screen : ScreenSize,
    cursor : Position,
    puzzles : List Str,
    prevDraw : Utc,
    currDraw : Utc,
}

init : Model
init = {
    cursor: { row: 3, col: 3 },
    screen: { width: 0, height: 0 },
    puzzles: [
        "2022 Day 1: Calorie Counting Part 1",
        "2022 Day 1: Calorie Counting Part 2",
        "2022 Day 2: Rock Paper Scissors Part 1",
        "2022 Day 2: Rock Paper Scissors Part 2",
        "2022 Day 3: Rucksack Reorganization Part 1",
        "2022 Day 3: Rucksack Reorganization Part 2",
    ],
    prevDraw: Utc.fromMillisSinceEpoch 0,
    currDraw: Utc.fromMillisSinceEpoch 0,
}

render : Model -> List DrawFn
render = \state ->
    cursorStr = "CURSOR \(Num.toStr state.cursor.row), \(Num.toStr state.cursor.col)"
    screenStr = "SCREEN \(Num.toStr state.screen.height), \(Num.toStr state.screen.width) TOTAL PIXELS \(Num.toStr (state.screen.height * state.screen.width))"
    inputDelatStr = "INPUT DELTA \(Num.toStr (Utc.deltaAsMillis state.prevDraw state.currDraw))ms"
    [
        drawText " Advent of Code Puzzles" { r: 1, c: 1, fg: Green },
        drawCursor { bg: Green },
        drawText inputDelatStr { r: state.screen.height - 4, c: 1, fg: Magenta },
        drawText cursorStr { r: state.screen.height - 3, c: 1, fg: Magenta },
        drawText screenStr { r: state.screen.height - 2, c: 1, fg: Magenta },
        drawBox { r: 0, c: 0, w: state.screen.width, h: state.screen.height }, # border
        drawVLine { r: 1, c: state.screen.width // 2, len: state.screen.height, fg: Blue },
        drawHLine { c: 1, r: state.screen.height // 2, len: state.screen.width, fg: Blue },
    ]
    |> List.concat
        (
            List.mapWithIndex state.puzzles \puzzleStr, idx ->
                row = 3 + (Num.toI32 idx)
                if (state.cursor.row == row) then
                    # Selected puzzle
                    drawText " - \(puzzleStr)" { r: row, c: 2, fg: Green }
                else
                    drawText " - \(puzzleStr)" { r: row, c: 2, fg: Gray }
        )

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

    # Exit
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

runLoop : Model -> Task [Step Model, Done Model] []
runLoop = \prevState ->

    # Get the time for this draw
    now <- Utc.now |> Task.await

    # Update screen size (in case it was resized since last draw)
    terminalSize <- getTerminalSize |> Task.await

    # Update State for this draw
    state = { prevState & screen: terminalSize, prevDraw: prevState.currDraw, currDraw: now }

    # Sleep to limit frame rate
    {} <- Sleep.millis 5 |> Task.await

    # Draw the screen
    drawFns = render state
    {} <- drawScreen state drawFns |> Task.await

    # Get user input
    bytes <- Stdin.bytes |> Task.await

    command =
        when parseRawStdin bytes is
            Key Up -> MoveCursor Up
            Key Down -> MoveCursor Down
            Key Left -> MoveCursor Left
            Key Right -> MoveCursor Right
            Key Escape -> Exit
            Key Enter -> Nothing
            Ctrl LetterC -> Exit
            _ -> UnsupportedInput

    # Handle input
    when command is
        MoveCursor direction ->
            # Move the cursor and step the game loop
            Task.ok (Step (updateCursor state direction))

        Exit ->
            # Exit the game loop
            Task.ok (Done state)

        UnsupportedInput ->
            # Clear the screen
            {} <- Stdout.write (ANSI.toStr ClearScreen) |> Task.await

            dbg
                T "UNSUPPORTED INPUT DETECTED" bytes

            Task.ok (Done state)

        Nothing -> Task.ok (Step state)

DrawFn : Model, Position -> Result Pixel {}
Pixel : { char : Str, fg : Color, bg : Color }

# Loop through each pixel in screen and build up a single string to write to stdout
drawScreen : Model, List DrawFn -> Task {} []
drawScreen = \state, drawFns ->
    pixels =
        row <- List.range { start: At 0, end: Before state.screen.height } |> List.map
        col <- List.range { start: At 0, end: Before state.screen.width } |> List.map

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
        |> Str.withPrefix (ANSI.toStr (SetCursor { row: Num.toI32 (row + 1), col: 0 }))

    { char: " ", fg: prev.fg, bg: prev.bg, lines: List.append lines line }

joinPixels : { rowStrs : List Str, prev : Pixel }, Pixel -> { rowStrs : List Str, prev : Pixel }
joinPixels = \{ rowStrs, prev }, curr ->
    pixelStr =
        # Prepend an ASCII escape ONLY if there is a change between pixels
        curr.char
        |> \str -> if curr.fg != prev.fg then Str.concat (ANSI.toStr (SetFgColor curr.fg)) str else str
        |> \str -> if curr.bg != prev.bg then Str.concat (ANSI.toStr (SetBgColor curr.bg)) str else str

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
drawCursor = \{ fg ? Default, bg ? Gray, char ? " " } -> \state, { row, col } ->
        if
            (row == state.cursor.row) && (col == state.cursor.col)
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

updateCursor : Model, [Up, Down, Left, Right] -> Model
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

parseCursorPosition : List U8 -> Position
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

getTerminalSize : Task ScreenSize []
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
        [13, ..] -> Key Enter
        [3, ..] -> Ctrl LetterC
        _ -> Key Unsupported

expect parseRawStdin [27, 91, 65] == Key Up
expect parseRawStdin [27] == Key Escape
