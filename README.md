# Advent of Code Template

Solve AoC puzzles using [Roc](https://www.roc-lang.org) 🤘

Roc is a [fast](https://www.roc-lang.org/fast), [friendly](https://www.roc-lang.org/friendly), and [functional](https://www.roc-lang.org/functional) language which makes it ideal for AoC.

You can find my solutions to previous years at [lukewilliamboswell/aoc](https://github.com/lukewilliamboswell/aoc). I try to keep these up to date with the latest version of roc as a resource for others, but also to test roc language features and help me find potential issues.

## Getting Started

To get started, make sure you have [installed roc](https://www.roc-lang.org/install).

This package provides a helper function `AoC.solve` that reads the problem input from STDIN, and runs your provided solutions for part 1 and part 2, and then prints the results with some helpful timing information.

```sh
$ roc 2020/01.roc < input/2020_01.txt
--- ADVENT OF CODE 2020-1: Report Repair ---

INPUT:
Reading input from STDIN...

PART 1:
462 * 1558 = 719796

PART 2:
277 * 1359 * 384 = 144554112

TIMING:
READING INPUT:  1ms
SOLVING PART 1: <1ms
SOLVING PART 2: 209ms
---
```

A starter solution:

```roc
app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br",
    aoc: "https://github.com/lukewilliamboswell/aoc-template/releases/download/0.2.0/tlS1ZkwSKSB87_3poSOXcwHyySe0WxWOWQbPmp7rxBw.tar.br",
}

import pf.Stdin
import pf.Stdout
import pf.Utc
import aoc.AoC {
    stdin: Stdin.readToEnd,
    stdout: Stdout.write,
    time: \{} -> Utc.now {} |> Task.map Utc.toMillisSinceEpoch,
}

main =
    AoC.solve {
        year: 2020,
        day: 1,
        title: "Report Repair",
        part1,
        part2,
    }

## Implement your part1 and part2 solutions here
part1 : Str -> Result Str _
part1 = \_ -> Err TODO

part2 : Str -> Result Str _
part2 = \_ -> Err TODO
```

Example implementation:
```roc
part1 : Str -> Result Str Str
part1 = \input ->
    numbers = parseNumbers input

    combined =
        List.joinMap numbers \x ->
            List.map numbers \y ->
                { x, y, sum: x + y, mul: x * y }

    when List.keepIf combined \c -> c.sum == 2020 is
        [first, ..] -> Ok "$(Num.toStr first.x) * $(Num.toStr first.y) = $(Num.toStr first.mul)"
        _ -> Err "expected at least one pair to have sum of 2020"

part2 : Str -> Result Str Str
part2 = \input ->
    numbers = parseNumbers input

    combined =
        List.joinMap numbers \x ->
            List.joinMap numbers \y ->
                List.map numbers \z ->
                    { x, y, z, sum: x + y + z, mul: x * y * z }

    when List.keepIf combined \c -> c.sum == 2020 is
        [first, ..] -> Ok "$(Num.toStr first.x) * $(Num.toStr first.y) * $(Num.toStr first.z) = $(Num.toStr first.mul)"
        _ -> Err "expected at least one triple to have sum of 2020"

parseNumbers = \input -> input |> Str.splitOn "\n" |> List.keepOks Str.toU64
```
