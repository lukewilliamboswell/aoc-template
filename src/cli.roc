app "AoC"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.2/c7T4Hp8bAdWz3r9ZrhboBzibCjJag8d0IP_ljb42yVc.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Stdin,
        pf.Tty,
        pf.Task.{ Task },
        ANSI.{ Color, Input, ScreenSize, Position, DrawFn },
        pf.Utc.{ Utc },
        App,
        AoC,
    ]
    provides [main, debugScreen] to pf

Model : {
    screen : ScreenSize,
    cursor : Position,
    puzzles : List AoC.Solution,
    prevDraw : Utc,
    currDraw : Utc,
    inputs : List Input,
    debug : Bool,
    state : [HomePage, SolutionResult],
}

switchState : Model -> Model
switchState = \model ->
    when model.state is
        HomePage -> { model & state: SolutionResult }
        SolutionResult -> { model & state: HomePage }

init : Model
init = {
    cursor: { row: 3, col: 3 },
    screen: { width: 0, height: 0 },
    puzzles: App.solutions,
    prevDraw: Utc.fromMillisSinceEpoch 0,
    currDraw: Utc.fromMillisSinceEpoch 0,
    inputs: List.withCapacity 1000,
    debug: Bool.false,
    state: HomePage,
}

render : Model -> List DrawFn
render = \state ->
    # PRESS 'd' to toggle debug screen
    debug = if state.debug then debugScreen state else []

    when state.state is
        HomePage ->
            List.join [
                homeScreen state,
                debug,
            ]

        SolutionResult ->
            List.join [
                resultScreen state,
                debug,
            ]

main : Task {} *
main = runTask |> Task.onErr \_ -> Stdout.line "ERROR Something went wrong"

runTask : Task {} []
runTask =

    # Enable Raw Mode
    {} <- Tty.enableRawMode |> Task.await

    # Run App Loop
    _ <- Task.loop init runLoop |> Task.await

    # Restore TTY Mode
    {} <- Tty.disableRawMode |> Task.await

    # Exit
    Task.ok {}

runLoop : Model -> Task [Step Model, Done Model] []
runLoop = \prevState ->

    # Get the time of this draw
    now <- Utc.now |> Task.await

    # Update screen size (in case it was resized since the last draw)
    terminalSize <- getTerminalSize |> Task.await

    # Update the State with screen size and time of this draw
    state = { prevState & screen: terminalSize, prevDraw: prevState.currDraw, currDraw: now }

    # Draw the screen
    drawFns = render state
    {} <- ANSI.drawScreen state drawFns |> Stdout.write |> Task.await

    # Get user input
    input <- Stdin.bytes |> Task.map ANSI.parseRawStdin |> Task.await

    # Parse user input into a command
    command =
        when input is
            KeyPress Escape -> Exit
            CtrlC -> Exit
            KeyPress Up -> MoveCursor Up
            KeyPress Down -> MoveCursor Down
            KeyPress Left -> MoveCursor Left
            KeyPress Right -> MoveCursor Right
            KeyPress LowerD -> ToggleDebug
            KeyPress Enter -> RunSolution
            Unsupported _ -> Nothing
            KeyPress _ -> Nothing

    # Update state so we can keep a history of user input
    stateWithInput = { state & inputs: List.append state.inputs input }

    # Action command
    when command is
        Nothing -> Task.ok (Step stateWithInput)
        Exit -> Task.ok (Done stateWithInput)
        ToggleDebug -> Task.ok (Step { stateWithInput & debug: !stateWithInput.debug })
        MoveCursor direction -> Task.ok (Step (ANSI.updateCursor stateWithInput direction))
        RunSolution -> 



            # Run the solution

            Task.ok (Step (switchState stateWithInput))

getTerminalSize : Task ScreenSize []
getTerminalSize =

    # Move the cursor to bottom right corner of terminal
    cmd = [SetCursor { row: 999, col: 999 }, GetCursor] |> List.map ANSI.toStr |> Str.joinWith ""
    {} <- Stdout.write cmd |> Task.await

    # Read the cursor position
    Stdin.bytes
    |> Task.map ANSI.parseCursor
    |> Task.map \{ row, col } -> { width: col, height: row }

