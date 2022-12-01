app "main"
    packages { pf: "./roc/examples/cli/cli-platform/main.roc" }
    imports [pf.Program, pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf


main = Program.quick mainTask

mainTask =
    content <- File.readUtf8 (Path.fromStr "input.txt") |> Task.await

    content
    |> Str.trim
    |> parse
    |> process ["start"] "start"
    |> Num.toStr
    |> Stdout.line

parse : Str -> List { a: Str, b: Str }
parse = \str ->
    Str.split str "\n"
    |> List.map \line ->
        when Str.split line "-" is
            [a, b] -> { a, b }
            _ -> { a: "", b: "" }

process : List { a: Str, b: Str }, List Str, Str -> Nat
process = \map, list, curr ->
    if curr == "end" then
        1
    else
        List.walk map 0 \acc, path ->
            if path.a == curr then
                acc + (check map list path.b)
            else if path.b == curr then
                acc + (check map list path.a)
            else
                acc

check : List { a: Str, b: Str }, List Str, Str -> Nat
check = \map, list, new ->
    if new == "start" then
        0
    else if downcase new == new then
        if List.contains list new && duplicates list then
            0
        else
            process map (List.append list new) new
    else
        process map (List.append list new) new

duplicates : List Str -> Bool
duplicates = \list ->
    downList = list |> List.keepIf \x -> downcase x == x
    setList = Set.fromList downList

    Set.len setList != List.len downList

downcase : Str -> Str
downcase = \str ->
    Str.toUtf8 str
    |> List.map \x ->
        if x >= 'A' && x <= 'Z' then
            x + 'a' - 'A'
        else
            x
    |> Str.fromUtf8
    |> Result.withDefault str
