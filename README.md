# garbage-day.nvim
Garbage collector that stops inactive LSP clients to free RAM

![screenshot_2023-11-08_08-12-12_851558101](https://github.com/Zeioth/garbage-day.nvim/assets/3357792/e4dbd49e-5470-4d1a-939b-1b55d9b2d97c)

<div align="center">
  <a href="https://discord.gg/ymcMaSnq7d" rel="nofollow">
    <img src="https://img.shields.io/discord/1121138836525813760?color=azure&labelColor=6DC2A4&logo=discord&logoColor=black&label=Join the discord server&style=for-the-badge" data-canonical-src="https://img.shields.io/discord/1121138836525813760">
  </a>
</div>

## Why
In many scenarios, unmanaged LSP clients running on background can take several Gb of RAM. So I wrote this LSP garbage collector for [NormalNvim](https://github.com/NormalNvim/NormalNvim) to auto free it. But you can use it on any distro.

## How to setup
Add this to lazy

```lua
{
  "zeioth/garbage-day.nvim",
  dependencies = "neovim/nvim-lspconfig",
  event = "VeryLazy",
  opts = {
    -- your options here
  }
},
```

We also support changing opts on execution time like `:let g:garbage_day_config['option']='value'`
`

## Available options

| Name | Default | Description |
|--|--|--|
| `aggressive_mode` | `false` | Set it to `true` to stop all lsp clients except the current buffer, every time you enter a buffer. `aggressive_mode` ignores `grace_period`, and it only triggers when entering a buffer with a differen filetype than the current buffer. Ensures the maximum RAM save. |
| `excluded_lsp_clients` | `{"jdtls"}` | LSP clients that should never be stopped. Useful for LSP clients that miss behave. |
| `grace_period` | `60*15` | Seconds to wait before stopping all LSP clients after neovim loses focus. |


## Advanced options
You don't need to touch these options. But you can tweak them in case some particular LSP client don't start/stop correctly on your machine.

| Name | Default | Description |
|--|--|--|
| `notifications` | `false` | Set it to `true` to get a notification every time LSP garbage collection triggers. |
| `retries` | `3` | Times to try to start a LSP client before giving up. |
| `timeout` | `100` | Milliseconds that will take for `retries` to complete. Example: by default we try 3 retries for 100ms. |

IMPORTANT: If you change the default values, make sure the value of `grace_period` is always bigger than `timeout`/1000. This ensures you are leaving enough time between `stop_lsp()`/`start_lsp()`, so they don't overlap.

## FAQ

* `If it doesn't work`: This plugin has been tested with neovim 0.9 and 0.10. If you are in a neovim version superior to nvim 0.10, and it doesn't work, please [open a issue tagging me](https://github.com/Zeioth/garbage-day.nvim/issues) and I will fix it.
* `Can I manually trigger garbage collection?` Yes, you can do it like
```lua
require("garbage-day.utils").stop_lsp()  -- stop all lsp clients.
require("garbage-day.utils").start_lsp() -- start lsp clients for the current buffer.
```
  
## 🌟 Support the project
If you want to help me, please star this repository to increase the visibility of the project.

[![Stargazers over time](https://starchart.cc/Zeioth/garbage-day.nvim.svg)](https://starchart.cc/Zeioth/garbage-day.nvim)

## Where do that cheesy name come from?
* [It comes from the beloved meme](https://knowyourmeme.com/memes/garbage-day)

## Other alternatives
* [lsp-timeout](https://github.com/hinell/lsp-timeout.nvim): Recommended for nvim versions `<=0.8`

## Roadmap
* Once nvim 0.10 is oficially released and we drop 0.9 support, we must replace the [deprecated function](https://neovim.io/doc/user/deprecated.html#vim.lsp.buf_get_clients()) `get_active_clients()` by `get_clients()`.
