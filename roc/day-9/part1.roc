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
        |> Str.replaceEach "\n" ""
        |> Result.map process

    when res is
        Ok s -> s |> Stdout.line
        Err _ -> Stdout.line "eh.."

len = 100

process = \str ->
    list = Str.toScalars str
    List.mapWithIndex list \x, idx ->
        r = right list idx
        l = left list idx
        u = up list idx
        d = down list idx

        if x < r && x < l && x < u && x < d then
            x - '0' + 1
        else
            0
    |> List.sum
    |> Num.toStr

right = \list, idx ->
    List.get list (idx + 1)
    |> Result.withDefault '9'

left = \list, idx ->
    Num.subChecked idx 1
    |> Result.try \x ->
        List.get list x
    |> Result.withDefault '9'

up = \list, idx ->
    Num.subChecked idx len
    |> Result.try \x ->
        List.get list x
    |> Result.withDefault '9'

down = \list, idx ->
    List.get list (idx + len)
    |> Result.withDefault '9'
