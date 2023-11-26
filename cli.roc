app "AoC"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.2/c7T4Hp8bAdWz3r9ZrhboBzibCjJag8d0IP_ljb42yVc.tar.br",
        colors: "https://github.com/lukewilliamboswell/roc-ansi-escapes/releases/download/0.1.1/cPHdNPNh8bjOrlOgfSaGBJDz6VleQwsPdW0LJK6dbGQ.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Task.{ Task },
        colors.Color,
        AoC,
        App,
    ]
    provides [main] to pf



main : Task {} *
main =
    when App.solutions |> solvePuzzle { year: 2022, day: 1, puzzle: Part1 } is
        Ok answer ->
            header = Color.fg "Advent of Code Solution" Green
            year = Color.fg "\(Num.toStr 2022)" Green
            day = Color.fg "\(Num.toStr 1)" Green
            part = Color.fg "1" Green
            time = Color.fg "245ms" Green

            """

            --- \(header)
            year: \(year)
            day: \(day)
            part: \(part)
            time: \(time)
            answer:

            \(answer)
            ---
            """
            |> Stdout.line
        
        Err NotImplemented -> 

            [ 
                Color.fg "Advent of Code" Green, ":",
                Color.fg "\(Num.toStr 2022)-\(Num.toStr 1)-Part 1" Blue, ":",
                Color.fg "NOT IMPLEMENTED" Red,
            ]
            |> Str.joinWith "" 
            |> Stdout.line

        Err (Error msg) -> 
            [ 
                Color.fg "Advent of Code" Green, ":",
                Color.fg "\(Num.toStr 2022)-\(Num.toStr 1)-Part 1" Blue, ":",
                Color.fg "ERROR \(msg)" Red,
            ]
            |> Str.joinWith "" 
            |> Stdout.line

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
