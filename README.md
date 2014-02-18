# searchmatch.vim

## Easy search highlight pinning in Vim with :match

So if you're a frequent user of Vim's `hlsearch` feature, you may find yourself
wishing that you could highlight multiple searches.  Well Vim has support for
this in its `:match` command, but doesn't make that particularly easy to use.

This plugin aims to put the full power of Vim's `:match` feature at the user's
fingertips in the easiest way possible: as an extension of the existing search
feature that you know and love.

You just search for something, and then pin that search with one of the
`SearchMatchN` commands or key mappings.

![Example Screenshot](../screenshots/self.png "Example Screenshot")

The screenshot above shows `/match` pinned to match1, `/search` pinned to
match2, and `/highlight` pinned to match3.  The colorscheme is a modified
[lucius][0].

## Basic Usage

The plugin defines 4 basic commands:
- `Searchmatch1`      -- sets the current search as first match
- `Searchmatch2`      -- sets the current search as second match
- `Searchmatch3`      -- sets the current search as third match
- `SearchmatchToggle` -- hides/shows any matches set by the above

Unless you've already defined a mapping for `<leader>/`, then the default
normal mappings for these commands are:
- `<leader>/1` -- calls Searchmatch1
- `<leader>/2` -- calls Searchmatch2
- `<leader>/3` -- calls Searchmatch3
- `<leader>/-` -- calls SearchmatchToggle

Additionally the user can run any of the stock match commands (`:match`,
`:2match`, and `:3match`) to turn off any of the three highlights individually.

## Operator Usage

In addition to the explicit search pinning use pattern, `searchmatch` can also
function as an operator.  A normal and visual mode mapping is provided at
`<Plug>SearchmatchOp`.  By default this is mapped to `<leader>/` with
convenience mappings in `<leader>//` and `<leader>/*`.

The `<leader>/` binding works like any other operator, so `<leader>/<Movement>`
highlights the text specified by movement (the visual mode mapping simply
highlights the selected range).

The highlight is set to `1match`, and any pre-existing `searchmatch` highlight
in `1match` is pushed down to `2match` (correspondingly `2match` -> `3match`).

The specified text is escaped so that any regex special characters are matched
literally.

The specified text has any leading/trailing white space stripped.

If the specified text spans multiple lines, it is split and each line treated
as an alternative when constructing the `match` regex.  In this case the
whitespace striping applies to each line individually.

The `<leader>//` and `<leader>/*` convenience mappings highlight the current
line and word respectively.

## Highlighting

The `searchmatch` plugin makes use of `Match1`, `Match2`, and `Match3`
highlighting groups for `:match`, `:2match`, and `:3match` respectively.

Since most colorscheme don't define these highlighting groups, default links
are setup to the standard `ErrorMsg`, `DiffDelete`, and `DiffAdd` groups.

The user will almost certainly want to define these highlight groups in their
`.vimrc` and/or patch their favorite colorscheme(s) (see for example the
author's patched [lucius.vim][0]).

## Stop the default mappings

If the default mapping are causing your grief, then you can set `let
g:searchmatch_nomap = 1` in your `.vimrc` to prevent searchmatch from defining
any.

## About `3match`

So the third match is used by other plugins, such as `matchparen`.  But the
notion of this plugin is to give the user as much direct control over as much
match highlighting as possible.

So the `SearchMatch3` command will first disable the `matchparen` plugin if it
is loaded.  Correspondingly, the `SearchMatchToggle` command will reload/unload
the `matchparen` plugin as appropriate when a `3match` highlight is defined.

## Installation

Typical [pathogen][1] installation:

    cd ~/.vim/bundle
    git clone https://github.com/jcorbin/vim-searchmatch

Otherwise just copy `plugin/searchmatch.vim` into `~/.vim/plugin/searchmatch.vim`.

## TODO

- can do better with the default highlight definitions?
- other usage patterns?
- fix glitch when calling `NoMatchParen` in `SearchMatch3`

## License

MIT License. Copyright (c) 2014 Joshua T Corbin.

[0]: https://github.com/jcorbin/home/blob/master/.vim/bundle/lucius/colors/lucius.vim
[1]: https://github.com/tpope/vim-pathogen
