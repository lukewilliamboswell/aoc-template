app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    aoc: "../../package/main.roc",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.2/FH4N0Sw-JSFXJfG3j54VEDPtXOoN-6I9v_IA8S18IGk.tar.br",
}

import pf.Stdin
import pf.Stdout
import pf.Utc
import json.Json
import aoc.AoC {
    stdin: Stdin.bytes,
    stdout: Stdout.write,
    time: \{} -> Utc.now {} |> Task.map Utc.toMillisSinceEpoch,
}

main =
    AoC.solve {
        year: 2020,
        day: 1,
        title: "Report Repair",
        part1,
        part2,
    }


part1 : Str -> Result Str Str
part1 = \input ->
    { numbers, rest } = parseNumbers { numbers: [], rest: Str.toUtf8 input }

    expect List.isEmpty rest

    combined =
        List.joinMap numbers \x ->
            List.map numbers \y ->
                { x, y, sum: x + y, mul: x * y }

    when List.keepIf combined \c -> c.sum == 2020 is
        [first, ..] -> Ok "$(Num.toStr first.x) * $(Num.toStr first.y) = $(Num.toStr first.mul)"
        _ -> Err "expected at least one pair to have sum of 2020"

part2 : Str -> Result Str Str
part2 = \input ->
    { numbers, rest } = parseNumbers { numbers: [], rest: Str.toUtf8 input }

    expect List.isEmpty rest

    combined =
        List.joinMap  numbers \x ->
            List.joinMap numbers \y ->
                List.map numbers \z ->
                    { x, y, z, sum: x + y + z, mul: x * y * z }

    when List.keepIf combined \c -> c.sum == 2020 is
        [first, ..] -> Ok "$(Num.toStr first.x) * $(Num.toStr first.y) * $(Num.toStr first.z) = $(Num.toStr first.mul)"
        _ -> Err "expected at least one triple to have sum of 2020"

parseNumbers = \{ numbers, rest } ->
    if List.isEmpty rest then
        { numbers, rest }
    else
        decodeResult : Decode.DecodeResult U64
        decodeResult = Decode.fromBytesPartial rest Json.utf8

        when decodeResult.result is
            Ok n -> parseNumbers { numbers: List.append numbers n, rest: decodeResult.rest }
            Err _ -> parseNumbers { numbers, rest: List.dropFirst rest 1 }

expect
    result = part1 sampleBytes
    result == Ok "1721 * 299 = 514579"

expect
    result = part2 sampleBytes
    result == Ok "979 * 366 * 675 = 241861950"

sampleBytes =
    """
    1721
    979
    366
    299
    675
    1456
    """
