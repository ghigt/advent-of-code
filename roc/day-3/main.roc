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

compare = \list, len, cmp ->
    List.map list \x ->
        if cmp (len - x) (len / 2) then "1" else "0"

transform = \list ->
    list
    |> Str.joinWith ""
    |> (\x -> Str.concat "0b" x)
    |> Str.toU64
    |> Result.withDefault 0

compute = \list, len, cmp ->
    list
    |> compare (Num.toFrac len) cmp
    |> transform

lineLength = \list ->
    List.takeFirst list 1 |> List.map Str.countGraphemes |> List.sum

process : List Str -> Str
process = \lines ->
    lines
    |> List.walk
        (List.repeat 0 (lineLength lines))
        (
            \list, line ->
                Str.toScalars line
                |> List.map2
                    list
                    \x, y ->
                        when x is
                            49 -> y + 1
                            _ -> y
        )
    |> \list ->
        a = compute list (List.len lines) Num.isGte
        b = compute list (List.len lines) Num.isLt
        a * b
    |> Num.toStr

mainTask : Task ExitCode [] [Write [Stderr, Stdout], Read [File]]
mainTask =
    task =
        content <- File.readUtf8 (Path.fromStr "input.txt")
            |> Task.await

        res =
            content
            |> Str.trim
            |> Str.split "\n"
            |> process

        Task.succeed res

    Task.attempt task \result ->
        when result is
            Ok total ->
                Stdout.line "\(total)"
                |> Program.exit 0

            Err _ ->
                Stderr.line "oh no!"
                |> Program.exit 1
