module Page.Index exposing (Data, Model, Msg, page, timestringToDate)

import DataSource exposing (DataSource)
import DataSource.File
import Head
import Head.Seo as Seo
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import List exposing (map)
import OptimizedDecoder exposing (Decoder)
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Regex exposing (Regex)
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    DataSource.File.bodyWithFrontmatter poemDecoder "content/poems/2021-04-05.md"


type alias Data =
    { body : String
    , date : String
    }


poemDecoder : String -> Decoder Data
poemDecoder body =
    OptimizedDecoder.map (Data body)
        (OptimizedDecoder.field "created" OptimizedDecoder.string)


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


markdownToHtml : String -> List (Html msg)
markdownToHtml markdownString =
    markdownString
        |> String.split "\n"
        |> map (\line -> div [ class "line" ] [ text line ])


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


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "test"
    , body =
        [ div []
            [ div [ class "date" ] [ text (timestringToDate static.data.date) ]
            , div [ class "poem" ] (markdownToHtml static.data.body)
            ]
        ]
    }
