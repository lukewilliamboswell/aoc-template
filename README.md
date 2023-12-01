# Advent of Code Template 

A template for AoC using [Roc](https://www.roc-lang.org) 🤘

Roc is a [fast](https://www.roc-lang.org/fast), [friendly](https://www.roc-lang.org/friendly), and [functional](https://www.roc-lang.org/functional) language which makes it ideal for AoC.  

All you need to get started is the `roc` executable. [Installing it](https://www.roc-lang.org/install) doesn't take long, and it ships with testing (`roc test`) and code formatting (`roc format`) already included.

The simplest setup is to make each day its own `.roc` file. 

For example, here's all you need for `day1`.

## day1.roc

```elm
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
```

You can run your solution from the terminal in the same directory as `day1.roc` with:

```sh
$ roc dev day1.roc
```

If you want to do an optimized build, run `roc run --optimize day1.roc` instead. This will take longer to build, but then the program will run faster.

To run tests, use:

```sh
$ roc test day1.roc 

0 failed and 1 passed in 277 ms.
```

This is all you need to solve AoC in Roc! 🎉 

## Optional: AoC CLI, TUI and Web Apps

If you'd like additional features that are specific to AoC, then this repository has several to choose from:
- A CLI App that prints the results to stdout `roc run src/cli.roc -- 2022 1`
- A TUI App with a graphical menu to choose a solution to run `roc src/tui.roc`
- A Web App for sharing your AoC solutions with your friends `roc src/web.roc`

The solutions for CLI, TUI and Web are common to all three applications. They are located in subfolders like `src/S2023/D01.roc`. 

To add another you can copy a previous solution, and include it in the `solutions` variable in `src/App.roc`.

```elm
solutions : List AoC.Solution
solutions = 
    [
        S2022.D01.solution,
        S2022.D02.solution,
        S2022.D03.solution,
        S2023.D01.solution,
    ]
    |> List.sortWith sortByYearAndDay
```