app "main"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task.{ Task }]
    provides [main] to pf

main =
    File.readUtf8 (Path.fromStr "input.txt")
    |> Task.await \content -> content |> parse |> process |> Stdout.line
    |> Task.onFail \_ -> crash "Uh oh, there was an error!"

parse : Str -> List Str
parse = \content ->
    content |> Str.trim |> Str.split "\n"

process : List Str -> Str
process = \lines ->
    lines
    |> List.map \line ->
        when line is
            "A X" -> 0 + 3
            "B X" -> 0 + 1
            "C X" -> 0 + 2
            "A Y" -> 3 + 1
            "B Y" -> 3 + 2
            "C Y" -> 3 + 3
            "A Z" -> 6 + 2
            "B Z" -> 6 + 3
            "C Z" -> 6 + 1
            _ -> 0
    |> List.sum
    |> Num.toStr
