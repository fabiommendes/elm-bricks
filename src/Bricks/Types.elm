module Bricks.Types exposing (..)

{-| Define all general purpose types for the Bricks module.

You generally should not access the types defined in this module directly and
should prefer the constructor functions defined in the Bricks main module.


# Types

@docs Brick, Attrs, Children, Attr, ActionType

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
