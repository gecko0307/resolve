# Resolve
A tool for D language that installs dependencies from arbitrary git repos/branches locally and points `dub.selections.json` to them. This helps to work on the project and its dependencies simultaneously without pushing.

## Usage
Create a `dependencies.json` file in your Dub project. It should look like this:

```json
{
    "git": {
        "dagon": ["https://github.com/gecko0307/dagon", "master"],
        "dagon:nuklear": ["https://github.com/gecko0307/dagon", "master"],
        "dagon:ftfont": ["https://github.com/gecko0307/dagon", "master"],
        "dlib": ["https://github.com/gecko0307/dlib", "v0.17.0"],
        "bindbc-loader": ["https://github.com/BindBC/bindbc-loader", "v0.2.1"],
        "bindbc-opengl": ["https://github.com/BindBC/bindbc-opengl", "v0.8.0"],
        "bindbc-sdl": ["https://github.com/BindBC/bindbc-sdl", "v0.8.0"],
        "bindbc-freetype": ["https://github.com/BindBC/bindbc-freetype", "v0.5.0"],
        "bindbc-nuklear": ["https://github.com/Timu5/bindbc-nuklear", "v0.3.1"],
        "bindbc-assimp": ["https://github.com/Sobaya007/bindbc-assimp", "v0.0.1-beta1"]
    }
}
```

Then install Resolve and run it:

`dub fetch resolve`

`dub run resolve`

It will create `.resolve` folder, clone the repositories and update `dub.selections.json`. Then you can build your project with Dub as usual.

It is recommended to add `.resolve` folder to `.gitignore`. 

## Limitations
Currently Resolve doesn't traverse dependency tree, you have to include everything to `dependencies.json` manually.
