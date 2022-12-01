app "main"
    packages { pf: "./roc/examples/interactive/cli-platform/main.roc" }
    imports [pf.Program, pf.Stdout, pf.Task, pf.File, pf.Path]
    provides [main] to pf

main = Program.quick mainTask

mainTask =
    content <- File.readUtf8 (Path.fromStr "input.txt") |> Task.await

    res =
        content
        |> Str.trim
        |> Str.split "\n"
        |> List.mapTry parseLine
        |> Result.map process
        |> Result.map seeDuplicate

    when res is
        Ok set ->
            set
            |> Set.len
            |> Num.toStr
            |> Stdout.line
        Err InvalidNumStr -> Stdout.line "invalid num str"
        Err OutOfBounds -> Stdout.line "out of bounds"

Coordinate : { x1: I32, x2: I32, y1: I32, y2: I32 }
Coord : { x: I32, y: I32 }

seeDuplicate : List Coord -> Set Coord
seeDuplicate = \list ->
    List.walk list { s: Set.empty, d: Set.empty } (\{s, d}, c ->
        if Set.contains s c then
            { d: Set.insert d c, s }
        else
            { s: Set.insert s c, d }
    )
    |> .d

parseLine : Str -> Result Coordinate [InvalidNumStr, OutOfBounds]
parseLine = \line ->
    list = line |> Str.split " -> " |> List.map (\x -> Str.split x ",") |> List.join

    x1 <- List.get list 0 |> Result.try (\x -> Str.toI32 x) |> Result.try
    y1 <- List.get list 1 |> Result.try (\x -> Str.toI32 x) |> Result.try
    x2 <- List.get list 2 |> Result.try (\x -> Str.toI32 x) |> Result.try
    y2 <- List.get list 3 |> Result.try (\x -> Str.toI32 x) |> Result.map

    { x1, y1, x2, y2 }

process : List Coordinate -> List Coord
process = \coord ->
    coord
    |> List.walk [] \l, c ->
        processCoordinate l c

smallest = \a, b ->
    if a < b then a else b

processCoordinate : List Coord, Coordinate -> List Coord
processCoordinate = \list, { x1, x2, y1, y2 } ->
    range =
        # diagonal
        if x1 - x2 == y2 - y1 || x2 - x1 == y2 - y1 then
            if x1 < x2 then
                if y1 < y2 then
                    { type: Up, x: x1, y: y1, len: y2 - y1 }
                else
                    { type: Down, x: x1, y: y1, len: y1 - y2 }
            else
                if y1 < y2 then
                    { type: Down, x: x2, y: y2, len: y2 - y1 }
                else
                    { type: Up, x: x2, y: y2, len: y1 - y2 }
        # horizontal
        else if x1 == x2 then
            { type: Y, x: x1, y: smallest y1 y2, len: Num.abs (y1 - y2) }
        # vertical
        else if y1 == y2 then
            { type: X, x: smallest x1 x2, y: y1, len: Num.abs (x1 - x2) }
        # others
        else
            { type: None, x: 0, y: 0, len: 0 }

    if range.type == None then
        list
    else
        List.walk (List.range 0 (range.len + 1)) list \l, idx ->
            { x, y } =
                when range.type is
                    X -> { x: range.x + idx, y: range.y }
                    Y -> { x: range.x, y: range.y + idx }
                    Up -> { x: range.x + idx, y: range.y + idx }
                    Down -> { x: range.x + idx, y: range.y - idx }
                    _ -> { x: 0, y: 0 } # Should never happen

            List.append l { x, y }
