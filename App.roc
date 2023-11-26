interface App
    exposes [solutions]
    imports [
        AoC,
        S2022D01,
    ]

## Export a list of the solutions included in this app 
solutions : List AoC.Solution
solutions = [
    S2022D01.solution,
]
