module Util.CollectionData exposing (..)

import Array exposing (Array)
import DataSource exposing (..)
import DataSource.File
import DataSource.Glob as Glob
import OptimizedDecoder exposing (Decoder)
import Util.Data exposing (mdFile)
import Util.Poem exposing (timestringToDate)


collectionPath : String
collectionPath =
    "content/collections/"


type alias CollectionData =
    { body : String
    , id : String
    , title : String
    , poems : Array String
    , date : String
    }


collections : DataSource (List CollectionData)
collections =
    collectionPaths
        |> DataSource.map (List.map (\{ filePath, id } -> DataSource.File.bodyWithFrontmatter (collectionDecoder id) filePath))
        |> DataSource.resolve


collectionDecoder : String -> String -> Decoder CollectionData
collectionDecoder path body =
    OptimizedDecoder.map3 (CollectionData body path)
        (OptimizedDecoder.field "title" OptimizedDecoder.string)
        (OptimizedDecoder.field "poems" (OptimizedDecoder.array <| OptimizedDecoder.map timestringToDate <| OptimizedDecoder.string))
        (OptimizedDecoder.field "created" (OptimizedDecoder.map timestringToDate OptimizedDecoder.string))


collectionPaths : DataSource (List { filePath : String, id : String })
collectionPaths =
    Glob.succeed (\filePath id -> { filePath = filePath, id = id })
        |> Glob.captureFilePath
        |> mdFile collectionPath
        |> Glob.toDataSource


getCollection : String -> DataSource CollectionData
getCollection id =
    id
        |> (++) collectionPath
        |> (\s -> s ++ ".md")
        |> DataSource.File.bodyWithFrontmatter (collectionDecoder id)
