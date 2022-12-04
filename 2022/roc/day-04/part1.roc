app "main"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task.{ Task }]
    provides [main] to pf

main =
    File.readUtf8 (Path.fromStr "input.txt")
    |> Task.await \content -> content |> parse |> process |> Stdout.line
    |> Task.onFail \_ -> crash "Uh oh, there was an error!"

Range : { from: U32, to: U32 }
Pair : { first: Range, second: Range }

parse : Str -> List Pair
parse = \content ->
    content
    |> Str.trim
    |> Str.split "\n"
    |> List.map \line ->
        line
        |> Str.split ","
        |> \pair ->
            when pair is
                [x, y] -> { first: parseNums x, second: parseNums y }
                _ -> { first: { from: 0, to: 0 }, second: { from: 0, to: 0 } }

parseNums : Str -> Range
parseNums = \s ->
    s
    |> Str.split "-"
    |> \x ->
        when x is
            [a, b] ->
                from = a |> Str.toU32 |> Result.withDefault 0
                to = b |> Str.toU32 |> Result.withDefault 0
                { from, to }
            _ -> { from: 0, to: 0 }

process : List Pair -> Str
process = \list ->
    list
    |> List.map \{ first, second } ->
        if ((first.from >= second.from && first.to <= second.to) ||
            (second.from >= first.from && second.to <= first.to)) then
            1
        else
            0
    |> List.sum
    |> Num.toStr
