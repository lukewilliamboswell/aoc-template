app "AoC"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.2/c7T4Hp8bAdWz3r9ZrhboBzibCjJag8d0IP_ljb42yVc.tar.br",
        colors: "https://github.com/lukewilliamboswell/roc-ansi-escapes/releases/download/0.1.1/cPHdNPNh8bjOrlOgfSaGBJDz6VleQwsPdW0LJK6dbGQ.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Stdin,
        pf.Sleep,
        pf.Tty,
        pf.Task.{ Task },
        colors.Color,
        # App,
    ]
    provides [main] to pf

State : {
    screen : { width : I32, height : I32},
    cursor : { row : I32, col : I32 },
}

init : State
init = 
    { 
        cursor: { row: 1, col: 1 },
        screen : { width : 0, height : 0 },
    }

main : Task {} *
main =
    task = 
        # Display Loading
        _ <- Task.loop 0 displayLoadingLoop |> Task.await

        # Enable TTY Raw mode
        {} <- Tty.enableRawMode |> Task.await

        # Run App Loop
        _ <- Task.loop init runLoop |> Task.await

        # Restore TTY Mode
        {} <- Tty.disableRawMode |> Task.await

        Task.ok {}

    task |> Task.onErr \_ -> crash "something died"

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

displayLoadingLoop : U32 -> Task [Step U32, Done U32] []
displayLoadingLoop = \i -> 

    # Move the cursor to the far left of screen
    {} <- Stdout.write (moveCursorANSI Left 1000) |> Task.await

    # Write the loading status
    {} <- Stdout.write (Color.fg "Loading puzzles: \(Num.toStr i)% ..." Green) |> Task.await

    # Sleep to limit frame rate and simulate loading
    {} <- Sleep.millis 25 |> Task.await

    # Loop until 100% "loaded"
    if i < 100 then
        Task.ok (Step (i+5))
    else
        Task.ok (Done i)

runLoop : State -> Task [Step State, Done State] []
runLoop = \state ->

    # Update screen size (in case it was resized since last draw)
    terminalSize <- getTerminalSize |> Task.await

    # Sleep to limit frame rate
    {} <- Sleep.millis 25 |> Task.await
    
    # Clear the screen
    {} <- Stdout.write clearScreenANSI |> Task.await

    # Draw the game 
    {} <- drawScreen {state & screen : terminalSize} [drawCursor "O", drawBorder "+"] |> Task.await

    # Get user input
    bytes <- Stdin.bytes |> Task.await

    command = when parseRawStdin bytes is 
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
            Task.ok (Step (updateCursor state direction))

        Exit -> 

            # Exit the game loop
            Task.ok (Done state)

        UnsupportedInput ->

            # Clear the screen
            {} <- Stdout.write clearScreenANSI |> Task.await

            dbg "UNSUPPORTED INPUT DETECTED"
            dbg bytes

            Task.ok (Done state)

DrawFn : State, { row : I32, col : I32 } -> Result Str {}

# Loop through each pixel in screen and build up a single string to write to stdout
drawScreen : State, List DrawFn -> Task {} *
drawScreen = \state, drawFns ->
    List.range {start: At 1, end: At state.screen.height} |> List.map \row ->
        List.range {start: At 1, end: At state.screen.width} |> List.map \col ->
            List.walkUntil 
                drawFns 
                " "
                (\pixelStr, drawFn ->
                    when drawFn state { row, col } is 
                        Ok str -> Break str
                        Err _ -> Continue pixelStr
                )
        |> Str.joinWith ""
        # Set cursor at the start, adjusting the map down on screen to make
        # room for the score and other info on first line
        |> Str.withPrefix (setCursorANSI {row: row, col: 1})
    |> Str.joinWith "\n"
    |> Stdout.write


drawBorder : Str -> DrawFn
drawBorder = \char -> \state, {row, col} -> 

    expect 1 == char |> Str.toUtf8 |> List.len # assert char is single character

    if row == 1 || row == state.screen.height then 
        Ok char
    else if col == 1 || col == state.screen.width then
        Ok char
    else
        Err {}

drawCursor : Str -> DrawFn
drawCursor = \char -> \state, {row, col} ->
    
    expect 1 == char |> Str.toUtf8 |> List.len # assert char is single character

    if (row - 1) == state.cursor.row 
    && (col - 1) == state.cursor.col then
        Ok (Color.fg char Blue)
    else
        Err {}

clearScreenANSI : Str
clearScreenANSI = "\u(001b)c"

setCursorANSI : {row: I32, col: I32} -> Str 
setCursorANSI = \{row, col} ->
    rowStr = row |> Num.toStr
    colStr = col |> Num.toStr

    "\u(001b)[\(rowStr);\(colStr)H"

moveCursorANSI : [Up, Down, Left, Right], I32 -> Str
moveCursorANSI = \direction, steps ->
    when direction is 
        Up -> "\u(001b)[\(Num.toStr steps)A"
        Down -> "\u(001b)[\(Num.toStr steps)B"
        Right -> "\u(001b)[\(Num.toStr steps)C"
        Left -> "\u(001b)[\(Num.toStr steps)D"

