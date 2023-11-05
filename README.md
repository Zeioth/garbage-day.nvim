# garbage-day.nvim
Garbage collector that stops inactive LSP clients to free RAM. 

![screenshot_2023-11-05_22-15-30_096966913](https://github.com/Zeioth/garbage-day.nvim/assets/3357792/449858f2-13a1-44d3-96ab-96e1f8df1432)

## Why
In many scenarios, unmanaged LSP clients running on background can take severl Gb of RAM. So I wrote this LSP garbage collector for [NormalNvim](https://github.com/NormalNvim/NormalNvim). It has no dependencies, so use it as you want.

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
| `stop_invisible` | `false` | When `true`, every time you enter a buffer, all LSP clients except for the ones inside a window in the current tab will be temporary stopped. Enabling this feature will free a considerable amount of RAM when working with multiple filetypes. But this comes at the cost of higher CPU consumption, as the LSP client will start anew every time you enter a buffer with a different filetype than any of the ones in the windows of the current tab. Note that null-ls won't be stopped by this specific feature, as it is not compatible. |
| `notifications` | `false` | Once you check the this plugin works correctly, is a good idea to keep this option `false`. |

## FAQ

* `If it doesn't work`: This plugin has been tested with neovim 0.9 and 0.10. If you are in a neovim version superior to nvim 0.10, and it doesn't work, please [open a issue tagging me](https://github.com/Zeioth/garbage-day.nvim/issues) and I will fix it.
* `If still doesn't work`: Set `stop_invisible` to `false` and try again. If that fixed your issue, please report how to reproduce.

## Where do that cheesy name come from?
[It comes from the beloved meme](https://knowyourmeme.com/memes/garbage-day)

## Other alternatives
* [lsp-timeout](https://github.com/hinell/lsp-timeout.nvim): Recommended for nvim versions `<=0.8`
