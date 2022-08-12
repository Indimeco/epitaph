module Page.About exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import Head
import Head.Seo as Seo
import Html exposing (Html, a, b, div, h1, section, text)
import Html.Attributes exposing (class, href)
import Markdown.Parser
import Markdown.Renderer
import OptimizedDecoder exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Page.Collections exposing (deadEndsToString)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import Site exposing (getSiteHead, pageTitle)
import Util.Error exposing (errorMessage)
import Util.Poem exposing (PoemNode(..), markdownToPoemNodes, timestringToDate)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


type alias Data =
    String


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    DataSource.File.bodyWithoutFrontmatter "content/about.md"


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    getSiteHead "about"


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = pageTitle "about"
    , body =
        [ Html.section [ Html.Attributes.class "prose" ]
            (static.data
                |> Markdown.Parser.parse
                |> Result.mapError deadEndsToString
                |> Result.andThen (\ast -> Markdown.Renderer.render Markdown.Renderer.defaultHtmlRenderer ast)
                |> Result.withDefault [ errorMessage ]
            )
        ]
    }
