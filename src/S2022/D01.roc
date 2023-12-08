interface S2022.D01
    exposes [solution]
    imports ["2022-01.txt" as puzzleInput : Str, AoC]

solution : AoC.Solution
solution = { year: 2022, day: 1, title: "Calorie Counting", part1, part2, puzzleInput }

exampleInput =
    """
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
    """

part1 : Str -> Result Str [NotImplemented, Error Str]
part1 = \input ->

    elfCalories = parse input

    sortedCals =
        elfCalories
        |> List.map List.sum
        |> List.sortDesc

    highestCals <-
        sortedCals
        |> List.first
        |> Result.mapErr \ListWasEmpty -> Error "list was empty, nothin in inventory"
        |> Result.map

    "The Elf with the highest calories has \(Num.toStr highestCals) kCal"

expect part1 exampleInput == Ok "The Elf with the highest calories has 24000 kCal"

part2 : Str -> Result Str [NotImplemented, Error Str]
part2 = \input ->

    elfCalories = parse input

    sortedCals =
        elfCalories
        |> List.map List.sum
        |> List.sortDesc

    sumOfTopThree <-
        (
            when sortedCals is
                [first, second, third, ..] -> Ok (first + second + third)
                _ -> Err (Error "should have more than three elves")
        )
        |> Result.try

    Ok "Total kCal the Elves are carrying is \(Num.toStr sumOfTopThree)"

expect part2 exampleInput == Ok "Total kCal the Elves are carrying is 45000"

parse : Str -> List (List U64)
parse = \str ->
    str
    |> Str.split "\n\n"
    |> List.map \inventory ->
        inventory
        |> Str.split "\n"
        |> List.keepOks Str.toU64

expect parse exampleInput == [[1000, 2000, 3000], [4000], [5000, 6000], [7000, 8000, 9000], [10000]]
