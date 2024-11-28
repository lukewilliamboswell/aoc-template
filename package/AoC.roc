module { stdin, stdout, time } -> [Solution, solve]

Solution err : {
    year : U64,
    day : U64,
    title : Str,
    part1 : Str -> Result Str err,
    part2 : Str -> Result Str err,
} where err implements Inspect

solve : Solution err -> Task {} _
solve = \{ year, day, title, part1, part2 } ->

    stdout!
        (
            Str.joinWith
                [
                    green "--- ADVENT OF CODE ",
                    green "$(Num.toStr year)-$(Num.toStr day): $(title)",
                    green " ---\n\n",
                    blue "INPUT:\n",
                    "Reading input from STDIN...\n\n",
                ]
                ""
        )

    startRead = time! {}

    input : Str
    input = readInput!

    endRead = time! {}

    startPart1 = time! {}

    solutionPart1 : Result Str _
    solutionPart1 = part1 input

    endPart1 = time! {}

    partOneTask =
        when solutionPart1 is
            Ok str -> stdout (Str.joinWith [blue "PART 1:\n", "$(str)\n\n"] "")
            Err err ->
                stdout
                    (
                        Str.joinWith
                            [
                                red "PART 1 ",
                                red "ERROR:\n",
                                "$(Inspect.toStr err)\n\n",
                            ]
                            ""
                    )

    partOneTask!

    startPart2 = time! {}

    solutionPart2 : Result Str _
    solutionPart2 = part2 input

    endPart2 = time! {}

    partTwoTask =
        when solutionPart2 is
            Ok str -> stdout (Str.joinWith [blue "PART 2:\n", "$(str)\n\n"] "")
            Err err ->
                stdout
                    (
                        Str.joinWith
                            [
                                red "PART 2 ",
                                red "ERROR:\n",
                                "$(Inspect.toStr err)\n\n",
                            ]
                            ""
                    )

    partTwoTask!

    readMillis = if (endRead - startRead) < 1 then "<1" else Num.toStr (endRead - startRead)
    part1Millis = if (endPart1 - startPart1) < 1 then "<1" else Num.toStr (endPart1 - startPart1)
    part2Millis = if (endPart2 - startPart2) < 1 then "<1" else Num.toStr (endPart2 - startPart2)

    stdout!
        (
            Str.joinWith
                [
                    blue "TIMING:\n",
                    "READING INPUT:  ",
                    blue "$(readMillis)ms\n",
                    "SOLVING PART 1: ",
                    blue "$(part1Millis)ms\n",
                    "SOLVING PART 2: ",
                    blue "$(part2Millis)ms\n",
                    green "---\n",
                ]
                ""
        )

readInput : Result Str _
readInput =
    stdin {}
        |> Task.map Str.fromUtf8
        |> Task.mapErr! \_ -> InputIsNotValidUTF8

blue = \str -> "\u(001b)[0;34m$(str)\u(001b)[0m"
green = \str -> "\u(001b)[0;32m$(str)\u(001b)[0m"
red = \str -> "\u(001b)[0;31m$(str)\u(001b)[0m"
