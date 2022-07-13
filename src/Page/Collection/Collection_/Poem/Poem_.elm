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
import Util.CollectionData exposing (collections, getCollection)
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
    collections
        |> DataSource.map
            (List.concatMap
                (\collection ->
                    List.map (\p -> { collection = collection.id, poem = p }) (Array.toList collection.poems)
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
                    -- REVIEW extract and test
                    Array.toIndexedList c.poems |> List.filter (\( _, v ) -> v == params.poem) |> List.head |> Maybe.withDefault ( 1, "" ) |> Tuple.first
            in
            { body = p.body, date = p.date, nextPoem = nextEl currentIndex c.poems, prevPoem = prevEl currentIndex c.poems, collectionId = params.collection, title = p.title }
        )
        poem
        collection


type alias Data =
    { collectionId : String
    , body : List PoemNode
    , date : String
    , nextPoem : Maybe String
    , prevPoem : Maybe String
    , title : Maybe String
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
            , alt = "epitaph logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing

        -- REVIEW what's the best way to share titles
        , title = "epitaph | " ++ Maybe.withDefault static.data.date static.data.title
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "epitaph | " ++ Maybe.withDefault static.data.date static.data.title
    , body =
        [ div [ class "poem" ]
            [ div [ class "poem__prevnext" ]
                [ prevNextLink "prev" static.data.collectionId static.data.prevPoem
                , prevNextLink "next" static.data.collectionId static.data.nextPoem
                ]
            , div [ class "poem__date" ] [ text static.data.date ]
            , section [ class "poem__body" ] (List.map poemNodeToHtml <| static.data.body)
            ]
        ]
    }


prevNextLink : String -> String -> Maybe String -> Html msg
prevNextLink txt collectionId link =
    case link of
        Nothing ->
            a [ class "poem__prevnext__link poem__prevnext__link--disabled" ] [ text txt ]

        Just x ->
            a [ class "poem__prevnext__link", href <| poemUrl collectionId x ] [ text txt ]


poemNodeToHtml : PoemNode -> Html msg
poemNodeToHtml node =
    case node of
        BlankLine ->
            div [ class "poem__body__blankline" ] []

        Line t ->
            div [ class "poem__body__line" ] [ text t ]

        Title t ->
            h2 [ class "poem__body__title" ] [ text t ]
