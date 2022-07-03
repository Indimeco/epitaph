module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Browser.Navigation
import Components.MenuSvg exposing (menuSvg)
import DataSource
import Html exposing (Html, div)
import Html.Attributes
import Html.Events
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    }


type Msg
    = OnPageChange
        { path : Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | ShowMenu Bool
    | SharedMsg SharedMsg


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    { showMenu : Bool
    }


init :
    Maybe Browser.Navigation.Key
    -> Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : Path
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Cmd Msg )
init navigationKey flags maybePagePath =
    ( { showMenu = False }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | showMenu = False }, Cmd.none )

        SharedMsg globalMsg ->
            ( model, Cmd.none )

        ShowMenu s ->
            ( { model | showMenu = s }, Cmd.none )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


view :
    Data
    ->
        { path : Path
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : Html msg, title : String }
view sharedData page model toMsg pageView =
    { body =
        let
            navActiveClass =
                if model.showMenu == True then
                    "nav--active"

                else
                    ""
        in
        div [ Html.Attributes.id "background" ]
            [ Html.div [ Html.Attributes.class "nav__control", Html.Attributes.class navActiveClass, Html.Events.onClick (toMsg (ShowMenu <| not model.showMenu)) ]
                [ Html.div
                    [ Html.Attributes.class "nav__control__context", Html.Attributes.attribute "role" "button" ]
                    [ Html.div
                        [ Html.Attributes.class "nav__control__icon" ]
                        [ menuSvg ]
                    , Html.h1 [ Html.Attributes.class "nav__control__heading" ] [ Html.text "Epitaph" ]
                    ]
                ]
            , Html.nav [ Html.Attributes.class "nav", Html.Attributes.class navActiveClass ]
                [ Html.div [ Html.Attributes.class "nav__body" ]
                    [ Html.a [ Html.Attributes.href "/" ]
                        [ Html.h2 [ Html.Attributes.class "nav__body__heading" ] [ Html.text "Epitaph" ]
                        ]
                    , Html.ul [] [ Html.li [] [ Html.a [ Html.Attributes.href "/collections" ] [ Html.text "collections" ] ] ]
                    ]
                ]
            , div [ Html.Attributes.id "book", Html.Events.onClick (toMsg (ShowMenu False)), Html.Attributes.class navActiveClass ] [ Html.section [] pageView.body ]
            ]
    , title = pageView.title
    }
