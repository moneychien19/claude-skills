# Install

Installs all skills from `skills/` into `~/.claude/skills/`.

Each `skills/<name>.md` is converted into `~/.claude/skills/<name>/SKILL.md` — the directory structure Claude Code requires.

If `assets/<name>/` exists, its contents are also copied into `~/.claude/skills/<name>/` alongside `SKILL.md`. This is how skills ship with companion files (rosters, configs, reference data).

Re-running the script is safe: existing skills are overwritten in place. **Note**: companion assets are also overwritten — if a user has edited `~/.claude/skills/<name>/roster.md` directly without syncing back to `assets/<name>/roster.md`, those local edits will be lost on re-install.

Works on macOS, Linux, and Windows (Git). On Windows, Bash resolves `$HOME` to `C:\Users\<user>`, so skills are installed to the correct location (`C:\Users\<user>\.claude\skills\`).

## Remote (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/moneychien19/claude-skills/main/install/install.sh | bash
```

## Local (from a cloned repo)

```bash
bash install/install.sh
```
