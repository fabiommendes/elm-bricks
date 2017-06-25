# Elm-Bricks

elm-bricks is a library that define "brick" components that behave similarly
as Html elements. Differently than Html objects, bricks can be 
stored in models and serialized/deserialized as JSON. This makes it ideal to
talk to a server that might render HTML fragments in a JSON representation
which is then controlled by Elm's mainloop.

The main goal is to interact seamlessly with the [django-bricks](https://github.com/fabiommendes/django-bricks/) 
library and consume brick elements from a Django server. The serialization 
protocol, however is very simple and can be easily implemented in different
backends.  

## Usage

Basic example (rendering a Brick from Json data):

```elm
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
```


# Instructions

This project is bootstrapped with [Create Elm App](https://github.com/halfzebra/create-elm-app).

Below you will find some information on how to perform basic tasks.  
You can find the most recent version of this guide [here](https://github.com/halfzebra/create-elm-app/blob/master/template/README.md).

## Table of Contents
- [Folder structure](#folder-structure)
- [Available scripts](#available-scripts)
  - [elm-app build](#elm-app-build)
  - [elm-app start](#elm-app-start)
  - [elm-app test](#elm-app-test)

## Available scripts

In the project directory you can run:

### `elm-app build`
Builds the app for production to the `dist` folder.  

The build is minified, and the filenames include the hashes.  
Your app is ready to be deployed!

### `elm-app start`
Runs the app in the development mode.  
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.  
You will also see any lint errors in the console.

### `elm-app test`
Run tests with [node-test-runner](https://github.com/rtfeldman/node-test-runner/tree/master)

You can make test runner watch project files by running:
```sh
elm-app test --watch
```

## Deploying to GitHub Pages

#### Step 1: install [gh-pages](https://github.com/tschaub/gh-pages)
```sh
npm install gh-pages -g
```

#### Step 2: configure `SERVED_PATH` environment variable
Create a `.env` file in the root of your project to specify the `SERVED_PATH` environment variable.

```
SERVED_PATH=./
```

The path must be `./` so the assets are served using relative paths.

#### Step 3: build the project and deploy it to GitHub Pages
```sh
elm-app build
gh-pages -d dist
```
