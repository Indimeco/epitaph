module Page.Collections exposing (..)

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Markdown.Parser
import Markdown.Renderer
import OptimizedDecoder exposing (Decoder)
import Page exposing (PageWithState, StaticPayload)
import Pages.Manifest exposing (DisplayMode(..))
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path exposing (Path)
import Shared
import Util.Poem exposing (PoemNode(..), poemUrl, timestringToDate)
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


type alias CollectionData =
    { body : String
    , id : String
    , title : String
    , poems : List String
    , date : String
    }


type alias Data =
    List CollectionData


page : PageWithState RouteParams Data Model Msg
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithLocalState { view = view, init = init, subscriptions = subscriptions, update = update }


collectionPaths : DataSource (List { filePath : String, id : String })
collectionPaths =
    Glob.succeed (\filePath id -> { filePath = filePath, id = id })
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/collections/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource


data : DataSource Data
data =
    collectionPaths
        |> DataSource.map (List.map (\{ filePath, id } -> DataSource.File.bodyWithFrontmatter (collectionDecoder id) filePath))
        |> DataSource.resolve


collectionDecoder : String -> String -> Decoder CollectionData
collectionDecoder path body =
    OptimizedDecoder.map3 (CollectionData body path)
        (OptimizedDecoder.field "title" OptimizedDecoder.string)
        (OptimizedDecoder.field "poems" (OptimizedDecoder.map (String.split " ") OptimizedDecoder.string))
        (OptimizedDecoder.field "created" (OptimizedDecoder.map timestringToDate OptimizedDecoder.string))


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
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
            List.map (\p -> Html.li [] [ Html.a [ Html.Attributes.href <| poemUrl id p ] [ Html.text p ] ]) poems
        ]


errorMessage : Html msg
errorMessage =
    Html.div [ Html.Attributes.class "error" ] [ Html.text "An error occurred / cosmic rays from newborn stars / or human folly" ]
