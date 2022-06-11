module Page.Collections exposing (..)

import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes
import Markdown.Parser
import Markdown.Renderer
import OptimizedDecoder exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import Util.Poem exposing (PoemNode(..), timestringToDate)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


type alias CollectionData =
    { body : String
    , title : String
    , poems : List String
    , date : String
    }


type alias Data =
    List CollectionData


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    Glob.succeed identity
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/collections/")
        |> Glob.match Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource
        |> DataSource.map (List.map (DataSource.File.bodyWithFrontmatter collectionDecoder))
        |> DataSource.resolve


collectionDecoder : String -> Decoder CollectionData
collectionDecoder body =
    OptimizedDecoder.map3 (CollectionData <| body)
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
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "test"
    , body =
        [ Html.h1 [ Html.Attributes.class "collection__heading" ]
            [ Html.text "Collections" ]
        , Html.div [ Html.Attributes.class "collections" ] (List.map collectionTile static.data)
        ]
    }


deadEndsToString deadEnds =
    deadEnds
        |> List.map Markdown.Parser.deadEndToString
        |> String.join "\n"


collectionTile : CollectionData -> Html msg
collectionTile { body, date, poems, title } =
    Html.button [ Html.Attributes.class "collections__tile" ]
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
            List.map (\p -> Html.li [] [ Html.a [ Html.Attributes.href p ] [ Html.text p ] ]) poems
        ]


errorMessage : Html msg
errorMessage =
    Html.div [ Html.Attributes.class "error" ] [ Html.text "An error occurred / cosmic rays from newborn stars / or human folly" ]
