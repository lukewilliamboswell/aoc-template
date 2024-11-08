# Advent of Code Template

Solve AoC puzzles using [Roc](https://www.roc-lang.org) 🤘

Roc is a [fast](https://www.roc-lang.org/fast), [friendly](https://www.roc-lang.org/friendly), and [functional](https://www.roc-lang.org/functional) language which makes it ideal for AoC.

You can find my solutions to previous years at [lukewilliamboswell/aoc](https://github.com/lukewilliamboswell/aoc). I try to keep these up to date with the latest version of roc as a resource for others, but also to test roc language features and help me find potential issues.

## Getting Started

To get started, make sure you have [installed roc](https://www.roc-lang.org/install).

This package provides a helper function `Aoc.solve!` that reads the problem input from STDIN, and runs your provided solutions for part 1 and part 2, and then prints the results with some helpful timing information.

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

This package assumes you have a [roc-lang/basic-cli](https://github.com/roc-lang/basic-cli) app (although that is not strictly necessary).

A starter solution might look like this:

```roc
app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.16.0/O00IPk-Krg_diNS2dVWlI0ZQP794Vctxzv0ha96mK0E.tar.br",
    aoc: "https://github.com/lukewilliamboswell/aoc-template/releases/download/0.1.0/DcTQw_U67F22cX7pgx93AcHz_ShvHRaFIFjcijF3nz0.tar.br",
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

## Implement your part1 and part1 solutions here
part1 : Str -> Result Str _
part1 = \_ -> Err TODO

part2 : Str -> Result Str _
part2 = \_ -> Err TODO
```
