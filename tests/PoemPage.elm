module PoemPage exposing (..)

import Array exposing (Array)
import DataSource.Http exposing (Expect)
import Expect
import Page.Collection.Collection_.Poem.Poem_ exposing (nextEl, prevEl)
import Test exposing (..)


suite : Test
suite =
    describe "The poem page"
        [ describe "nextEl"
            [ test "gets next element in an array" <|
                \_ ->
                    Array.fromList [ 0, 1, 2, 3 ]
                        |> nextEl 0
                        |> Expect.equal (Just 1)
            , test "gets nothing when current element is last" <|
                \_ ->
                    Array.fromList [ 0, 1 ]
                        |> nextEl 1
                        |> Expect.equal Nothing
            ]
        , describe "prevEl"
            -- Nest as many descriptions as you like.
            [ test "gets prev element in an array" <|
                \_ ->
                    Array.fromList [ 0, 1, 2, 3 ]
                        |> prevEl 1
                        |> Expect.equal (Just 0)
            , test "gets nothing when current element is last" <|
                \_ ->
                    Array.fromList [ 0, 1 ]
                        |> prevEl 0
                        |> Expect.equal Nothing
            ]
        ]
