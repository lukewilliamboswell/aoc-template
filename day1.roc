app "AoC"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br",
    }
    imports [pf.Stdout, pf.Task.{Task}, "day-1-input.txt" as input : Str]
    provides [main] to pf

main : Task {} *
main = Stdout.line part1

part1 : Str
part1 =
    elfCalories
    |> List.map List.sum
    |> List.sortDesc
    |> List.first
    |> Result.map \highestCals -> "The Elf with the highest calories has \(Num.toStr highestCals) kCal"
    |> Result.withDefault "Ooops there are no rucksacks to count"

elfCalories : List (List U64)
elfCalories = parse input

parse : Str -> List (List U64)
parse = \str ->
    inventory <- str |> Str.split "\n\n" |> List.map

    inventory |> Str.split "\n" |> List.keepOks Str.toU64

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
