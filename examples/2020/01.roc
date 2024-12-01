app [main!] {
    pf: platform "../../../basic-cli/platform/main.roc",
    aoc: "../../package/main.roc",
}

import pf.Stdin
import pf.Stdout
import pf.Utc
import aoc.AoC {
    stdin!: Stdin.bytes!,
    stdout!: Stdout.write!,
    time!: \{} -> Utc.now! {} |> Utc.toMillisSinceEpoch,
}

main! = \{} ->
    AoC.solve! {
        year: 2020,
        day: 1,
        title: "Report Repair",
        part1,
        part2,
    }

part1 : Str -> Result Str Str
part1 = \input ->
    numbers = parseNumbers input

    combined =
        List.joinMap numbers \x ->
            List.map numbers \y ->
                { x, y, sum: x + y, mul: x * y }

    when List.keepIf combined \c -> c.sum == 2020 is
        [first, ..] -> Ok "$(Num.toStr first.x) * $(Num.toStr first.y) = $(Num.toStr first.mul)"
        _ -> Err "expected at least one pair to have sum of 2020"

part2 : Str -> Result Str Str
part2 = \input ->
    numbers = parseNumbers input

    combined =
        List.joinMap numbers \x ->
            List.joinMap numbers \y ->
                List.map numbers \z ->
                    { x, y, z, sum: x + y + z, mul: x * y * z }

    when List.keepIf combined \c -> c.sum == 2020 is
        [first, ..] -> Ok "$(Num.toStr first.x) * $(Num.toStr first.y) * $(Num.toStr first.z) = $(Num.toStr first.mul)"
        _ -> Err "expected at least one triple to have sum of 2020"

parseNumbers = \input -> input |> Str.splitOn "\n" |> List.keepOks Str.toU64

expect
    result = part1 example
    result == Ok "1721 * 299 = 514579"

expect
    result = part2 example
    result == Ok "979 * 366 * 675 = 241861950"

expect parseNumbers example == [1721, 979, 366, 299, 675, 1456]

example =
    """
    1721
    979
    366
    299
    675
    1456
    """
