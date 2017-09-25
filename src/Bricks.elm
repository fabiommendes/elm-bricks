module Bricks
    exposing
        ( Attr
        , Brick
        , attr
        , attrs
        , brick
        , children
        , class
        , decodeString
        , decodeValue
        , encode
        , getText
        , tag
        , text
        , view
        , viewString
        , viewValue
        )

{-| The main module for the Bricks library. This module has functions to build
and modify bricks and a few functions to convert to/from JSON.


# Types

@docs Brick, Attr


# Constructors

Bricks provides many constructors with an API similar to Html. The generic
constructor is called "brick" instead of "node".

@docs brick, text


## Attributes

@docs attr, class


# Getters

@docs tag, attrs, children, getText


# View functions

Bricks provide a few functions that render brick objects, and their respective
Json and string respresentations

@docs view, viewValue, viewString


# Standard encoders/decoders

The main decoding interface is done through the decodeString and decodeValue
functions. If you need more options or if you need to use the decoders
directly, please check the documentation for the Bricks.Json module.

This module define a few convenience functions that helps decoding JSON data
to Brick values.

Example

    json = "{...some valid JSON data here...}"

    brick =
        case decodeString json of
            Ok x -> x
            Err _ -> brick 'div' [] []

@docs decodeValue, decodeString, encode

-}

import Bricks.Json as Json
import Bricks.Types as Types exposing (..)
import Html exposing (Html, div, pre)
import Html.Attributes as HAttrs
import Json.Decode as Dec exposing (Value)
import Json.Encode as Enc


--------------------------------------------------------------------------------
-- TYPE ALIASES
--------------------------------------------------------------------------------


{-| Main Brick type.

Bricks are stored internally as a Brick type. It defines a tag, some
attributes and a children. Bricks are similar to Html.Html objects and
can be easily converted using the view function. They are however a
little more restricted and can be included in models.

-}
type alias Brick =
    Types.Brick


{-| Attribute of a Bricks element.

The list of attributes can be accessed using the `attrs brick` function.

-}
type alias Attr =
    Types.Attr


type alias Children =
    Types.Children



--------------------------------------------------------------------------------
-- CONSTRUCTORS
--------------------------------------------------------------------------------


{-| Creates a brick from a list of attrs and children.

Do not create bricks manually unless you really known what you are doing.

-}
brick : String -> List (Attrs -> Attrs) -> List Brick -> Brick
brick tag attrs children =
    let
        attrs =
            List.foldl (\f lst -> f lst) defaultArgs []
    in
    Brick tag attrs (Children children)


{-| Creates a Brick object that represents a text node
-}
text : String -> Brick
text st =
    Brick "text" [ Value st ] (Children [])


{-| Initial list of empty attributes
-}
defaultArgs : Attrs
defaultArgs =
    [ Classes [] ]



--------------------------------------------------------------------------------
-- ATTRIBUTES
--------------------------------------------------------------------------------


{-| Adds an arbitrary string attribute
-}
attr : String -> String -> Attrs -> Attrs
attr name value attrs =
    attrs ++ [ Attr name value ]


{-| Add a class to the list of classes in the brick
-}
class : String -> Attrs -> Attrs
class cls attrs =
    attrs
        |> List.map
            (\x ->
                case x of
                    Classes lst ->
                        Classes (cls :: lst)

                    _ ->
                        x
            )



--------------------------------------------------------------------------------
-- GETTERS
--------------------------------------------------------------------------------


{-| Return a list of attributes
-}
attrs : Brick -> Attrs
attrs brick =
    brick.attrs


{-| Return a list of child bricks
-}
children : Brick -> List Brick
children brick =
    case brick.children of
        Children lst ->
            lst


{-| Return the Brick's tag value
-}
tag : Brick -> String
tag brick =
    brick.tag


{-| We assume that brick was created with text "foo" and extract
the corresponding string data.

Return empty string if no text data is found.

-}
getText : Brick -> String
getText brick =
    case List.head brick.attrs of
        Just x ->
            case x of
                Value st ->
                    st

                _ ->
                    ""

        Nothing ->
            ""



--------------------------------------------------------------------------------
-- VIEW FUNCTIONS
--------------------------------------------------------------------------------


{-| Convert brick to Html.Html element
-}
view : Brick -> Html msg
view brick =
    let
        toHtmlAttr attr =
            case attr of
                Classes lst ->
                    HAttrs.classList (List.map (\x -> ( x, True )) lst)

                Id id ->
                    HAttrs.id id

                Attr name value ->
                    HAttrs.attribute name value

                Action action ->
                    case action of
                        NoOp ->
                            HAttrs.attribute "data-no-op" "undefined"

                Value x ->
                    HAttrs.attribute "data-value" x

        tag =
            Html.node brick.tag

        attrs_ =
            List.map toHtmlAttr (attrs brick)

        children_ =
            List.map view (children brick)
    in
    case brick.tag of
        "text" ->
            Html.text <| getText brick

        _ ->
            tag attrs_ children_


{-| Decode a JSON String directly as an Html element.
-}
viewString : String -> Html msg
viewString str =
    case decodeString str of
        Ok brick ->
            view brick

        Err err ->
            decodeErr err


{-| Decode a Json Value object directly as an Html element.
-}
viewValue : Value -> Html msg
viewValue value =
    case decodeValue value of
        Ok brick ->
            view brick

        Err err ->
            decodeErr err


decodeErr : String -> Html msg
decodeErr err =
    div [ HAttrs.class "error" ] [ pre [] [ Html.text err ] ]



--------------------------------------------------------------------------------
-- OTHERS
--------------------------------------------------------------------------------
--- DECODERS ---


{-| Decode a Json Value object as a brick result
-}
decodeValue : Value -> Result String Brick
decodeValue value =
    Dec.decodeValue Json.brick value


{-| Decode a Json String object as a brick result
-}
decodeString : String -> Result String Brick
decodeString value =
    Dec.decodeString Json.brick value


{-| Encode brick element as a Json string
-}
encode : Int -> Brick -> String
encode n brick =
    Enc.encode n (Json.brickEncoder brick)
