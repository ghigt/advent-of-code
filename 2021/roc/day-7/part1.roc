app "main"
    packages { pf: "./roc/examples/cli/cli-platform/main.roc" }
    imports [pf.Program, pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf

main = Program.quick mainTask

mainTask =
    content <- File.readUtf8 (Path.fromStr "input.txt") |> Task.await

    res =
        content
        |> Str.trim
        |> Str.split ","
        |> List.mapTry Str.toI32
        |> Result.map List.sortAsc
        |> Result.try process

    when res is
        Ok s -> Num.toStr s |> Stdout.line
        Err _ -> Stdout.line "eh.."

process = \list ->
    min = List.first list |> Result.withDefault 0
    max = List.last list |> Result.withDefault 0

    List.range min max
    |> List.map \idx ->
        List.map list \i -> Num.abs (idx - i)
        |> List.sum
    |> List.min
