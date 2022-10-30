app "main"
    packages { pf: "./roc/examples/cli/cli-platform/main.roc" }
    imports [pf.Program, pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf


main = Program.quick mainTask

len = 10
totalLen = 10 * 10

mainTask =
    content <- File.readUtf8 (Path.fromStr "input.txt") |> Task.await

    content
    |> Str.trim
    |> Str.replaceEach "\n" "" |> Result.withDefault ""
    |> parse
    |> steps 100
    # |> stringify
    |> Stdout.line

Map : Dict Nat Item
Item : [On Nat, Off Nat]

parse : Str -> Map
parse = \str ->
    Str.graphemes str
    |> List.mapWithIndex \g, idx -> { idx, g }
    |> List.walk Dict.empty \map, v ->
        item =
            Str.toNat v.g
            |> Result.withDefault 0
            |> Off

        Dict.insert map v.idx item

# stringify : Map -> Str
# stringify = \map ->
#     List.range 0 totalLen
#     |> List.map \idx ->
#         item = Dict.get map idx |> Result.withDefault (Off 0)
#         s =
#             when item is
#                 On n -> Num.toStr n
#                 Off n -> Num.toStr n

#         if idx > 0 && idx % 10 == 0 then
#             Str.concat "\n" s
#         else
#             s
#     |> Str.joinWith ""

steps : Map, Nat -> Str
steps = \map, n ->
    List.range 0 n
    |> List.walk { map, total: 0 } \acc, _ ->
        newMap = init acc.map |> process

        { map: newMap, total: acc.total + (flashes newMap) }
    |> .total
    |> Num.toStr

flashes : Map -> Nat
flashes = \map ->
    Dict.walk map 0 \total, _, v ->
        when v is
            On _ -> total + 1
            _ -> total

init : Map -> Map
init = \map ->
    Dict.walk map Dict.empty \acc, k, v ->
        item =
            when v is
                On n -> Off n
                Off n -> Off n

        Dict.insert acc k item

process : Map -> Map
process = \list ->
    List.range 0 totalLen
    |> List.walk list \map, idx ->
        update map idx

update : Map, I8 -> Map
update = \map, idx ->
    natIdx = Num.toNat idx
    res = Dict.get map natIdx

    when res is
        Ok item ->
            when item is
                On _ -> map
                Off n ->
                    if n + 1 > 9 then
                        Dict.insert map natIdx (On 0)
                        |> update (idxRight idx)
                        |> update (idxUp idx)
                        |> update (idxUpRight idx)
                        |> update (idxUpLeft idx)
                        |> update (idxLeft idx)
                        |> update (idxDown idx)
                        |> update (idxDownRight idx)
                        |> update (idxDownLeft idx)
                    else
                        Dict.insert map natIdx (Off (n + 1))
        Err _ -> map

idxRight : I8 -> I8
idxRight = \idx -> if (idx + 1) % len == 0 then -1 else idx + 1

idxUp : I8 -> I8
idxUp = \idx -> if (idx - len) < 0 then -1 else idx - len

idxLeft : I8 -> I8
idxLeft = \idx -> if idx % len == 0 then -1 else idx - 1

idxDown : I8 -> I8
idxDown = \idx -> if (idx + len) >= totalLen then -1 else idx + len

idxUpRight : I8 -> I8
idxUpRight = \idx -> if (idx - len) < 0 || (idx - len + 1) % len == 0 then -1 else idx - len + 1

idxUpLeft : I8 -> I8
idxUpLeft = \idx -> if (idx - len - 1) < 0 || (idx - len) % len == 0 then -1 else idx - len - 1

idxDownRight : I8 -> I8
idxDownRight = \idx -> if (idx + len + 1) >= totalLen || (idx + len + 1) % len == 0 then -1 else idx + len + 1

idxDownLeft : I8 -> I8
idxDownLeft = \idx -> if (idx + len - 1) >= totalLen || (idx + len) % len == 0 then -1 else idx + len - 1
