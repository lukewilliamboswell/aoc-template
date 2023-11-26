interface S2022D01
    exposes [solution]
    imports ["input/2022-01.txt" as input : List U8, AoC]

solution : AoC.Solution
solution = { year : 2022, day : 1, part1, part2 }

part1 : {} -> Result Str [NotImplemented, Error Str]
part1 = \_ -> 
    if List.isEmpty input then 
        Err NotImplemented
    else 
        Err (Error "Something else")

part2 : {} -> Result Str [NotImplemented, Error Str]
part2 = \_ -> Err NotImplemented
