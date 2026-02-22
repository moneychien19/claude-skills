# Install

These scripts install all skills from `skills/` into `~/.claude/skills/`.

Each `skills/<name>.md` is converted into `~/.claude/skills/<name>/SKILL.md` — the directory structure Claude Code requires.

Re-running the script is safe: existing skills are overwritten in place.

## macOS / Linux

```bash
bash install/install.sh
```

Or via `curl` (replace `main` with a tag/commit as needed):

```bash
curl -fsSL https://raw.githubusercontent.com/moneychien19/claude-skills/main/install/install.sh | bash
```

## Windows (PowerShell)

```powershell
.\install\install.ps1
```

Or via `iwr`:

```powershell
iwr -useb https://raw.githubusercontent.com/moneychien19/claude-skills/main/install/install.ps1 | iex
```
