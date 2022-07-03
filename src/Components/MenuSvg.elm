module Components.MenuSvg exposing (..)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)


menuSvg : Html msg
menuSvg =
    svg [ version "1.1", viewBox "0 0 16 16" ] [ g [ fill "none", stroke "inherit", strokeLinecap "round", strokeWidth "1px" ] [ Svg.path [ d "m1 4h3" ] [], Svg.path [ d "m6 4h5" ] [], Svg.path [ d "m13 4h2" ] [], Svg.path [ d "m1 8h5" ] [], Svg.path [ d "m8 8h3" ] [], Svg.path [ d "m1 12h2" ] [], Svg.path [ d "m5 12h5" ] [], Svg.path [ d "m12 12h1" ] [] ] ]
