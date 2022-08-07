module Site exposing (config)

import DataSource
import Head
import MimeType exposing (MimeImage(..))
import Pages.Manifest as Manifest exposing (DisplayMode)
import Pages.Url
import Path exposing (Path)
import Route
import SiteConfig exposing (SiteConfig)


type alias Data =
    ()


config : SiteConfig Data
config =
    { data = data

    -- FIXME elm pages metadata
    , canonicalUrl = ""
    , manifest = manifest
    , head = head
    }


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


head : Data -> List Head.Tag
head static =
    [ Head.sitemapLink "/sitemap.xml"
    , Head.appleTouchIcon (Just 180) (Pages.Url.fromPath <| Path.fromString "/apple-touch-icon.png")
    , Head.metaName "msapplication-TileColor" (Head.raw "#fef7e5")
    ]



{- Elm pages doesn't support certain Head tags, and no arbitrary links
   The following icon assets are missing from this config
   <link rel="manifest" href="/site.webmanifest"> -- elm-pages tries to generate this automatically
   <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#990a29"> -- elm pages doesn't allow for color to be passed to masked images
-}


manifest : Data -> Manifest.Config
manifest static =
    Manifest.init
        { name = "Epitaph"
        , description = "Jacob Lawrence | Epitaph"
        , startUrl = Route.Index |> Route.toPath
        , icons =
            [ Manifest.Icon
                (Pages.Url.fromPath <| Path.fromString "favicon-32x32.png")
                [ ( 32, 32 ) ]
                (Just Png)
                [ Manifest.IconPurposeAny ]
            , Manifest.Icon
                (Pages.Url.fromPath <| Path.fromString "favicon-16x16.png")
                [ ( 16, 16 ) ]
                (Just Png)
                [ Manifest.IconPurposeAny ]
            ]
        }
