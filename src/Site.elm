module Site exposing (config)

import DataSource
import Head
import Pages.Manifest as Manifest
import Route
import SiteConfig exposing (SiteConfig)


type alias Data =
    ()


config : SiteConfig Data
config =
    { data = data

    -- FIXME elm pages metadata
    , canonicalUrl = "https://epitaph.com"
    , manifest = manifest
    , head = head
    }


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


head : Data -> List Head.Tag
head static =
    [ Head.sitemapLink "/sitemap.xml"
    ]


manifest : Data -> Manifest.Config
manifest static =
    Manifest.init
        { name = "Epitaph"
        , description = "Jacob Lawrence | Epitaph"
        , startUrl = Route.Index |> Route.toPath
        , icons = []
        }
