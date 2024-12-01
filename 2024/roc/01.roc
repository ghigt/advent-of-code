app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br",
    aoc: "https://github.com/lukewilliamboswell/aoc-template/releases/download/0.2.0/tlS1ZkwSKSB87_3poSOXcwHyySe0WxWOWQbPmp7rxBw.tar.br",
}

import pf.Stdin
import pf.Stdout
import pf.Utc
import aoc.AoC {
    stdin: Stdin.bytes,
    stdout: Stdout.write,
    time: \{} -> Utc.now {} |> Task.map Utc.toMillisSinceEpoch,
}

main =
    AoC.solve {
        year: 2024,
        day: 1,
        title: "Historian Hysteria",
        part1,
        part2,
    }

parseInput = \input ->
    list =
        input
        |> Str.splitOn "\n"
        |> List.map \s ->
            Str.splitOn s "   "
            |> List.map \ns ->
                Str.toI32 ns
                |> Result.withDefault 0

    List.walk list ([], []) \acc, n ->
        a = List.append acc.0 (List.get n 0 |> Result.withDefault 0)
        b = List.append acc.1 (List.get n 1 |> Result.withDefault 0)
        (a, b)

part1 : Str -> Result Str Str
part1 = \input ->
    map = parseInput input

    List.map2 (List.sortAsc map.0) (List.sortAsc map.1) \a, b ->
        Num.abs (a - b)
    |> List.sum
    |> Num.toStr
    |> Ok

part2 : Str -> Result Str Str
part2 = \input ->
    map = parseInput input

    map.0
    |> List.map \n ->
        map.1
        |> List.keepIf \nn -> nn == n
        |> List.len
        |> Num.toI32
        |> Num.mul n
    |> List.sum
    |> Num.toStr
    |> Ok

fixture =
    """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """

expect part1 fixture == Ok "11"
expect part2 fixture == Ok "31"
