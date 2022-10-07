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
            # |> Set.toList
            # |> List.map (\i -> Str.concat (Num.toStr i.x) ":" |> Str.concat (Num.toStr i.y))
            # |> Str.joinWith "\n"
            |> Num.toStr
            |> Stdout.line
        Err InvalidNumStr -> Stdout.line "invalid num str"
        Err OutOfBounds -> Stdout.line "out of bounds"

Coordinate : { x1: U32, x2: U32, y1: U32, y2: U32 }
Coord : { x: U32, y: U32 }

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

    x1 <- List.get list 0 |> Result.try (\x -> Str.toU32 x) |> Result.try
    y1 <- List.get list 1 |> Result.try (\x -> Str.toU32 x) |> Result.try
    x2 <- List.get list 2 |> Result.try (\x -> Str.toU32 x) |> Result.try
    y2 <- List.get list 3 |> Result.try (\x -> Str.toU32 x) |> Result.map

    { x1, y1, x2, y2 }

process : List Coordinate -> List Coord
process = \coord ->
    coord
    |> List.walk [] \l, c ->
        processCoordinate l c

processCoordinate : List Coord, Coordinate -> List Coord
processCoordinate = \list, coord ->
    range =
        if coord.x1 == coord.x2 then
            if coord.y1 > coord.y2 then
                { type: Y, x: coord.x1, y: coord.y2, len: coord.y1 - coord.y2 }
            else
                { type: Y, x: coord.x1, y: coord.y1, len: coord.y2 - coord.y1 }
        else if coord.x1 > coord.x2 then
            { type: X, x: coord.x2, y: coord.y1, len: coord.x1 - coord.x2 }
        else
            { type: X, x: coord.x1, y: coord.y1, len: coord.x2 - coord.x1 }

    if coord.x1 != coord.x2 && coord.y1 != coord.y2 then
        list
    else
        List.walk (List.range 0 (range.len + 1)) list \l, idx ->
            { x, y } =
                when range.type is
                    X -> { x: range.x + idx, y: range.y }
                    Y -> { x: range.x, y: range.y + idx }

            List.append l { x, y }
