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


poemPath =
    "content/poems/"


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
        (OptimizedDecoder.field "created" OptimizedDecoder.string)


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


poemNode : String -> Html msg
poemNode lineText =
    if String.startsWith "# " lineText then
        lineText
            |> String.replace "# " ""
            |> (\t -> div [ class "title" ] [ text t ])

    else if String.isEmpty lineText then
        div [ class "blank-line" ] []

    else
        div [ class "line" ] [ text lineText ]



-- FIXME incomplete function
-- filterPoemTrailingBlanks : List (Html msg) -> List (Html msg)
-- filterPoemTrailingBlanks list =
--     case list of
--         [] ->
--             []
--         x :: xs ->
--             if x == "title" && List.head xs == "blank-line" then
--                 -- remove blank line
--                 xs
--             else if List.tail xs == "blank-line" then
--                 -- remove blank line
--                 xs
--             else
--                 xs


markdownToHtml : String -> List (Html msg)
markdownToHtml markdownString =
    markdownString
        |> String.split "\n"
        |> List.map poemNode


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
