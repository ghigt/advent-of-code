app "main"
    packages { pf: "./roc/examples/cli/cli-platform/main.roc" }
    imports [pf.Program, pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf

main = Program.quick mainTask

mainTask =
    content <- File.readUtf8 (Path.fromStr "input.txt") |> Task.await

    content
    |> Str.trim
    |> Str.split "\n"
    |> List.map process
    |> List.keepOks \x -> x
    |> List.map complete
    |> List.map count
    |> calc
    |> Num.toStr
    |> Stdout.line

process : Str -> Result (List U8) U8
process = \line ->
    Str.toUtf8 line
    |> List.walkUntil (Ok []) \state, elem ->
        list = Result.withDefault state []
        when elem is
            '<' -> Continue (Ok (List.append list '<'))
            '(' -> Continue (Ok (List.append list '('))
            '[' -> Continue (Ok (List.append list '['))
            '{' -> Continue (Ok (List.append list '{'))
            '>' -> check list '<'
            ')' -> check list '('
            ']' -> check list '['
            '}' -> check list '{'
            c   -> Break (Err c)

check : List U8, U8 -> [Continue [Ok (List U8)]*, Break [Err U8]*]*
check = \list, x ->
    when List.last list is
        Ok c if c == x -> Continue (Ok (List.dropLast list))
        _ -> Break (Err x)

complete : List U8 -> List U8
complete = \list ->
    List.reverse list
    |> List.map \x ->
        when x is
            '<' -> '>'
            '(' -> ')'
            '[' -> ']'
            '{' -> '}'
            c -> c

count : List U8 -> Nat
count = \list ->
    List.walk list 0 \total, x ->
        v =
            when x is
                ')' -> 1
                ']' -> 2
                '}' -> 3
                '>' -> 4
                _ -> 0

        total * 5 + v

calc : List Nat -> Nat
calc = \list ->
    List.sortAsc list
    |> \x ->
        List.get x (List.len x |> Num.divTrunc 2)
        |> Result.withDefault 0
