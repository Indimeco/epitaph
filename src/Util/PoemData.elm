module Util.PoemData exposing (..)

import Array exposing (Array)
import DataSource exposing (..)
import DataSource.File
import DataSource.Glob as Glob
import OptimizedDecoder exposing (Decoder)
import Util.Poem exposing (timestringToDate)


poemPath : String
poemPath =
    "content/poems/"


poemUrl : String -> String -> String
poemUrl collection poem =
    "/collection/" ++ collection ++ "/poem/" ++ poem


poemDateMetadataKey : String
poemDateMetadataKey =
    "created"


poems : DataSource (List String)
poems =
    Glob.succeed (\slug -> slug)
        |> Glob.match (Glob.literal poemPath)
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource


type alias DecodedPoem =
    { body : String
    , date : String
    }


poemDecoder : String -> Decoder DecodedPoem
poemDecoder body =
    OptimizedDecoder.map (DecodedPoem body) <|
        OptimizedDecoder.map timestringToDate (OptimizedDecoder.field poemDateMetadataKey OptimizedDecoder.string)


getPoem : String -> DataSource DecodedPoem
getPoem id =
    id
        |> (++) poemPath
        |> (\s -> s ++ ".md")
        |> DataSource.File.bodyWithFrontmatter poemDecoder
