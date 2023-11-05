# garbage-day.nvim
Garbage collector that stops inactive LSP clients to free RAM. 

![screenshot_2023-11-05_23-22-27_341640170](https://github.com/Zeioth/garbage-day.nvim/assets/3357792/76c2042e-39e2-4a94-b7a4-251bd41f2e04)

## Why
In many scenarios, unmanaged LSP clients running on background can take several Gb of RAM. So I wrote this LSP garbage collector for [NormalNvim](https://github.com/NormalNvim/NormalNvim) to auto free it. It has no dependencies, so use it as you want.

## How to setup
Add this to lazy

```lua
{
  "zeioth/garbage-day.nvim",
  event = "BufEnter",
  opts = {
    -- your options here
  }
},
```

## Available options

| Name | Default | Description |
|--|--|--|
| `grace_period` | `60*15` | Seconds to wait before stopping all LSP clients after neovim loses focus. |
| `excluded_languages` | `{"java", "markdown"}` | Languages whose LSP clients will never be stopped. Useful for LSP clients that miss behave. |
| `stop_invisible` | `false` | When `true`, stop all LSP clients except the ones used by the visible buffers. This happen every time you change to a different buffer. This ensures the minimum RAM consumption. |

## FAQ

* `If it doesn't work`: This plugin has been tested with neovim 0.9 and 0.10. If you are in a neovim version superior to nvim 0.10, and it doesn't work, please [open a issue tagging me](https://github.com/Zeioth/garbage-day.nvim/issues) and I will fix it.
* `If still doesn't work`: Set `stop_invisible` to `false` and try again. If that fixed your issue, please report how to reproduce.

## Where do that cheesy name come from?
[It comes from the beloved meme](https://knowyourmeme.com/memes/garbage-day)

## Other alternatives
* [lsp-timeout](https://github.com/hinell/lsp-timeout.nvim): Recommended for nvim versions `<=0.8`
