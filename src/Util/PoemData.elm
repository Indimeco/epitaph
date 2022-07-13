module Util.PoemData exposing (..)

import Array exposing (Array)
import DataSource exposing (..)
import DataSource.File
import DataSource.Glob as Glob
import OptimizedDecoder exposing (Decoder)
import Util.Poem exposing (PoemNode, getTitle, markdownToPoemNodes, timestringToDate)


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
    { body : List PoemNode
    , date : String
    , title : Maybe String
    }


poemDecoder : String -> Decoder DecodedPoem
poemDecoder body =
    let
        poem =
            markdownToPoemNodes body
    in
    OptimizedDecoder.map2 (DecodedPoem <| poem)
        (OptimizedDecoder.field "created" (OptimizedDecoder.map timestringToDate OptimizedDecoder.string))
        (OptimizedDecoder.succeed <| getTitle poem)


getPoem : String -> DataSource DecodedPoem
getPoem id =
    id
        |> (++) poemPath
        |> (\s -> s ++ ".md")
        |> DataSource.File.bodyWithFrontmatter poemDecoder
