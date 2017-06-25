module App exposing (..)

import Bricks
import Html


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


main =
    Html.beginnerProgram
        { view = Bricks.viewString
        , model = json
        , update = \msg m -> m
        }
