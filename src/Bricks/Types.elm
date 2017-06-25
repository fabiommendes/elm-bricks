module Bricks.Types exposing (..)

{-| Define all general purpose types for the Bricks module.
-}


{-| Main brick type.
-}
type alias Brick =
    { tag : String
    , attrs : Attrs
    , children : Children
    }


{-| List of attributes
-}
type alias Attrs =
    List Attr


{-| A list of bricks.

Must be defined like this in order to avoid recursion

-}
type Children
    = Children (List Brick)


{-| A single attribute of a brick
-}
type Attr
    = Attr String String
    | Classes (List String)
    | Id (Maybe String)
    | Value String
    | Action ActionType


{-| Represents serialized action.
-}
type ActionType
    = NoOp
