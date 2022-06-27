module Util.Data exposing (..)

import DataSource.Glob as Glob


mdFile : String -> Glob.Glob (String -> value) -> Glob.Glob value
mdFile path glob =
    glob
        |> Glob.match (Glob.literal path)
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
