module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import Head
import Head.Seo as Seo
import Html exposing (Html, a, b, div, h1, section, text)
import Html.Attributes exposing (class, href)
import OptimizedDecoder exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import Util.Poem exposing (PoemNode(..), markdownToPoemNodes, poemDateMetadataKey, poemPath, timestringToDate)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


type alias PoemPreview =
    { body : List PoemNode
    , date : String
    }


type alias Data =
    List PoemPreview


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }



-- this decoder stuff is really a mess, should be refactored


poemDecoder : String -> Decoder PoemPreview
poemDecoder body =
    OptimizedDecoder.map (PoemPreview <| markdownToPoemNodes body)
        (OptimizedDecoder.field poemDateMetadataKey (OptimizedDecoder.map timestringToDate OptimizedDecoder.string))


data : DataSource Data
data =
    Glob.succeed identity
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal poemPath)
        |> Glob.match Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource
        |> DataSource.map (List.map (DataSource.File.bodyWithFrontmatter poemDecoder))
        |> DataSource.resolve


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
        [ h1 [ class "poems__heading" ]
            [ text "Poems" ]
        , section
            [ class "poems" ]
          <|
            List.map poemPreviewHtml static.data
        ]
    }


poemPreviewHtml : PoemPreview -> Html msg
poemPreviewHtml prev =
    a [ class "poems__link", href ("/poem/" ++ prev.date) ] [ text prev.date ]
