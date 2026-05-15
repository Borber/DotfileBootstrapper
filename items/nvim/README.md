# nvim

This item manages Neovim by cloning or updating:

```text
https://github.com/borber/config-nvim.git
```

The target is:

```text
~/.config/nvim
```

Dependencies derived from the upstream README:

- Required: Neovim 0.12+, `git`, `tree-sitter` CLI.
- Recommended optional: `rg`, `fd`, `cmake` for Telescope / fzf-native.
- Feature optional: `just`, `bun`, `npm`, `cargo` for Overseer task discovery.
- Windows optional: `sqlite-dll` via Scoop for bookmarks.

The item does not vendor the config repository into this framework. It keeps the config source external and updates the target clone with `git pull --ff-only`.

