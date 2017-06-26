module App exposing (..)

import Bricks
import Html
import Result


json : String
json =
    """
{
    "tag": "div",
    "children": [
        {
            "tag": "h1",
            "children": ["Hello!"]
        },
        {
            "tag": "p",
            "children": ["Hello Bricks!"]
        },
        {
            "tag": "input",
            "attrs": [["value", "Button"], ["type", "submit"]]
        }
    ]
}
"""


view st =
    Html.div []
        [ Bricks.viewString st
        , Html.pre []
            [ Html.text <| Bricks.encode 2 (Bricks.decodeString st |> Result.withDefault (Bricks.text "error"))
            ]
        ]


main =
    Html.beginnerProgram
        { view = view
        , model = json
        , update = \msg m -> m
        }
