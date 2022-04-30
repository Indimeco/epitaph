module Page.Poem.Poem_ exposing (Data, Model, Msg, page, timestringToDate)

import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
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
    { poem : String
    }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head -- TODO don't know why this is wrong, type error prob caused by somewhere else, see https://github.com/dillonkearns/elm-pages/blob/master/examples/docs/src/Page/Docs/Section__.elm
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
        |> Glob.match (Glob.literal "content/poems/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource


findBySlug : String -> String -> DataSource String
findBySlug path slug =
    Glob.succeed identity
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal path)
        |> Glob.match (Glob.literal slug)
        |> Glob.match (Glob.literal ".md")
        |> Glob.expectUniqueMatch


data : RouteParams -> DataSource Data
data params =
    params.poem
        |> (++) "content/poems/"
        |> DataSource.File.bodyWithFrontmatter poemDecoder


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
