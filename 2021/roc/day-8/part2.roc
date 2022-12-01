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
        Ok s ->
            s
            |> List.map \x -> List.map x Num.toStr |> Str.joinWith ""
            |> List.map \x -> Str.toU64 x |> Result.withDefault 0
            |> List.sum
            |> Num.toStr
            |> Stdout.line
        Err _ -> Stdout.line "eh.."


parse = \list ->
    list
    |> List.mapTry \x ->
        split <- Str.splitFirst x " | " |> Result.map

        left = processLeft split.before
        processRight split.after left

positions = [
    ["A", "B", "C", "E", "F", "G"],
    ["C", "F"],
    ["A", "C", "D", "E", "G"],
    ["A", "C", "D", "F", "G"],
    ["B", "C", "D", "F"],
    ["A", "B", "D", "F", "G"],
    ["A", "B", "D", "E", "F", "G"],
    ["A", "C", "F"],
    ["A", "B", "C", "D", "E", "F", "G"],
    ["A", "B", "C", "D", "F", "G"],
]

processRight = \line, left ->
    pos = transform left

    Str.split line " "
    |> List.map \x ->
        List.findFirstIndex pos \y ->
            (Str.toUtf8 x |> List.sortAsc) == y
        |> Result.withDefault 0

# dict -> { a: [A], b: [B], c: [A,B]...}
transform = \dict ->
    new =
        Dict.walk dict Dict.empty \acc, k, v ->
            list = Set.toList v
            pos =
                if List.len list > 1 then
                    "G"
                else
                    List.first list |> Result.withDefault "A"

            Dict.insert acc pos k

    List.map positions \x ->
        List.map x \y ->
            Dict.get new y |> Result.withDefault '-'
        |> List.sortAsc

processLeft = \line ->
    inputs = Str.split line " "

    List.walk [2, 3, 4, 5, 6, 7] Dict.empty \dict, len ->
        inp =
            List.keepIf inputs \x -> Str.countGraphemes x == len
            |> List.map Str.toUtf8
            |> List.join
            |> countLetters
        pos =
            List.keepIf positions \x -> List.len x == len
            |> List.join
            |> countLetters

        processMerge dict inp pos

countLetters = \list ->
    List.walk list Dict.empty \dict, letter ->
        Dict.update dict letter \x ->
            when x is
                Present v -> Present (v + 1)
                Missing -> Present 1
    |> Dict.walk Dict.empty \dict, k, v ->
        Dict.update dict v \x ->
            when x is
                Present y -> Present (List.append y k)
                Missing -> Present ([k])

processMerge = \dict, inp, pos ->
    Dict.walk inp dict \acc, k, v ->
        nums = Dict.get pos k |> Result.withDefault []

        merge acc v (Set.fromList nums)

merge = \dict, inputs, nums ->
    List.walk inputs dict \letters, letter ->
        Dict.update letters letter \x ->
            when x is
                Present v -> Present (Set.intersection v nums)
                Missing -> Present nums
