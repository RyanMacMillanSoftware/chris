# Project Path Resolution

Resolve the canonical project directory for a given `<slug>`. All skills that read or write project files must use this logic instead of hardcoding paths.

## Resolution

Project dir = `~/Code/chris/projects/<slug>/`

This is the only path to use. When vault backing is configured via `scripts/install.sh`, `~/Code/chris/projects/` is a directory-level symlink to `<vault_path>/Projects/`, so all reads and writes transparently land in the Obsidian vault.

## Vault root

Some features (dashboard generation, hub notes) need the vault root path. Read `vault_path` from `~/.chris/config.yml` when needed — but never use it for project directory resolution.
