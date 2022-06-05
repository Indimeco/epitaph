module Util.Poem exposing (..)

import List exposing (foldl, map)
import Regex exposing (Regex)


poemPath : String
poemPath =
    "content/poems/"


poemDateMetadataKey : String
poemDateMetadataKey =
    "created"


type PoemNode
    = Line String
    | BlankLine
    | Title String


extraneousBlanksRegex : Regex
extraneousBlanksRegex =
    Maybe.withDefault Regex.never <|
        Regex.fromString <|
            foldl (++)
                ""
                [ "^\n+" -- beginning newlines
                , "|"
                , "\n+$" -- ending newlines
                , "|"
                , "(?<=#.+\n)\n" -- newlines after titles
                ]


markdownToPoemNodes : String -> List PoemNode
markdownToPoemNodes markdownString =
    markdownString
        |> Regex.replace extraneousBlanksRegex (\_ -> "")
        |> String.split "\n"
        |> map
            (\text ->
                if String.isEmpty text then
                    BlankLine

                else if String.startsWith "#" text then
                    Title <| String.replace "# " "" text

                else
                    Line text
            )


timestringRegex : Regex
timestringRegex =
    Maybe.withDefault Regex.never <| Regex.fromString "^\\d\\d\\d\\d\\-\\d\\d\\-\\d\\d"


timestringToDate : String -> String
timestringToDate timestring =
    timestring
        |> Regex.find timestringRegex
        |> map .match
        |> List.head
        |> Maybe.withDefault "undated"
