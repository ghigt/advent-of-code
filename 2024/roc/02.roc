app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br",
    aoc: "https://github.com/lukewilliamboswell/aoc-template/releases/download/0.2.0/tlS1ZkwSKSB87_3poSOXcwHyySe0WxWOWQbPmp7rxBw.tar.br",
}

import pf.Stdin
import pf.Stdout
import pf.Utc
import aoc.AoC {
    stdin: Stdin.readToEnd,
    stdout: Stdout.write,
    time: \{} -> Utc.now {} |> Task.map Utc.toMillisSinceEpoch,
}

main =
    AoC.solve {
        year: 2024,
        day: 2,
        title: "Red-Nosed Reports",
        part1,
        part2,
    }

parseInput = \input ->
    input
    |> Str.trim
    |> Str.splitOn "\n"
    |> List.map \s ->
        Str.splitOn s " "
        |> List.keepOks Str.toI32

check = \ns, dir ->
    when ns is
        [a, b, .. as rest] ->
            if b - a >= 1 && b - a <= 3 && (dir == Asc || dir == None) then
                check (List.prepend rest b) Asc
            else if a - b >= 1 && a - b <= 3 && (dir == Desc || dir == None) then
                check (List.prepend rest b) Desc
            else
                Bool.false

        [_] | [] -> Bool.true

part1 : Str -> Result Str Str
part1 = \input ->
    parseInput input
    |> List.countIf \ns -> check ns None
    |> Num.toStr
    |> Ok

part2 : Str -> Result Str Str
part2 = \input ->
    parseInput input
    |> List.countIf \ns ->
        if !(check ns None) then
            List.range { start: At 0, end: Length (List.len ns) }
            |> List.any \x -> check (List.dropAt ns x) None
        else
            Bool.true
    |> Num.toStr
    |> Ok

fixture =
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    2 1 5 6 7
    3 6 5 4 3 1
    26 23 28 30 31
    75 76 79 81 80 81 84
    """

expect part1 fixture == Ok "2"
expect part2 fixture == Ok "8"
