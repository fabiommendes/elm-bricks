module Bricks.Json
    exposing
        ( attr
        , attrEncoder
        , brick
        , brickEncoder
        )

{-| JSON decoders and encoders. Use this to compose with other more
complicated JSON pipelines.


# Decoders

@docs brick, attr


# Encoders

@docs brickEncoder, attrEncoder


# JSON Format

Bricks are encoded with the following JSON format

    {
        "tag": tag name (string, required),
        "attrs": array of attributes (optional, see bellow),
        "children": array of bricks (optional)
    }

Each attribute must be encoded as an array with a few special options:

**Regular attributes**

    ["attr-name", "attr-value"] (both are strings)

**Id**

    "id-name"

-}

import Bricks.Types exposing (..)
import Json.Decode as Dec exposing (..)
import Json.Encode as Enc


--- DECODERS ---


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
        converter : List Value -> Decoder Attr
        converter value =
            case value of
                [] ->
                    fail "attribute cannot be an empty list of values"

                -- Extract first element of the list of values, which must
                -- be a string
                x :: tail ->
                    case toStr x of
                        Ok name ->
                            case name of
                                "id" ->
                                    convertId tail

                                "classList" ->
                                    convertClassList tail

                                "valueAttr" ->
                                    convertValue tail

                                "actionNoOp" ->
                                    convertAction name tail

                                _ ->
                                    convertItem name tail

                        Err _ ->
                            fail "expect string as first attribute"

        -- Extract first value of list, which must be a string
        convertItem : String -> List Value -> Decoder Attr
        convertItem name tail =
            case tail of
                [] ->
                    succeed (Attr name name)

                x :: [] ->
                    case toStr x of
                        Ok value ->
                            succeed (Attr name value)

                        Err _ ->
                            fail "not a string"

                _ ->
                    fail "attribute list is too long"

        -- Convert to Id attr
        convertId : List Value -> Decoder Attr
        convertId lst =
            extractSingle lst string (\x -> Id x)

        -- Convert to Classes attr
        convertClassList : List Value -> Decoder Attr
        convertClassList lst =
            case Dec.decodeValue (list string) (Enc.list lst) of
                Ok data ->
                    succeed (Classes data)

                Err err ->
                    fail err

        -- Convert to Value attr
        convertValue : List Value -> Decoder Attr
        convertValue lst =
            extractSingle lst string (\x -> Value x)

        -- Convert to Action attr
        convertAction : String -> List Value -> Decoder Attr
        convertAction name v =
            succeed (Action NoOp)

        -- Utilities
        extractSingle : List Value -> Decoder a -> (a -> b) -> Decoder b
        extractSingle lst dec func =
            case lst of
                x :: [] ->
                    case Dec.decodeValue dec x of
                        Ok x ->
                            succeed (func x)

                        Err err ->
                            fail "argument of invalid type"

                _ ->
                    fail "expect exactly 2 arguments"
    in
    list value |> andThen converter


brickText : Decoder Brick
brickText =
    string |> andThen (\x -> succeed <| Brick "text" [ Value x ] (Children []))



--- ENCODERS ---


type alias Items =
    List ( String, Enc.Value )


{-| Encode a brick object as a Json value
-}
brickEncoder : Brick -> Enc.Value
brickEncoder brick =
    let
        attrs =
            List.map attrEncoder brick.attrs

        children =
            case brick.children of
                Children lst ->
                    List.map brickEncoder lst

        tag =
            Enc.string brick.tag

        add : String -> List Enc.Value -> Items -> Items
        add name lst obj =
            case lst of
                [] ->
                    obj

                x ->
                    obj ++ [ ( name, Enc.list x ) ]
    in
    if isText brick then
        Enc.string
            (case brick.attrs of
                x :: [] ->
                    case x of
                        Value data ->
                            data

                        _ ->
                            ""

                _ ->
                    ""
            )
    else
        Enc.object
            ([ ( "tag", tag ) ]
                |> add "attrs" attrs
                |> add "children" children
            )


{-| Encode a brick attribute as a Json value
-}
attrEncoder : Attr -> Enc.Value
attrEncoder attr =
    let
        list =
            Enc.list

        str =
            Enc.string
    in
    case attr of
        Attr name value ->
            list [ str name, str value ]

        Classes lst ->
            list [ str "classList", list (List.map str lst) ]

        Id id ->
            list [ str "id", str id ]

        Value data ->
            list [ str "valueAttr", str data ]

        Action action ->
            case action of
                NoOp ->
                    list [ str "actionNoOp", str "" ]



--- UTILITIES ---


toStr : Dec.Value -> Result String String
toStr st =
    Dec.decodeValue string st


isText : Brick -> Bool
isText { attrs } =
    let
        isValue x =
            case x of
                Value _ ->
                    True

                _ ->
                    False
    in
    case attrs of
        [] ->
            False

        x :: _ ->
            isValue x
