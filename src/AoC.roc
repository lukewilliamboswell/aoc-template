interface AoC
    exposes [Solution, display, filterByYearDay, getDescription]
    imports []

Solution : {
    year : U64,
    day : U64,
    title : Str,
    part1 : {} -> Result Str [NotImplemented, Error Str],
    part2 : {} -> Result Str [NotImplemented, Error Str],
}

display : Solution -> Str
display = \s -> "\(Num.toStr s.year) Day \(Num.toStr s.day): \(s.title)"

getDescription : List Solution, U64, U64 -> Result Str [NotAvailable]
getDescription = \solutions, year, day ->
    solutions 
    |> List.keepOks (filterByYearDay year day) 
    |> List.first
    |> Result.mapErr \_ -> NotAvailable
    |> Result.map display

filterByYearDay : U64, U64 -> (AoC.Solution -> Result AoC.Solution [DoesNotMatch])
filterByYearDay = \year, day ->
    \sol ->
        if sol.year == year && sol.day == day then
            Ok sol
        else
            Err DoesNotMatch