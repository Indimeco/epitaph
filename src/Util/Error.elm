module Util.Error exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


errorMessage : Html msg
errorMessage =
    Html.div [ Html.Attributes.class "error" ] [ Html.text "An error occurred / cosmic rays from newborn stars / or human folly" ]
