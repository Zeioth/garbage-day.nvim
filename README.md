# garbage-day.nvim
Garbage collector that stops inactive LSP clients to free RAM

![screenshot_2023-11-07_01-45-44_431834829](https://github.com/Zeioth/garbage-day.nvim/assets/3357792/703d2af6-58cb-4061-a485-41c1c8432696)

<div align="center">
  <a href="https://discord.gg/ymcMaSnq7d" rel="nofollow">
    <img src="https://img.shields.io/discord/1121138836525813760?color=azure&labelColor=6DC2A4&logo=discord&logoColor=black&label=Join the discord server&style=for-the-badge" data-canonical-src="https://img.shields.io/discord/1121138836525813760">
  </a>
</div>

## Why
In many scenarios, unmanaged LSP clients running on background can take several Gb of RAM. So I wrote this LSP garbage collector for [NormalNvim](https://github.com/NormalNvim/NormalNvim) to auto free it. It has no dependencies, so you can use it on any distro.

## How to setup
Add this to lazy

```lua
{
  "zeioth/garbage-day.nvim",
  event = "VeryLazy",
  opts = {
    -- your options here
  }
},
```

We also support changing opts on execution time like `:let g:garbage_day_config['option'] = 'value'`
`

## Available options

| Name | Default | Description |
|--|--|--|
| `grace_period` | `60*15` | Seconds to wait before stopping all LSP clients after neovim loses focus. |
| `excluded_lsp_clients` | `{"null-ls", "jdtls"}` | LSP clients that should never be stopped. Useful for LSP clients that miss behave. |
| `stop_invisible` | `false` | Set it to `true` to enable agressive mode. It stops all LSP clients except the ones used by the visible buffers every time you change to a different buffer, ignoring the grace period. This ensures the minimum RAM consumption. If your CPU is not very powerful, it might take a few seconds to bring back LSP, so keep this option disabled in that case. |
| `notifications` | `false` | Set it to `true` to get a notification every time LSP clients are stopped. |

## FAQ

* `If it doesn't work`: This plugin has been tested with neovim 0.9 and 0.10. If you are in a neovim version superior to nvim 0.10, and it doesn't work, please [open a issue tagging me](https://github.com/Zeioth/garbage-day.nvim/issues) and I will fix it.
* `If still doesn't work`: Set `stop_invisible` to `false` and try again. If that fixed your issue, please report how to reproduce.

## 🌟 Support the project
If you want to help me, please star this repository to increase the visibility of the project.

[![Stargazers over time](https://starchart.cc/Zeioth/garbage-day.nvim.svg)](https://starchart.cc/Zeioth/garbage-day.nvim)

## Where do that cheesy name come from?
* [It comes from the beloved meme](https://knowyourmeme.com/memes/garbage-day)

## Other alternatives
* [lsp-timeout](https://github.com/hinell/lsp-timeout.nvim): Recommended for nvim versions `<=0.8`

## Roadmap
* Once nvim 0.10 is oficially released and we drop 0.9 support, we must replace the [deprecated function](https://neovim.io/doc/user/deprecated.html#vim.lsp.buf_get_clients()) `get_active_clients()` by `get_clients()`.
