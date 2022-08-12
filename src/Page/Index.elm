module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head
import Html exposing (a, h1, p, section, text)
import Html.Attributes exposing (class, href)
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Shared
import Site exposing (getSiteHead, pageTitle)
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
    getSiteHead "home"


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = pageTitle "home"
    , body =
        [ section [ class "home" ]
            [ h1 [ class "home__title" ]
                [ text Site.siteName ]
            , p
                [ class "home__subtitle" ]
                [ text Site.siteDescription ]
            , section [ class "home__showcase" ]
                [ a [ href "/collections" ] [ text "collections" ]
                , a [ href "/about" ] [ text "about" ]
                ]
            ]
        ]
    }
