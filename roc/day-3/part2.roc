app "main"
    packages { pf: "./roc/examples/interactive/cli-platform/main.roc" }
    imports [
        pf.Program.{ Program, ExitCode },
        pf.Stdout,
        pf.Stderr,
        pf.Task.{ Task },
        pf.File,
        pf.Path,
    ]
    provides [main] to pf

main : Program
main = Program.noArgs mainTask

transform = \list ->
    list
    |> Str.joinWith ""
    |> (\x -> Str.concat "0b" x)
    |> Str.toU64
    |> Result.withDefault 0

splitZeroOneAt = \lines, idx ->
    lines
    |> List.walk { zero: [], one: [] } (\{ zero, one }, line ->
        n = Str.toUtf8 line |> List.get idx |> Result.withDefault 0

        if n == 48 then
            { one, zero: List.append zero line }
        else
            { zero, one: List.append one line }
    )

cmpFirst = \{ zero, one } ->
    if List.len one >= List.len zero then
        one
    else
        zero

cmpSec = \{ zero, one } ->
    if List.len zero <= List.len one then
        zero
    else
        one

process = \lines, cmp ->
    List.range 0 12
    |> List.walk lines (\list, idx ->
        if List.len list == 1 then
            list
        else
            splitZeroOneAt list idx
            |> cmp
    )
    |> transform

mainTask : Task ExitCode [] [Write [Stderr, Stdout], Read [File]]
mainTask =
    task =
        content <- File.readUtf8 (Path.fromStr "input.txt")
            |> Task.await

        s =
            content
            |> Str.trim
            |> Str.split "\n"

        res =
            (process s cmpFirst) * (process s cmpSec)
            |> Num.toStr

        Task.succeed res

    Task.attempt task \result ->
        when result is
            Ok total ->
                Stdout.line "\(total)"
                |> Program.exit 0

            Err _ ->
                Stderr.line "oh no!"
                |> Program.exit 1
