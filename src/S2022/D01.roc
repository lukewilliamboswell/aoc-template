interface S2022.D01
    exposes [solution]
    imports ["2022-01.txt" as input : Str, AoC]

solution : AoC.Solution
solution = { year: 2022, day: 1, title: "Calorie Counting", part1, part2 }

elfCalories = parse input

part1 : {} -> Result Str [NotImplemented, Error Str]
part1 = \_ ->
    elfCalories
    |> List.map List.sum
    |> List.sortDesc
    |> List.first
    |> Result.mapErr \ListWasEmpty -> Error "list was empty, nothin in inventory"
    |> Result.map \highestCals -> "The Elf with the highest calories has \(Num.toStr highestCals) kCal"

part2 : {} -> Result Str [NotImplemented, Error Str]
part2 = \_ -> Err NotImplemented

parse : Str -> List (List U64)
parse = \str ->

    inventory <- str |> Str.split "\n\n" |> List.map

    inventory
    |> Str.split "\n"
    |> List.keepOks Str.toU64

expect parse example == [[1000, 2000, 3000], [4000], [5000, 6000], [7000, 8000, 9000], [10000]]

example : Str
example =
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
