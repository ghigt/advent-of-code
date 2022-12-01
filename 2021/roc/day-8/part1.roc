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
        |> Str.split "\n"
        |> parse

    when res is
        Ok s -> s |> Num.toStr |> Stdout.line
        Err _ -> Stdout.line "eh.."

parse = \list ->
    split <- list |> List.mapTry (\x -> Str.splitFirst x " | ") |> Result.map
    List.map split .after
    |> List.map \x ->
        Str.split x " "
        |> List.walk 0 \acc, s ->
            when Str.countGraphemes s is
                2 | 4 | 3 | 7 -> acc + 1
                _ -> acc
    |> List.sum
