app "main"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task.{ Task }]
    provides [main] to pf

main =
    File.readUtf8 (Path.fromStr "input.txt")
    |> Task.await \content -> content |> parse |> process |> Stdout.line
    |> Task.onFail \_ -> crash "Uh oh, there was an error!"

# parse : Str -> List Pair
parse = \content ->
    when Str.trim content |> Str.split "\n\n" is
        [a, b] -> { header: parseHeader a, instr: parseInstructions b }
        _ -> crash "parse failed"

# parseHeader : Str ->
parseHeader = \lines ->
    lines
    |> Str.split "\n"
    |> List.dropLast
    |> List.map \line ->
        Str.graphemes line
        |> List.keepIf \x -> x >= 'A' && x <= 'Z'
    |> toHeader

toHeader = list ->
    List.last |> Result.withDefault []
    |> List.mapWithIndex \_, idx ->
        List.map list \x -> x |> List.get idx |> Result.withDefault " "
        |> List.keepIf \x -> x != " "
        |> List.reverse

# parseInstructions : Str ->
parseInstructions = \lines ->
    lines
    |> Str.split "\n"
    |> List.map \line ->
        when Str.split line " " is
            [_, move, _, from, _, to] -> {
                    move: move |> Str.toU32 |> Result.withDefault 0,
                    from: from |> Str.toU32 |> Result.withDefault 0,
                    to: to |> Str.toU32 |> Result.withDefault 0
                }
            _ -> crash "parse instructions failed"

process = \game ->
    game.instructions
    |> List.walk game.header \header, instr ->
        toMove =
            List.get header (instr.from - 1)
            |> Result.withDefault []
            |> List.takeLast instr.move

        List.walkWithIndex head
