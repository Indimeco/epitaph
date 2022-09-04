module Util.Data exposing (..)

import DataSource.Glob as Glob
import Path
import Route exposing (Route)


mdFile : String -> Glob.Glob (String -> value) -> Glob.Glob value
mdFile path glob =
    glob
        |> Glob.match (Glob.literal path)
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")



-- elm-pages has a horrendous way of specifying base url
-- which requires all links to be wrapped in a few helper functions
-- to ensure they continue to work when deployed in different subdomains/paths


relativeUrl : Route -> String
relativeUrl =
    Route.toPath >> Path.toAbsolute
