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
    |> List.map count
    |> List.sum
    |> Num.toStr
    |> Stdout.line

process = \line ->
    Str.toScalars line
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

check = \list, x ->
    when List.last list is
        Ok c if c == x -> Continue (Ok (List.dropLast list))
        _ -> Break (Err x)

count = \res ->
    when res is
        Err c ->
            when c is
                '(' -> 3
                '[' -> 57
                '{' -> 1197
                '<' -> 25137
                _   -> 0
        _ -> 0
