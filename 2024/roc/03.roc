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
        day: 3,
        title: "Mull It Over",
        part1,
        part2,
    }

check = \x, res ->
    when Str.splitFirst x "mul(" is
        Ok { after } ->
            when Str.splitFirst after "," is
                Ok comma ->
                    first = comma.before
                    next = comma.after
                    when Str.toU32 first is
                        Ok a ->
                            when Str.splitFirst next ")" is
                                Ok parens ->
                                    second = parens.before
                                    when Str.toU32 second is
                                        Ok b -> check after (List.sum [res, List.product [a, b]])
                                        Err _ -> check after res

                                Err _ -> check after res

                        Err _ -> check after res

                Err _ -> check after res

        Err _ -> res

part1 : Str -> Result Str Str
part1 = \input ->
    input
    |> Str.trim
    |> check 0
    |> Num.toStr
    |> Ok

part2 : Str -> Result Str Str
part2 = \input ->
    Err ""

fixture = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

expect part1 fixture == Ok "161"
expect part2 fixture == Ok "8"
