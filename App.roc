interface App
    exposes [solvePuzzle]
    imports [
        AoC,
        S2022D01,
    ]

## Export a list of the solutions included in this app
solutions : List AoC.Solution
solutions = [
    S2022D01.solution,
]

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
