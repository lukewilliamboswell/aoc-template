interface S2022.D02
    exposes [solution]
    imports [AoC]

solution : AoC.Solution
solution = { year: 2022, day: 2, title: "Rock Paper Scissors", part1, part2 }

part1 : {} -> Result Str [NotImplemented, Error Str]
part1 = \_ -> Err NotImplemented

part2 : {} -> Result Str [NotImplemented, Error Str]
part2 = \_ -> Err NotImplemented