updateCursor : State, [Up, Down, Left, Right] -> State
updateCursor = \state, direction ->
    when direction is 
        Up -> 
            { state & 
                cursor: {
                    row: ((state.cursor.row + state.screen.height - 1) % state.screen.height), 
                    col: state.cursor.col,
                }
            }
        Down -> 
            { state & 
                cursor: {
                    row: ((state.cursor.row + 1) % state.screen.height), 
                    col: state.cursor.col,
                }
            }
        Left -> 
            { state & 
                cursor: {
                    row: state.cursor.row, 
                    col: ((state.cursor.col + state.screen.width - 1) % state.screen.width),
                }
            }
        Right -> 
            { state & 
                cursor: {
                    row: state.cursor.row, 
                    col: ((state.cursor.col + 1) % state.screen.width),
                }
            }

expect updateCursor { cursor: {row: 1, col: 1}, screen : {width: 10, height: 10} } Up == { cursor: {row: 0, col: 1}, screen : {width: 10, height: 10} }
expect updateCursor { cursor: {row: 0, col: 1}, screen : {width: 10, height: 10} } Up == { cursor: {row: 9, col: 1}, screen : {width: 10, height: 10} }
expect updateCursor { cursor: {row: 1, col: 1}, screen : {width: 10, height: 10} } Up == { cursor: {row: 0, col: 1}, screen : {width: 10, height: 10} }
expect updateCursor { cursor: {row: 0, col: 1}, screen : {width: 10, height: 10} } Up == { cursor: {row: 9, col: 1}, screen : {width: 10, height: 10} }
expect updateCursor { cursor: {row: 5, col: 5}, screen : {width: 10, height: 10} } Down == { cursor: {row: 6, col: 5}, screen : {width: 10, height: 10} }
expect updateCursor { cursor: {row: 9, col: 5}, screen : {width: 10, height: 10} } Down == { cursor: {row: 0, col: 5}, screen : {width: 10, height: 10} }
expect updateCursor { cursor: {row: 5, col: 5}, screen : {width: 10, height: 10} } Left == { cursor: {row: 5, col: 4}, screen : {width: 10, height: 10} }
expect updateCursor { cursor: {row: 5, col: 0}, screen : {width: 10, height: 10} } Left == { cursor: {row: 5, col: 9}, screen : {width: 10, height: 10} }
expect updateCursor { cursor: {row: 5, col: 5}, screen : {width: 10, height: 10} } Right == { cursor: {row: 5, col: 6}, screen : {width: 10, height: 10} }
expect updateCursor { cursor: {row: 5, col: 9}, screen : {width: 10, height: 10} } Right == { cursor: {row: 5, col: 0}, screen : {width: 10, height: 10} }
        
getCursorANSI : Str 
getCursorANSI = "\u(001b)[6n"

parseCursorPosition : List U8 -> { row : I32, col : I32 }
parseCursorPosition = \bytes -> 
    {val: row, rest: afterFirst} = takeNumber {val : 0, rest : List.dropFirst bytes 2 }
    {val: col } = takeNumber {val : 0, rest : List.dropFirst afterFirst 1 }

    {row, col}

# test "ESC[33;1R"
expect parseCursorPosition [27, 91, 51, 51, 59, 49, 82] == { row: 1, col: 33 }

takeNumber : {val : I32, rest : List U8 } -> {val : I32, rest : List U8 }
takeNumber = \in ->
    when in.rest is 
        [a, ..] if a == '0' -> takeNumber {val : in.val * 10 + 0, rest : List.dropFirst in.rest 1}
        [a, ..] if a == '1' -> takeNumber {val : in.val * 10 + 1, rest : List.dropFirst in.rest 1}
        [a, ..] if a == '2' -> takeNumber {val : in.val * 10 + 2, rest : List.dropFirst in.rest 1}
        [a, ..] if a == '3' -> takeNumber {val : in.val * 10 + 3, rest : List.dropFirst in.rest 1}
        [a, ..] if a == '4' -> takeNumber {val : in.val * 10 + 4, rest : List.dropFirst in.rest 1}
        [a, ..] if a == '5' -> takeNumber {val : in.val * 10 + 5, rest : List.dropFirst in.rest 1}
        [a, ..] if a == '6' -> takeNumber {val : in.val * 10 + 6, rest : List.dropFirst in.rest 1}
        [a, ..] if a == '7' -> takeNumber {val : in.val * 10 + 7, rest : List.dropFirst in.rest 1}
        [a, ..] if a == '8' -> takeNumber {val : in.val * 10 + 8, rest : List.dropFirst in.rest 1}
        [a, ..] if a == '9' -> takeNumber {val : in.val * 10 + 9, rest : List.dropFirst in.rest 1}
        _ -> in
            
expect takeNumber {val: 0, rest :[27, 91, 51, 51, 59, 49, 82] } == {val: 0, rest : [27, 91, 51, 51, 59, 49, 82] }
expect takeNumber {val: 0, rest :[51, 51, 59, 49, 82] } == {val: 33, rest : [59, 49, 82] }
expect takeNumber {val: 0, rest :[49, 82] } == {val: 1, rest : [82] }

# Requires TTY Raw Mode
# Set the cursor to 999,999
# Read the cursor position
# Leaves cursor in bottom right corner
getTerminalSize : Task {width : I32, height : I32} []
getTerminalSize = 
    [setCursorANSI { row: 999, col : 999}, getCursorANSI] 
    |> Str.joinWith ""
    |> Stdout.write
    |> Task.await \{} -> Stdin.bytes 
    |> Task.map parseCursorPosition
    |> Task.map \{ row, col } -> {width: col, height:row}

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
    