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
        |> List.mapTry Str.toU8
        |> Result.map process

    when res is
        Ok s -> Stdout.line s
        Err _ -> Stdout.line "Err"

process : List U8 -> Str
process = \list ->
    List.range 0 80
    |> List.walk list \items, _ ->
        items
        |> List.walk items \fishes, fish ->
            if fish == 0 then
                List.append fishes 9
            else
                fishes
        |> List.map \fish ->
            if fish == 0 then
                6
            else
                fish - 1
    |> List.len
    |> Num.toStr
