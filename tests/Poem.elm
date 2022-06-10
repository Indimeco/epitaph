module Poem exposing (..)

import Expect
import Test exposing (..)
import Util.Poem exposing (..)


suite : Test
suite =
    describe "Poem utilities"
        [ describe "timestampToDate"
            -- Nest as many descriptions as you like.
            [ test "returns a date from a date" <|
                \_ ->
                    "2021-04-05"
                        |> timestringToDate
                        |> Expect.equal "2021-04-05"
            , test "returns a date from a timestring" <|
                \_ ->
                    "2021-04-05 18:40:32"
                        |> timestringToDate
                        |> Expect.equal "2021-04-05"
            , test "returns a date from a timestring with zone" <|
                \_ ->
                    "2021-04-05 18:39:22 +1000"
                        |> timestringToDate
                        |> Expect.equal "2021-04-05"
            , test "returns undated from a bad timestring" <|
                \_ ->
                    "222222"
                        |> timestringToDate
                        |> Expect.equal "undated"
            , test "returns undated from an empty timestring" <|
                \_ ->
                    ""
                        |> timestringToDate
                        |> Expect.equal "undated"
            ]
        , describe
            "parsePoem newlines"
            [ test "removes blank line at the beginning of text" <|
                \_ ->
                    "\nA bee\nStaggers out\nOf the peony"
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Line "A bee"
                            , Line "Staggers out"
                            , Line
                                "Of the peony"
                            ]
            , test "removes blank line at the end of text" <|
                \_ ->
                    "A bee\nStaggers out\nOf the peony\n"
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Line "A bee"
                            , Line "Staggers out"
                            , Line
                                "Of the peony"
                            ]
            , test "removes blank line at the beginning and  end of text" <|
                \_ ->
                    "\nA bee\nStaggers out\nOf the peony\n"
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Line "A bee"
                            , Line "Staggers out"
                            , Line
                                "Of the peony"
                            ]
            ]
        , describe
            "parsePoem titles"
            [ test "gets title at the beginning of the poem" <|
                \_ ->
                    "# Child\nYour clear eye is the one absolutely beautiful thing\nI want to fill it with color and ducks\nThe zoo of the new"
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Title "Child"
                            , Line "Your clear eye is the one absolutely beautiful thing"
                            , Line
                                "I want to fill it with color and ducks"
                            , Line "The zoo of the new"
                            ]
            , test "Allows the poem to have multiple titles in the middle of the poem" <|
                \_ ->
                    "# I\nBirth\n# II\nChildhood"
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Title "I"
                            , Line "Birth"
                            , Title
                                "II"
                            , Line "Childhood"
                            ]
            , test "Doesn't add titles to untitled poems" <|
                \_ ->
                    "green, gray\nI painted from a nothing"
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Line "green, gray"
                            , Line "I painted from a nothing"
                            ]
            ]
        , describe
            "parsePoem blank lines"
            [ test "doesn't add blank lines to the beginning of poems" <|
                \_ ->
                    "\n\ni am nobody\n"
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Line "i am nobody"
                            ]
            , test "doesn't add blank lines to the end of poems" <|
                \_ ->
                    "i am nobody\n\n"
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Line "i am nobody"
                            ]
            , test "allows extra blank lines to the middle of poems" <|
                \_ ->
                    "i am nobody\n\n\nwho are you?"
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Line "i am nobody"
                            , BlankLine
                            , BlankLine
                            , Line "who are you?"
                            ]
            , test "doesn't add blank lines after titles" <|
                \_ ->
                    "# The Nightdances\n\nA smile fell in the grass."
                        |> markdownToPoemNodes
                        |> Expect.equal
                            [ Title "The Nightdances"
                            , Line "A smile fell in the grass."
                            ]
            ]
        ]
