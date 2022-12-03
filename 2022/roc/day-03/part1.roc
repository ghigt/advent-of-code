app "main"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task.{ Task }]
    provides [main] to pf

main =
    File.readUtf8 (Path.fromStr "input.txt")
    |> Task.await \content -> content |> parse |> process |> Stdout.line
    |> Task.onFail \_ -> crash "Uh oh, there was an error!"

Rucksack : { left: Set U32, right: Set U32 }

parse : Str -> List Rucksack
parse = \content ->
    content
    |> Str.trim
    |> Str.split "\n"
    |> List.map \line ->
        list = line |> Str.toUtf8
        list
        |> List.map Num.toU32
        |> List.split (Num.divTrunc (List.len list) 2)
        |> \{ before, others } ->
            { left: Set.fromList before, right: Set.fromList others }

process : List Rucksack -> Str
process = \rs ->
    rs
    |> List.map \r ->
        Set.intersection r.left r.right
        |> count
    |> List.sum
    |> Num.toStr

count : Set U32 -> U32
count = \s ->
    s
    |> Set.toList
    |> List.map \x ->
        if x >= 'a' && x <= 'z' then
            x - 'a' + 1
        else
            x - 'A' + 27
    |> List.sum
