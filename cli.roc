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
    when solutions |> solve {year: 2022, day: 1} is 
        Ok answer -> Stdout.line "Success: \(answer)"
        Err NotAvailable -> Stdout.line "Not available"
        Err NotImplemented -> Stdout.line "Not implemented"
        Err (Error msg) -> Stdout.line "Something went wrong: \(msg)"

solve : List AoC.Solution, {year : U64, day : U64} -> Result Str [NotAvailable, NotImplemented, Error Str]
solve = \sols, {year, day} ->
    Err NotAvailable