module Bricks.Json
    exposing
        ( attr
        , brick
        )

{-| JSON decoders and encoders.


# Decode functions

@docs decodeValue, decodeString, viewValue, viewString


# Decoders

@docs brick, attr, children

-}

import Bricks.Types exposing (Attr(..), Attrs, Brick, Children(..))
import Json.Decode as Dec exposing (..)


{-| Decode a single brick
-}
brick : Decoder Brick
brick =
    let
        optional : String -> Decoder a -> a -> Decoder a
        optional name dec default =
            let
                convert : Value -> Decoder a
                convert x =
                    case Dec.decodeValue (field name value) x of
                        Ok content ->
                            case Dec.decodeValue dec content of
                                Ok res ->
                                    succeed res

                                Err msg ->
                                    fail msg

                        Err _ ->
                            succeed default
            in
            value |> andThen convert
    in
    map3 Brick
        (field "tag" string)
        (optional "attrs" (list attr) [])
        (optional "children"
            (lazy (\x -> oneOf [ brick, brickText ])
                |> list
                |> Dec.map Children
            )
            (Children [])
        )


{-| Decode a single attribute element.
-}
attr : Decoder Attr
attr =
    let
        convertTail : String -> List Value -> Decoder Attr
        convertTail name tail =
            case tail of
                [] ->
                    succeed (Attr name name)

                x :: [] ->
                    case Dec.decodeValue string x of
                        Ok value ->
                            succeed (Attr name value)

                        Err _ ->
                            fail "not a string"

                _ ->
                    fail "attribute list is too long"

        converter : List Value -> Decoder Attr
        converter value =
            case value of
                [] ->
                    fail "attribute cannot be an empty list of values"

                x :: tail ->
                    case Dec.decodeValue string x of
                        Ok name ->
                            convertTail name tail

                        Err _ ->
                            fail "expect string as first attribute"
    in
    list value |> andThen converter


brickText : Decoder Brick
brickText =
    string |> andThen (\x -> succeed <| Brick "text" [ Value x ] (Children []))
