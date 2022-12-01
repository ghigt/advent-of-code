app "main"
    packages { pf: "./roc/examples/cli/cli-platform/main.roc" }
    imports [pf.Program, pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf

main : Program.Program
main = Program.quick mainTask

mainTask =
    content <- File.readUtf8 (Path.fromStr "input.txt") |> Task.await

    res =
        content
        |> Str.trim
        |> Str.split ","
        |> List.mapTry Str.toU8
        |> Result.map compute
        |> Result.map process

    when res is
        Ok s -> Stdout.line s
        Err _ -> Stdout.line "Err"

compute : List U8 -> Dict U8 Nat
compute = \list ->
    List.range 0 9
    |> List.walk Dict.empty \dict, x ->
        size =
            List.keepIf list \i -> i == x
            |> List.len

        Dict.insert dict x size

process : Dict U8 Nat -> Str
process = \dict ->
    List.range 0 256
    |> List.walk dict \nums, _ ->
        nums
        |> Dict.walk Dict.empty \state, k, v ->
            res =
                if k == 0 then
                    { state: Dict.insert state 8 v, num: 6 }
                else
                    { state, num: k - 1 }

            Dict.update res.state res.num \x ->
                when x is
                    Present n -> Present (v + n)
                    Missing -> Present v

    |> Dict.values
    |> List.sum
    |> Num.toStr
