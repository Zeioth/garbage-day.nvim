# garbage-day.nvim
LSP garbage collector that free RAM memory by stopping LSP clients while you are not using them.

## Requirements
* This plugin has no external dependencies.
* It has been tested with neovim 0.9 and 0.10.
* If a future neovim version changes stuff and the plugin stop working, and for some reason I don't notice, please [open a issue tagging me](https://github.com/Zeioth/garbage-day.nvim/issues) and I will fix it.

## How to use
Add this to lazy

```lua
{
  "zeioth/garbage-day.nvim",
  event = "BufEnter",
  opts = {
    grace_period = (60*15), -- after 15 min, stop clients until resuming.
    excluded_languages = { "java" }, -- ignore languages whose clients miss behave.
  }
},
```

## Why did I make this plugin
I wrote this plugin for [NormalNvim](https://github.com/NormalNvim/NormalNvim), in order to ensure the code remains readable, maintainable, and stable.

## Alternatives
* [lsp-timeout](https://github.com/hinell/lsp-timeout.nvim)

## What's the deal with the cheesy name?
[It comes from the beloved meme](https://knowyourmeme.com/memes/garbage-day)

## Roadmap
* New feature: Stop clients not attached to the buffers in the visible windows → Restore when a loading a new buffer.

This feature could potentially save even more RAM.

