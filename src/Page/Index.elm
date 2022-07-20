module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (Html, p, a, b, div, h1, section, text)
import Html.Attributes exposing (class, href)
import OptimizedDecoder exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
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
    DataSource.succeed "No"


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "epitaph"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "epitaph logo"
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
    { title = "home"
    , body =
        [ section [ class "home"] [
         h1 [ class "home__title" ]
            [ text "Epitaph" ]
        , p
            [ class "home__subtitle" ]
            [ text "Something" ]
        , section [ class "home__showcase" ] [ 
           a [ href "/collections" ] [ text "collections" ],
           a [ href "/about" ] [ text "about" ]
           ]
        ]]
    }
