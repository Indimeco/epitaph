module Page.Poem.Poem_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Head
import Head.Seo as Seo
import Html exposing (Html, div, h2, text)
import Html.Attributes exposing (class)
import List exposing (map)
import OptimizedDecoder exposing (Decoder)
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import Util.Poem exposing (..)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { poem : String
    }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = pages
        , data = data
        }
        |> Page.buildNoState
            { view = view
            }


pages : DataSource (List RouteParams)
pages =
    poems
        |> DataSource.map
            (List.map
                (\p ->
                    { poem = p }
                )
            )


poems : DataSource (List String)
poems =
    Glob.succeed (\slug -> slug)
        |> Glob.match (Glob.literal poemPath)
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource


data : RouteParams -> DataSource Data
data params =
    params.poem
        |> (++) poemPath
        |> (\s -> s ++ ".md")
        |> DataSource.File.bodyWithFrontmatter poemDecoder


type alias Data =
    { body : String
    , date : String
    }


poemDecoder : String -> Decoder Data
poemDecoder body =
    OptimizedDecoder.map (Data body)
        (OptimizedDecoder.field poemDateMetadataKey OptimizedDecoder.string)


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "repertoire"
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
        [ div []
            [ div [ class "poem__date" ] [ text (timestringToDate static.data.date) ]
            , div [ class "poem__body" ] (markdownToPoemHtml static.data.body)
            ]
        ]
    }


markdownToPoemHtml : String -> List (Html msg)
markdownToPoemHtml markdown =
    markdown
        |> markdownToPoemNodes
        |> map poemNodeToHtml


poemNodeToHtml : PoemNode -> Html msg
poemNodeToHtml node =
    case node of
        BlankLine ->
            div [ class "poem__body__blankline" ] []

        Line t ->
            div [ class "poem__body__line" ] [ text t ]

        Title t ->
            h2 [ class "poem__body__title" ] [ text t ]
