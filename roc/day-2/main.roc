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

process : List Str -> Str
process = \lines ->
    lines
    |> List.map (\line -> Str.split line " ")
    |> List.walk { h: 0, d: 0, aim: 0 } \{ h, d, aim }, list ->
        l0 = List.first list
        l1 = List.last list |> Result.try Str.toU32

        when P l0 l1 is
            P (Ok "forward") (Ok move) -> { h: h + move, d: d + aim * move, aim }
            P (Ok "down") (Ok move) -> { h, d, aim: aim + move }
            P (Ok "up") (Ok move) -> { h, d, aim: aim - move }
            _ -> { h, d, aim }

    |> \{ h, d } -> h * d
    |> Num.toStr

mainTask : Task ExitCode [] [Write [Stderr, Stdout], Read [File]]
mainTask =
    task =
        content <- File.readUtf8 (Path.fromStr "input.txt")
            |> Task.await

        res =
            content
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
