module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import Head
import Head.Seo as Seo
import Html exposing (Html, div, text)
import List exposing (map)
import OptimizedDecoder exposing (Decoder)
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
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


markdownToView : String -> List (Html msg)
markdownToView markdownString =
    markdownString
        |> String.split "\n"
        |> map (\line -> div [] [ text line ])


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "test"
    , body =
        [ div []
            [ div [] [ text static.data.date ]
            , div [] (markdownToView static.data.body)
            ]
        ]
    }
