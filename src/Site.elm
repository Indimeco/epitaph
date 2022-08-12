module Site exposing (config, getSiteHead, pageTitle, siteDescription, siteName)

import DataSource
import Head
import Head.Seo
import MimeType exposing (MimeImage(..))
import Pages.Manifest as Manifest
import Pages.Url
import Path
import Route
import SiteConfig exposing (SiteConfig)


siteName : String
siteName =
    "epitaph"


siteDescription : String
siteDescription =
    "words written by Jacob Lawrence"


type alias Data =
    ()


config : SiteConfig Data
config =
    { data = data
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
        { name = siteName
        , description = siteDescription
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


pageTitle : String -> String
pageTitle title =
    siteName ++ " | " ++ title


getSiteHead : String -> List Head.Tag
getSiteHead title =
    Head.Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = siteName
        , image =
            { url = Pages.Url.external "/mstile-310x310.png"
            , alt = "epitaph logo"
            , dimensions = Just { width = 310, height = 310 }
            , mimeType = Just "png"
            }
        , description = siteDescription
        , locale = Nothing
        , title = pageTitle title
        }
        |> Head.Seo.website
