app "http"
    packages {
        pf: "https://github.com/roc-lang/basic-webserver/releases/download/0.2.0/J6CiEdkMp41qNdq-9L3HGoF2cFkafFlArvfU1RtR4rY.tar.br",
        html: "https://github.com/Hasnep/roc-html/releases/download/v0.2.0/5fqQTpMYIZkigkDa2rfTc92wt-P_lsa76JVXb8Qb3ms.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Stderr,
        pf.Task.{ Task },
        pf.Http.{ Request, Response },
        pf.Utc,
        pf.Url.{ Url },
        html.Html,
        html.Attribute,
        "styles.css" as styles : List U8,
        App,
    ]
    provides [main] to pf

main : Request -> Task Response []
main = \req ->

    # Log the date, time, method, and url to stdout
    {} <- logRequest req |> Task.await

    # Handle request
    result <- handleReq req |> Task.attempt

    # Handle errors
    when result is
        Ok response ->
            Task.ok response

        Err (EnvVarNotFound var) ->
            {} <- Stderr.line "Environment Variable NotFound \(var)" |> Task.await

            Task.ok {
                status: 500,
                headers: [],
                body: "ERROR" |> Str.toUtf8,
            }

        Err (HttpError msg) ->
            {} <- Stderr.line msg |> Task.await

            Task.ok {
                status: 500,
                headers: [],
                body: "ERROR" |> Str.toUtf8,
            }

handleReq : Request -> Task _ _
handleReq = \req ->
    when (req.method, req.url |> Url.fromStr |> urlSegments) is
        (Get, ["styles.css", ..]) ->
            Task.ok {
                status: 200,
                headers: [],
                body: styles,
            }

        (Get, ["puzzle", "2022", "01", ..]) ->
            when App.solvePuzzle { year: 2022, day: 1, puzzle: Part1 } is
                Ok answer ->
                    { year: 2022, day: 1, part: 1, time: 253, answer }
                    |> solutionPage
                    |> Html.render
                    |> respondHtml 200

                Err NotImplemented -> respondHtml "NOT IMPLEMENTED" 200
                Err (Error msg) -> respondHtml "ERROR: \(msg)" 200

        (_, _) -> respondHtml (Html.render indexPage) 200

logRequest : Request -> Task {} *
logRequest = \req ->
    dateTime <- Utc.now |> Task.map Utc.toIso8601Str |> Task.await

    Stdout.line "\(dateTime) \(Http.methodToStr req.method) \(req.url)"

# Respond with the given status code and body
respondHtml : Str, U16 -> Task Response *
respondHtml = \body, code ->
    Task.ok {
        status: code,
        headers: [
            { name: "Content-Type", value: Str.toUtf8 "text/html; charset=utf-8" },
        ],
        body: Str.toUtf8 body,
    }

urlSegments : Url -> List Str
urlSegments = \url ->
    url
    |> Url.path
    |> Str.split "/"
    |> List.dropFirst 1

indexPage : Html.Node
indexPage =
    Html.html [] [
        Html.head [] [
            Html.link [Attribute.rel "stylesheet", Attribute.href "/styles.css"] [],
        ],
        Html.body [] [
            Html.h1 [] [Html.text "Advent of Code"],
            Html.h2 [] [Html.text "[2023 Solutions Coming Soon!]"],
            Html.p [] [
                Html.text "Click on a solution below -- ",
                Html.a [Attribute.href "/puzzle/2022/01"] [Html.text "Solution for Puzzle 2022-01 Part 1"],
            ],
        ],
    ]

solutionPage : { year : U64, day : U64, part : U64, time : U64, answer : Str } -> Html.Node
solutionPage = \{ year, day, part, time, answer } ->

    yearStr = Num.toStr year
    dayStr = Num.toStr day
    partStr = Num.toStr part
    timeStr = Num.toStr time

    Html.html [] [
        Html.head [] [
            Html.link [Attribute.rel "stylesheet", Attribute.href "/styles.css"] [],
        ],
        Html.body [] [
            Html.h1 [] [Html.text "Advent of Code"],
            Html.h2 [] [Html.text "Puzzle Solution"],
            Html.p [] [Html.text "year: ", Html.text yearStr],
            Html.p [] [Html.text "day: ", Html.text dayStr],
            Html.p [] [Html.text "part: ", Html.text partStr],
            Html.p [] [Html.text "time: ", Html.text timeStr],
            Html.p [] [Html.text "answer:\n\(answer)"],
            Html.p [] [
                Html.a [Attribute.href "/"] [Html.text "Click here to return Home"],
            ],
        ],
    ]
