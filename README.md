# Advent of Code Template

A package to help solve AoC puzzles using [Roc](https://www.roc-lang.org) 🤘

Roc is a [fast](https://www.roc-lang.org/fast), [friendly](https://www.roc-lang.org/friendly), and [functional](https://www.roc-lang.org/functional) language which makes it ideal for AoC.

To get started, make sure you have [installed roc](https://www.roc-lang.org/install), and then you can use this package to help solve the puzzles.

```sh
$ roc examples/2020/01.roc < examples/input/2020_01.txt
--- ADVENT OF CODE 2020-1: Report Repair ---

INPUT:
Reading input from STDIN...

PART 1:
1939 * 81 = 157059

PART 2 ERROR:
"expected at least one triple to have sum of 2020"

TIMING:
READING INPUT:  <1ms
SOLVING PART 1: <1ms
SOLVING PART 2: 14ms
---
```

This package assumes you have a [roc-lang/basic-cli](https://github.com/roc-lang/basic-cli) app (although that is not strictly necessary).

A starter solution might look like;

```roc
app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    aoc: "https://github.com/lukewilliamboswell/aoc-template/releases/download/0.1.0/DcTQw_U67F22cX7pgx93AcHz_ShvHRaFIFjcijF3nz0.tar.br",
}

import pf.Stdin
import pf.Stdout
import pf.Utc
import aoc.AoC {
    stdin: Stdin.bytes,
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
## e.g.
part1 : Str -> Result Str [TODO]
part1 = \_ -> TODO

part2 : Str -> Result Str [TODO]
part2 = \_ -> TODO
```
