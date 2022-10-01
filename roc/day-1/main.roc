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


mainTask : Task ExitCode [] [Write [Stderr, Stdout], Read [File]]
mainTask =
    task =
        content <- File.readUtf8 (Path.fromStr "./input.txt")
            |> Task.await

        res = content
            |> Str.split "\n"
            |> List.walk { range: Pair None None, sum: None, total: 0 } \acc, line ->
                { range, sum, total } = acc
                curr = Str.toU32 line |> Result.withDefault 0

                when range is
                    Pair (Some prev) None ->
                        { acc & range: Pair (Some curr) (Some prev) }
                    Pair (Some prev) (Some ante) ->
                        newSum = curr + prev + ante

                        when sum is
                            Some s if newSum > s ->
                                { range: Pair (Some curr) (Some prev), sum: Some newSum, total: total + 1 }
                            _ ->
                                { acc & range: Pair (Some curr) (Some prev), sum: Some newSum }
                    _ ->
                        { acc & range: Pair (Some curr) None }
            |> .total
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
