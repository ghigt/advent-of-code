app "main"
    packages { pf: "./roc/examples/interactive/cli-platform/main.roc" }
    imports [
        pf.Program.{ Program },
        pf.Stdout,
        pf.Task.{ await },
        pf.File,
        pf.Path,
    ]
    provides [main] to pf

main = Program.quick mainTask

parseNums = \s ->
    Str.split s "," |> List.map \x -> Str.toU64 x |> Result.withDefault 0

parseCards = \list ->
    list
    |> List.walk { cards: [], card: [] } (\{ cards, card }, line ->
        if line == "" then
            { cards: List.append cards card, card: [] }
        else
            newCard =
                line |> Str.split " " |> List.keepOks Str.toU64 |> List.map NotFound

            { cards, card: List.append card newCard }
        )
    |> .cards

markCard = \card, num ->
    List.map card \line ->
        List.map line \n ->
            when n is
                NotFound v if v == num -> Found v
                _ -> n

isFound = \item ->
    when item is
        Found _ -> Bool.true
        _ -> Bool.false

validateH = \card ->
    List.any card \line -> List.all line isFound

validateV = \card ->
    len =
        List.first card
        |> Result.withDefault []
        |> List.len

    List.any (List.range 0 len) \idx ->
        List.all card \line ->
            line
            |> List.get idx
            |> Result.withDefault (NotFound 0)
            |> isFound

validate = \cards ->
    List.findFirst cards \card ->
        validateH card || validateV card

sumCard = \card ->
    card
    |> List.join
    |> List.walk 0 \acc, item ->
        when item is
            NotFound v -> acc + v
            _ -> acc

play = \cards, nums ->
    num = List.first nums |> Result.withDefault 0

    newCards = List.map cards (\x -> markCard x num)

    valid = newCards |> validate

    when valid is
        Ok card -> num * sumCard card
        Err _   -> play newCards (List.dropFirst nums)

# printCard = \card ->
#     List.map card (\line ->
#         List.map line (\x ->
#             when x is
#                 Found n    -> Num.toStr n |> \s -> "Found \(s)"
#                 NotFound n -> Num.toStr n |> \s -> "NotFound \(s)"
#         )
#         |> Str.joinWith ", "
#         |> \x -> "  [\(x)],"
#     )
#     |> Str.joinWith "\n"
#     |> \x -> "[\n\(x)\n]"

# printCards = \cards ->
#     cards |> List.map printCard |> Str.joinWith ",\n" |> \x -> "[\n\(x)]"

mainTask =
    content <- File.readUtf8 (Path.fromStr "input.txt") |> await

    lines = content |> Str.split "\n"
    nums = parseNums (lines |> List.first |> Result.withDefault "")

    res =
        parseCards (List.drop lines 2)
        |> play nums
        |> Num.toStr

    Stdout.line res
