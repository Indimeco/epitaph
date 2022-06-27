module Page.Collection.Collection_.Poem.Poem_ exposing (Data, Model, Msg, nextEl, page, prevEl)

import Array exposing (Array)
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (Html, a, div, h2, section, text)
import Html.Attributes exposing (class, href)
import List exposing (map)
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import Util.CollectionData exposing (getCollection)
import Util.Poem exposing (..)
import Util.PoemData exposing (getPoem, poemUrl, poems)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { collection : String
    , poem : String
    }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState
            { view = view
            }


nextEl : Int -> Array a -> Maybe a
nextEl currentIndex arr =
    Array.get (currentIndex + 1) arr


prevEl : Int -> Array a -> Maybe a
prevEl currentIndex arr =
    Array.get (currentIndex - 1) arr


routes : DataSource (List RouteParams)
routes =
    poems
        |> DataSource.map
            (List.map
                (\p ->
                    -- FIXME only epitaph collection is available here
                    { collection = "epitaph", poem = p }
                )
            )


data : RouteParams -> DataSource Data
data params =
    let
        poem =
            params.poem
                |> getPoem

        collection =
            params.collection
                |> getCollection
    in
    DataSource.map2
        (\p c ->
            let
                currentIndex =
                    Array.toIndexedList c.poems |> List.filter (\( _, v ) -> v == params.poem) |> List.head |> Maybe.withDefault ( 1, "" ) |> Tuple.first
            in
            { body = p.body, date = p.date, nextPoem = nextEl currentIndex c.poems, prevPoem = prevEl currentIndex c.poems }
        )
        poem
        collection


type alias Data =
    { body : String
    , date : String
    , nextPoem : Maybe String
    , prevPoem : Maybe String
    }


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
        [ div [ class "poem" ]
            [ div [ class "poem__prevnext" ] [ prevNextLink "prev" static.data.prevPoem, prevNextLink "next" static.data.nextPoem ]
            , div [ class "poem__date" ] [ text static.data.date ]
            , section [ class "poem__body" ] (markdownToPoemHtml static.data.body)
            ]
        ]
    }


prevNextLink : String -> Maybe String -> Html msg
prevNextLink txt link =
    case link of
        Nothing ->
            a [ class "poem__prevnext__link poem__prevnext__link--disabled" ] [ text txt ]

        Just x ->
            -- FIXME pass collection to poem url
            a [ class "poem__prevnext__link", href <| poemUrl "epitaph" x ] [ text txt ]


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
