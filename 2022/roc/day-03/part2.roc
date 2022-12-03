app "main"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task.{ Task }]
    provides [main] to pf

main =
    File.readUtf8 (Path.fromStr "input.txt")
    |> Task.await \content -> content |> parse |> process |> Stdout.line
    |> Task.onFail \_ -> crash "Uh oh, there was an error!"

parse : Str -> List (List (List U32))
parse = \content ->
    content
    |> Str.trim
    |> Str.split "\n"
    |> List.walk { result: [], pending: [] } \{ result, pending }, line ->
        list = line |> Str.toUtf8 |> List.map Num.toU32
        when List.len pending is
            2 -> { result: List.append result (List.append pending list), pending: [] }
            _ -> { result, pending: List.append pending list }
    |> .result

process : List (List (List U32)) -> Str
process = \rs ->
    List.map rs \r ->
        List.walk r (Err {}) \set, current ->
            when set is
                Ok s -> Ok (Set.intersection s (Set.fromList current))
                Err _ -> Ok (Set.fromList current)
        |> Result.withDefault Set.empty
        |> count
    |> List.sum
    |> Num.toStr

count : Set U32 -> U32
count = \s ->
    s
    |> Set.toList
    |> List.map \x ->
        if x >= 'a' && x <= 'z' then
            x - 'a' + 1
        else
            x - 'A' + 27
    |> List.sum
