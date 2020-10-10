
# btrpstr (minimalistic LaTeX+TikZ poster class)

The `btrpstr` class was created as a simple support for efficiently creating
the #betterposter-style posters in LaTeX. See https://osf.io/ef53g/ for Mike
Morrison's non-TeX templates.

This repository contains 2 very rough templates, `posterh` (the "original"
horizontal betterposter) and `posterv` (the "vertical" format of the same,
better compatible with the way of postering at the conferences).

Prebuilt PDFs can be seen in [build/](build/).

### How-To

Take the poster template, compile with double `lualatex` (or switch to the
traditional font system and compile with double `pdflatex`), modify for your
needs, enjoy.

### Reference

This tries to very minimalistically mimic the behavior of `baposter` template
that gives a straightforward way to organize poster contents in "boxes" that
all belong to "columns", which makes the poster look seriously organized.

This class defines the following:

- `poster` environment that converts the current page to a poster (optionally
  it modifies the font sizes, turns off page numbering, sets up geometry if
  asked, and starts a `tikzpicture` environment. You can draw normal TikZ boxes
  and paths inside. Notably, `baposter` uses fullpage scaling to achieve "large
  fonts", we just scale fonts. If you need fullpage scaling (e.g. transparently
  scale up tikz arrows etc), use `pgfpages` to resize a smaller poster.

- `posterbox` and `headerbox` environments to create simple boxes with text
  nicely aligned in _columns_

- `\newpostercol` and `\splitpostercol` to define new columns, and, optionally,
  split them into multiple sub-columns

- several other helpers, mainly some stuff for simplified background drawing.

For now, see the comments in `posterv.tex` for a more precise reference. Some
study of the Tikz manual is higly recommended (reading that manual is highly
recommended in any case).

### Future

Everything is likely going to change a lot (see the comments with TODOs in the
class file).

### License

This repository and all work in it is relased to public domain.
