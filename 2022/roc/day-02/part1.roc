app "main"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Stderr, pf.Path, pf.File, pf.Task.{ Task }, pf.Process]
    provides [main] to pf

main : Task {} []
main =
    task =
        content <- File.readUtf8 (Path.fromStr "input.txt") |> Task.await

        content
        |> parse
        |> process
        |> Stdout.line

    Task.attempt task \result ->
        when result is
            Ok {} -> Process.exit 0
            Err _ ->
                {} <- Stderr.line "Uh oh, there was an error!" |> Task.await
                Process.exit 1

parse : Str -> List Str
parse = \content ->
    content
    |> Str.trim
    |> Str.split "\n"

process : List Str -> Str
process = \lines ->
    lines
    |> List.map \line ->
        when line is
            "A X" -> 1 + 3
            "B X" -> 1 + 0
            "C X" -> 1 + 6
            "A Y" -> 2 + 6
            "B Y" -> 2 + 3
            "C Y" -> 2 + 0
            "A Z" -> 3 + 0
            "B Z" -> 3 + 6
            "C Z" -> 3 + 3
            _ -> 0
    |> List.sum
    |> Num.toStr
