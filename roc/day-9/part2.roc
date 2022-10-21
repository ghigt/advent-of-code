app "main"
    packages { pf: "./roc/examples/cli/cli-platform/main.roc" }
    imports [pf.Program, pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf


main = Program.quick mainTask

len = 100

mainTask =
    content <- File.readUtf8 (Path.fromStr "input.txt") |> Task.await

    res =
        content
        |> Str.trim
        |> Str.replaceEach "\n" ""
        |> Result.map \x ->
            process x
            |> List.sortDesc
            |> List.takeFirst 3
            |> List.product
            |> Num.toStr

    when res is
        Ok s -> s |> Stdout.line
        Err _ -> Stdout.line "eh.."

process : Str -> List Nat
process = \str ->
    list = Str.toScalars str

    List.mapWithIndex list \x, idx ->
        r = right list idx
        l = left  list idx
        u = up    list idx
        d = down  list idx

        if x < r.x && x < l.x && x < u.x && x < d.x then
            processBasins Set.empty list x idx
            |> Set.len
        else
            0

processBasins : Set Nat, List U32, U32, Nat -> Set Nat
processBasins = \set, list, x, idx ->
    Set.insert set idx
    |> calc list x (right list idx)
    |> calc list x (left  list idx)
    |> calc list x (up    list idx)
    |> calc list x (down  list idx)

calc : Set Nat, List U32, U32, { x: U32, idx: Nat } -> Set Nat
calc = \set, list, x, y ->
    if y.x >= x + 1 && y.x != '9' then
        Set.insert set y.idx
        |> processBasins list y.x y.idx
    else
        set

right : List U32, Nat -> { idx: Nat, x: U32 }
right = \list, idx ->
    List.get list (idx + 1)
    |> Result.map \x -> { idx: idx + 1, x }
    |> Result.withDefault { idx: 0, x: '9' }

left : List U32, Nat -> { idx: Nat, x: U32 }
left = \list, idx ->
    Num.subChecked idx 1
    |> Result.try \x ->
        List.get list x
    |> Result.map \x -> { idx: idx - 1, x }
    |> Result.withDefault { idx: 0, x: '9' }

up : List U32, Nat -> { idx: Nat, x: U32 }
up = \list, idx ->
    Num.subChecked idx len
    |> Result.try \x ->
        List.get list x
    |> Result.map \x -> { idx: idx - len, x }
    |> Result.withDefault { idx: 0, x: '9' }

down : List U32, Nat -> { idx: Nat, x: U32 }
down = \list, idx ->
    List.get list (idx + len)
    |> Result.map \x -> { idx: idx + len, x }
    |> Result.withDefault { idx: 0, x: '9' }
