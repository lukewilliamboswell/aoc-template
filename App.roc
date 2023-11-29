interface App
    exposes [
        solutions,
        solvePuzzle,
    ]
    imports [
        AoC,
        S2022.D01,
        S2022.D02,
        S2022.D03,
        S2023.D01,
    ]

## Export a list of the solutions included in this app
solutions : List AoC.Solution
solutions = 
    [
        S2022.D01.solution,
        S2023.D01.solution,
        S2022.D03.solution,
        S2022.D02.solution,
    ]
    |> List.sortWith sortByYearAndDay

solvePuzzle : { year : U64, day : U64, puzzle : [Part1, Part2] } -> Result Str [NotImplemented, Error Str]
solvePuzzle = \selection ->

    result = solutions |> List.keepOks (filterSolutions selection.year selection.day) |> List.first

    when (selection.puzzle, result) is
        (Part1, Ok solution) -> solution.part1 {}
        (Part2, Ok solution) -> solution.part2 {}
        (_, Err ListWasEmpty) -> Err (Error "Selected puzzle not available")

filterSolutions : U64, U64 -> (AoC.Solution -> Result AoC.Solution [DoesNotMatch])
filterSolutions = \year, day ->
    \sol ->
        if sol.year == year && sol.day == day then
            Ok sol
        else
            Err DoesNotMatch

sortByYearAndDay : AoC.Solution, AoC.Solution -> [LT, EQ, GT]
sortByYearAndDay = \first, second -> 
    if first.year < second.year then 
        GT
    else if first.year > second.year then 
        LT
    else if first.day < second.day then 
        GT
    else if first.day > second.day then 
        LT
    else 
        EQ