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

parse : Str -> List (List U64)
parse = \content ->
    content
    |> Str.trim
    |> Str.split "\n\n"
    |> List.map \lines ->
        Str.split lines "\n"
        |> List.map \line ->
            Str.toU64 line |> Result.withDefault 0

process : List (List U64) -> Str
process = \elves ->
    elves
    |> List.map \elf ->
        List.sum elf
    |> List.sortAsc
    |> List.last
    |> Result.withDefault 0
    |> Num.toStr
