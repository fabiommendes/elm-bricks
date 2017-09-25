# Elm-Bricks

elm-bricks is a library that define "brick" components that behave similarly
to Html elements. Differently than Html objects, bricks can be 
stored in models and serialized/deserialized as JSON. This makes it ideal to
talk to a server that might render HTML fragments serialized in JSON.

The main goal is to interact seamlessly with the [django-bricks](https://github.com/fabiommendes/django-bricks/) 
library and consume brick elements from a Django server. The serialization 
protocol, however is very simple and can be easily implemented in different
backends. 


## Usage

This package defines a `Bricks.Brick` type that represent a brick element. It can be 
rendered to Html using the `Bricks.view` function and recovered from a JSON
serialization using `Bricks.decodeString`. This very simple example shows 
how to process a JSON string and render the corresponding Brick object:

```elm
module App exposing (..)

import Bricks
import Html


--- THE MODEL
type alias Model =
    { brickElement : Brick }


--- INPUT DATA
data =
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
            "attrs": [["class", "text"]],
            "children": ["Hello Bricks!"]
        }
    ]
}
"""


--- MAIN
main =
    Html.beginnerProgram
        { view = \m -> Bricks.view m.brickElement
        , model = { brickElement = Bricks.decodeString data }
        , update = \msg m -> m
        }
```