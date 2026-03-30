# Project Path Resolution

Resolve the canonical project directory for a given `<slug>`. All skills that read or write project files must use this logic instead of hardcoding paths.

## Resolution steps

1. **Read config.** Check if `~/.chris/config.yml` exists. If it does, extract `vault_path` (may be absent or empty).

2. **Vault path check.** If `vault_path` is set and the directory `<vault_path>/Projects/<slug>/` exists:
   → Project dir = `<vault_path>/Projects/<slug>/`

3. **Fallback.** Otherwise:
   → Project dir = `~/Code/chris/projects/<slug>/`

## Migration prompt

When a skill accesses a project directory and **all** of these conditions are true:

- `vault_path` is configured in `~/.chris/config.yml`
- The project directory is at `~/Code/chris/projects/<slug>/` (not in the vault)
- The vault directory `<vault_path>/Projects/<slug>/` does **not** exist
- The local directory is **not** already a symlink

Then prompt the user:

```
📂 Vault backing is configured but '<slug>' is stored locally.
   Move to vault? (y/n)
```

- **y** → Move `~/Code/chris/projects/<slug>/` to `<vault_path>/Projects/<slug>/`. Create a symlink at the old location pointing to the new location.
- **n** → Continue using the local path. Do not prompt again this session.

This migration is per-project and on-demand. Never auto-migrate without user confirmation.
