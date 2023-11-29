interface AoC
    exposes [Solution, display]
    imports []

Solution : {
    year : U64,
    day : U64,
    title : Str,
    part1 : {} -> Result Str [NotImplemented, Error Str],
    part2 : {} -> Result Str [NotImplemented, Error Str],
}

display : Solution -> Str
display = \s -> "AoC \(Num.toStr s.year)-\(Num.toStr s.day): \(s.title)"