homeScreen : Model -> List DrawFn
homeScreen = \state ->
    [
        [
            ANSI.drawCursor { bg: Green },
            ANSI.drawText " Advent of Code Solutions" { r: 1, c: 1, fg: Green },
            ANSI.drawText " ENTER TO RUN, ESCAPE TO QUIT" { r: 2, c: 1, fg: Gray },
            ANSI.drawBox { r: 0, c: 0, w: state.screen.width, h: state.screen.height },
        ],
        List.mapWithIndex state.puzzles \puzzle, idx ->
            row = 3 + (Num.toI32 idx)
            if (state.cursor.row == row) then
                # Selected puzzle
                ANSI.drawText " - \(puzzle.title)" { r: row, c: 2, fg: Green }
            else
                ANSI.drawText " - \(puzzle.title)" { r: row, c: 2, fg: Black },
    ]
    |> List.join

resultScreen : Model -> List DrawFn
resultScreen = \state -> [
    ANSI.drawCursor { bg: Green },
    ANSI.drawText " Solution for AoC 2022 Day 1" { r: 1, c: 1, fg: Green },
    ANSI.drawText " ENTER TO RETURN TO HOME, ESCAPE TO QUIT" { r: 2, c: 1, fg: Gray },
    ANSI.drawText " Part 1:" { r: 3, c: 1, fg: Black },
    ANSI.drawText " Part 2:" { r: 4, c: 1, fg: Black },
    ANSI.drawBox { r: 0, c: 0, w: state.screen.width, h: state.screen.height },
]

debugScreen : Model -> List DrawFn
debugScreen = \state ->
    cursorStr = "CURSOR R\(Num.toStr state.cursor.row), C\(Num.toStr state.cursor.col)"
    screenStr = "SCREEN H\(Num.toStr state.screen.height), W\(Num.toStr state.screen.width)"
    inputDelatStr = "DELTA \(Num.toStr (Utc.deltaAsMillis state.prevDraw state.currDraw)) millis"
    lastInput =
        state.inputs
        |> List.last
        |> Result.map ANSI.inputToStr
        |> Result.map \str -> "INPUT \(str)"
        |> Result.withDefault "NO INPUT YET"

    [
        ANSI.drawText lastInput { r: state.screen.height - 5, c: 1, fg: Magenta },
        ANSI.drawText inputDelatStr { r: state.screen.height - 4, c: 1, fg: Magenta },
        ANSI.drawText cursorStr { r: state.screen.height - 3, c: 1, fg: Magenta },
        ANSI.drawText screenStr { r: state.screen.height - 2, c: 1, fg: Magenta },
        ANSI.drawVLine { r: 1, c: state.screen.width // 2, len: state.screen.height, fg: Gray },
        ANSI.drawHLine { c: 1, r: state.screen.height // 2, len: state.screen.width, fg: Gray },
    ]

    #  { year : U64, day : U64, puzzle : [Part1, Part2] } -> Result Str [NotImplemented, Error Str]
# runSolution : Result {} []
# runSolution = 
#     when App.solvePuzzle { year: 2022, day: 1, puzzle: Part1 } is
#         Ok answer ->
#             header = Color.fg "Advent of Code Solution" Green
#             year = Color.fg "\(Num.toStr 2022)" Green
#             day = Color.fg "\(Num.toStr 1)" Green
#             part = Color.fg "1" Green
#             time = Color.fg "245ms" Green

#             """

#             --- \(header)
#             year: \(year)
#             day: \(day)
#             part: \(part)
#             time: \(time)
#             answer:

#             \(answer)
#             ---
#             """
#             |> Stdout.line

#         Err NotImplemented ->
#             [
#                 Color.fg "Advent of Code" Green,
#                 ":",
#                 Color.fg "\(Num.toStr 2022)-\(Num.toStr 1)-Part 1" Blue,
#                 ":",
#                 Color.fg "NOT IMPLEMENTED" Red,
#             ]
#             |> Str.joinWith ""
#             |> Stdout.line

#         Err (Error msg) ->
#             [
#                 Color.fg "Advent of Code" Green,
#                 ":",
#                 Color.fg "\(Num.toStr 2022)-\(Num.toStr 1)-Part 1" Blue,
#                 ":",
#                 Color.fg "ERROR \(msg)" Red,
#             ]
#             |> Str.joinWith ""
#             |> Stdout.line