app "AoC"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
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
    provides [main] to pf

Model : {
    screen : ScreenSize,
    cursor : Position,
    solutions : List AoC.Solution,
    prevDraw : Utc,
    currDraw : Utc,
    inputs : List Input,
    debug : Bool,
    state : [HomePage, ConfirmPage AoC.Solution, RunSolution AoC.Solution, UserExited],
}

init : Model
init = {
    cursor: { row: 3, col: 3 },
    screen: { width: 0, height: 0 },
    solutions: App.solutions,
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
        ConfirmPage solution ->
            List.join [
                confirmScreen state solution,
                debug,
            ]

        _ ->
            List.join [
                homeScreen state,
                debug,
            ]

main : Task {} *
main = runTask |> Task.onErr \_ -> Stdout.line "ERROR Something went wrong"

runTask : Task {} []
runTask =

    # TUI Dashboard
    {} <- Tty.enableRawMode |> Task.await
    model <- Task.loop init runUILoop |> Task.await

    # Restore terminal
    {} <- Stdout.write (ANSI.toStr Reset) |> Task.await
    {} <- Tty.disableRawMode |> Task.await

    # EXIT or RUN selected solution 
    when model.state is 
        RunSolution s -> 
            runSolution s
        _ ->
            {} <- Stdout.line "Exiting... wishing you a very Merry Christmas!" |> Task.await
            Task.ok {}

runUILoop : Model -> Task [Step Model, Done Model] []
runUILoop = \prevModel ->

    # Get the time of this draw
    now <- Utc.now |> Task.await

    # Update screen size (in case it was resized since the last draw)
    terminalSize <- getTerminalSize |> Task.await

    # Update the model with screen size and time of this draw
    model = { prevModel & screen: terminalSize, prevDraw: prevModel.currDraw, currDraw: now }

    # Draw the screen
    drawFns = render model
    {} <- ANSI.drawScreen model drawFns |> Stdout.write |> Task.await

    # Get user input
    input <- Stdin.bytes |> Task.map ANSI.parseRawStdin |> Task.await

    # Parse user input into a command
    command =
        when (input, model.state) is
            (KeyPress Up, _) -> MoveCursor Up
            (KeyPress Down, _) -> MoveCursor Down
            (KeyPress Left, _) -> MoveCursor Left
            (KeyPress Right, _) -> MoveCursor Right
            (KeyPress LowerD, _) -> ToggleDebug
            (KeyPress Enter, HomePage) -> UserToggledScreen
            (KeyPress Enter, ConfirmPage s) -> UserWantToRunSolution s
            (KeyPress Escape, ConfirmPage _) -> UserToggledScreen
            (KeyPress Escape, _) -> Exit
            (KeyPress _, _) -> Nothing
            (Unsupported _, _) -> Nothing
            (CtrlC, _) -> Exit

    # Update model so we can keep a history of user input
    modelWithInput = { model & inputs: List.append model.inputs input }

    # Action command
    when command is
        Nothing -> Task.ok (Step modelWithInput)
        Exit -> Task.ok (Done {modelWithInput & state: UserExited})
        ToggleDebug -> Task.ok (Step { modelWithInput & debug: !modelWithInput.debug })
        MoveCursor direction -> Task.ok (Step (ANSI.updateCursor modelWithInput direction))
        UserWantToRunSolution s -> Task.ok (Done {modelWithInput & state: RunSolution s})
        UserToggledScreen -> 
            when modelWithInput.state is
                HomePage -> 
                    result = getSelected modelWithInput

                    when result is
                        Ok s -> Task.ok (Step {modelWithInput & state: ConfirmPage s})
                        Err NothingSelected -> Task.ok (Step modelWithInput)
    
                _ -> Task.ok (Step {modelWithInput & state: HomePage})
        

mapSelected : Model -> List {selected: Bool, s: AoC.Solution, row: I32}
mapSelected = \model ->
    s, idx <- List.mapWithIndex model.solutions
               
    row = 3 + (Num.toI32 idx)

    { selected: model.cursor.row == row, s, row }

getSelected : Model -> Result AoC.Solution [NothingSelected]
getSelected = \model -> 
    mapSelected model
    |> List.keepOks \{selected, s} -> if selected then Ok s else Err {}
    |> List.first
    |> Result.mapErr \_ -> NothingSelected

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
homeScreen = \model ->
    [
        [
            ANSI.drawCursor { bg: Green },
            ANSI.drawText " Advent of Code" { r: 1, c: 1, fg: Green },
            ANSI.drawText "RUN" { r: 2, c: 11, fg: Blue },
            ANSI.drawText "QUIT" { r: 2, c: 26, fg: Red },
            ANSI.drawText " ENTER TO RUN, ESCAPE TO QUIT" { r: 2, c: 1, fg: Gray },
            ANSI.drawBox { r: 0, c: 0, w: model.screen.width, h: model.screen.height },
        ],
        (
            { selected, s, row } <- model |> mapSelected |> List.map 

            if selected then
                ANSI.drawText " > \(AoC.display s)" { r: row, c: 2, fg: Green }
            else
                ANSI.drawText " - \(AoC.display s)" { r: row, c: 2, fg: Black }
        )
    ]
    |> List.join

confirmScreen : Model, AoC.Solution -> List DrawFn
confirmScreen = \state, solution -> 
    [
        ANSI.drawCursor { bg: Green },
        ANSI.drawText " Would you like to run \(AoC.display solution)?" { r: 1, c: 1, fg: Yellow },
        ANSI.drawText "CONFIRM" { r: 2, c: 11, fg: Blue },
        ANSI.drawText "RETURN" { r: 2, c: 30, fg: Red },
        ANSI.drawText " ENTER TO CONFIRM, ESCAPE TO RETURN" { r: 2, c: 1, fg: Gray },
        ANSI.drawText " title: \(solution.title)" { r: 3, c: 1 },
        ANSI.drawText " year: \(Num.toStr solution.year)" { r: 4, c: 1 },
        ANSI.drawText " day: \(Num.toStr solution.day)" { r: 5, c: 1 },
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

runSolution : AoC.Solution -> Task {} []
runSolution = \solution ->

    start <- Utc.now |> Task.await

    {} <- Stdout.write (ANSI.withFg "Running Part 1..." Gray) |> Task.await

    partOneResult = solution.part1 {}

    mid <- Utc.now |> Task.await

    {} <- Stdout.write (ANSI.withFg "done\nRunning Part 2..." Gray) |> Task.await

    partTwoResult = solution.part2 {}

    end <- Utc.now |> Task.await

    {} <- Stdout.write (ANSI.withFg "done\n" Gray) |> Task.await

    header = ANSI.withFg "Solution for \(AoC.display solution)" Blue
    year = ANSI.withFg "\(Num.toStr solution.year)" Blue
    day = ANSI.withFg "\(Num.toStr solution.day)" Blue
    part1 = solutionResultToStr partOneResult
    part2 = solutionResultToStr partTwoResult
    part1Time = ANSI.withFg (deltaToStr start mid) Blue
    part2Time = ANSI.withFg (deltaToStr mid end) Blue
    totalTime = ANSI.withFg (deltaToStr start end) Blue
    
    """
    ---------------------------------
    \(header)
    ---------------------------------
    year: \(year)
    day: \(day)
    total time: \(totalTime)

    Part 1 calculated in \(part1Time)
    ---------------------------------
    \(part1)

    Part 2 calculated in \(part2Time)
    ---------------------------------
    \(part2)

    """
    |> Stdout.line

solutionResultToStr : Result Str [NotImplemented, Error Str] -> Str
solutionResultToStr = \result ->
    when result is
        Ok answer -> answer
        Err NotImplemented -> "TODO - NOT YET IMPLEMENTED"
        Err (Error msg) -> "ERROR \(msg)"

deltaToStr : Utc, Utc -> Str
deltaToStr = \start, end ->
   millis = Utc.deltaAsMillis start end 

   if millis == 0 then
       "<0 ms"
   else
    Num.toStr millis
   