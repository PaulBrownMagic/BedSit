# ToDo Example

**"Whoah, that's a lot of files!", I know, but only one actually
contains the app: `todo.lgt`** Let me give you the lay of the land.

## Loaders

We have 3 loaders so you can choose what GUI you want to use the app
with:

- `XPCE_loader.lgt` for the XPCE desktop GUI
- `Web_loader.lgt` to launch a server so you can navigate to
  [localhost:8000](http://localhost:8000/) in the web browser of your
  choice
- `Chromium_loader.lgt` to launch the Chromium/Chrome browser in "pretending to
  be a native-desktop app" mode. Obviously this depends on you having
  Chromium or Chrome installed. It searches for executables under
  common names, you can adjust this in `chromium_app.pl`. Note,
  `www_url_open` works with your launching program (`xdg-open`
  typically for linux, `open` for MacOS) and so does not work with the
  path to the chrom(e/ium) executable.

If everything is setup as described in the [main
README](https://github.com/PaulBrownMagic/BedSit) and you have `logtalk`
setup as your executable, then you should be
able to launch with:

```bash
$~: logtalk Chromium_loader.lgt
```

## Web vs XPCE

To run as an **XPCE** app we have `xpce_hooks.pl` and
`xpce_includes.lgt` which give Logtalk an interface to XPCE. Then
`todo_xpce.lgt` hooks into the messages printed by `todo.lgt` to manage
the GUI.

For running as a **Web** app (including as a Chromium app), we have
`web_hooks.lgt` to manage the routes. Then `todo_web.lgt` is the GUI
again, hooking into the same messages printed by `todo.lgt` to manage
it. We're using Websockets so we can easily push to the client. Finally,
the whole `static` directory is just CSS and JS to make this run nicely.

## Persistent Storage

The final file: `todo_storage.pl` is where the situation is persisted
between sessions. In this example I opted for using
[SitCalc](https://github.com/PaulBrownMagic/SitCalc) as the backend, so
this is one of those terms.

## `todo.lgt`

This is the actual app. It's pretty short! Just a few actions that
`todos` is allowed to do and one fluent that holds plus a view to print
your the situation. Much shorter and simpler than the GUIs!
