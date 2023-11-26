app "AoC"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.2/c7T4Hp8bAdWz3r9ZrhboBzibCjJag8d0IP_ljb42yVc.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Task.{ Task },
        AoC,
        S2022D01,
    ]
    provides [main] to pf

solutions : List AoC.Solution
solutions = [
    S2022D01.solution,
]

main : Task {} *
main =
    when solutions |> solvePuzzle { year: 2022, day: 1, puzzle: Part1 } is
        Ok answer -> Stdout.line "Success: \(answer)"
        Err NotImplemented -> Stdout.line "Not implemented"
        Err (Error msg) -> Stdout.line "Something went wrong: \(msg)"

solvePuzzle : List AoC.Solution, { year : U64, day : U64, puzzle : [Part1, Part2] } -> Result Str [NotImplemented, Error Str]
solvePuzzle = \sols, selection ->

    result = sols |> List.keepOks (filterSolutions selection.year selection.day) |> List.first

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
