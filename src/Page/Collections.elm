module Page.Collections exposing (..)

import Array exposing (Array)
import Browser.Navigation
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Markdown.Parser
import Markdown.Renderer
import Page exposing (PageWithState, StaticPayload)
import Pages.Manifest exposing (DisplayMode(..))
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path exposing (Path)
import Shared
import Util.CollectionData exposing (CollectionData, collections)
import Util.Error exposing (errorMessage)
import Util.Poem exposing (PoemNode(..))
import Util.PoemData exposing (poemUrl)
import View exposing (View)


type alias Model =
    String


type Msg
    = Select String


init : Maybe PageUrl -> Shared.Model -> StaticPayload templateData routeParams -> ( Model, Cmd Msg )
init pageUrl sharedModel static =
    ( "", Cmd.none )


subscriptions : Maybe PageUrl -> routeParams -> Path -> Model -> Sub Msg
subscriptions pageUrl routeParams path model =
    Sub.none


update : PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> StaticPayload templateData routeParams -> Msg -> Model -> ( Model, Cmd Msg )
update pageUrl key sharedModel static msg model =
    case msg of
        Select s ->
            if s == model then
                ( "", Cmd.none )

            else
                ( s, Cmd.none )


type alias RouteParams =
    {}


type alias Data =
    List CollectionData


page : PageWithState RouteParams Data Model Msg
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithLocalState { view = view, init = init, subscriptions = subscriptions, update = update }


data : DataSource Data
data =
    collections


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "epitaph"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "epitaph logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel model static =
    { title = "test"
    , body =
        [ Html.h1 [ Html.Attributes.class "collection__heading" ]
            [ Html.text "Collections" ]
        , Html.div [ Html.Attributes.class "collections" ] (List.map (\collectionData -> collectionTile collectionData model) static.data)
        ]
    }


deadEndsToString deadEnds =
    deadEnds
        |> List.map Markdown.Parser.deadEndToString
        |> String.join "\n"


collectionTile : CollectionData -> String -> Html Msg
collectionTile { id, body, date, poems, title } selectedCollection =
    let
        selectedClass =
            if selectedCollection == title then
                "collections__tile--selected"

            else
                ""
    in
    Html.button [ Html.Attributes.class "collections__tile", Html.Events.onClick (Select title), Html.Attributes.class selectedClass ]
        [ Html.div [ Html.Attributes.class "collections__tile__header" ]
            [ Html.h2 [ Html.Attributes.class "collections__tile__header__title" ] [ Html.text title ]
            , Html.span [ Html.Attributes.class "collections__tile__header__date" ] [ Html.text date ]
            ]
        , Html.div [ Html.Attributes.class "collections__tile__content" ]
            (body
                |> Markdown.Parser.parse
                |> Result.mapError deadEndsToString
                |> Result.andThen (\ast -> Markdown.Renderer.render Markdown.Renderer.defaultHtmlRenderer ast)
                |> Result.withDefault [ errorMessage ]
            )
        , Html.ol [ Html.Attributes.class "collections__tile__poems" ] <|
            List.map (\p -> Html.li [] [ Html.a [ Html.Attributes.href <| poemUrl id p ] [ Html.text p ] ]) (Array.toList poems)
        ]
