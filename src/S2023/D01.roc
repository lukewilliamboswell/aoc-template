interface S2023.D01
    exposes [solution]
    imports [AoC]

solution : AoC.Solution
solution = { year: 2023, day: 1, title: "(Coming Soon)", part1, part2, puzzleInput: "" }

part1 : Str -> Result Str [NotImplemented, Error Str]
part1 = \_ -> Err NotImplemented

part2 : Str -> Result Str [NotImplemented, Error Str]
part2 = \_ -> Err NotImplemented
