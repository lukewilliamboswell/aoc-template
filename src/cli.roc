app "AoC"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Arg,
        pf.Task.{ Task },
        pf.Utc.{ Utc },
        ANSI,
        App,
        AoC,
    ]
    provides [main] to pf

main : Task {} *
main = runTask |> Task.onErr handlErr

handlErr : [UnableToParseArgs] -> Task {} *
handlErr = \err ->
    when err is
        UnableToParseArgs -> Stdout.line "Unable to parse args, usage 'roc run src/cli.roc -- <year> <day>'"

runTask : Task {} [UnableToParseArgs]
runTask =

    { yearArg, dayArg } <- getArgs |> Task.await

    start <- Utc.now |> Task.await

    {} <- Stdout.write (ANSI.withFg "Running Part 1..." Gray) |> Task.await

    partOneResult = App.solvePuzzle { year: yearArg, day: dayArg, puzzle: Part1 }

    mid <- Utc.now |> Task.await

    {} <- Stdout.write (ANSI.withFg "done\nRunning Part 2..." Gray) |> Task.await

    partTwoResult = App.solvePuzzle { year: yearArg, day: dayArg, puzzle: Part2 }

    end <- Utc.now |> Task.await

    {} <- Stdout.write (ANSI.withFg "done\n" Gray) |> Task.await

    description = AoC.getDescription App.solutions yearArg dayArg |> Result.withDefault "unreachable"
    header = ANSI.withFg "Solution for \(description)" Blue
    year = ANSI.withFg "\(Num.toStr yearArg)" Blue
    day = ANSI.withFg "\(Num.toStr dayArg)" Blue
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

    Part 1 calculated in \(part1Time) ms
    ---------------------------------
    \(part1)

    Part 2 calculated in \(part2Time) ms
    ---------------------------------
    \(part2)

    """
    |> Stdout.line

getArgs : Task { yearArg : U64, dayArg : U64 } [UnableToParseArgs]
getArgs =
    args <- Arg.list |> Task.await

    when args is
        [_, first, second, ..] ->
            when (Str.toU64 first, Str.toU64 second) is
                (Ok yearArg, Ok dayArg) -> Task.ok { yearArg, dayArg }
                _ -> Task.err UnableToParseArgs

        _ -> Task.err UnableToParseArgs

solutionResultToStr : Result Str [NotImplemented, Error Str] -> Str
solutionResultToStr = \result ->
    when result is
        Ok answer -> answer
        Err NotImplemented -> "not yet implemented"
        Err (Error msg) -> "returned an error: \(msg)"

deltaToStr : Utc, Utc -> Str
deltaToStr = \start, end ->
    millis = Utc.deltaAsMillis start end

    if millis == 0 then
        "<0"
    else
        Num.toStr millis
