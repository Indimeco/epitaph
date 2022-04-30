module Poem exposing (..)

import Expect
import Page.Poem.Poem_ exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "The poem page"
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
        ]
