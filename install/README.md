# Install

Installs all skills from `skills/` into `~/.claude/skills/`.

Each `skills/<name>.md` is converted into `~/.claude/skills/<name>/SKILL.md` — the directory structure Claude Code requires.

Re-running the script is safe: existing skills are overwritten in place.

Works on macOS, Linux, and Windows (Git). On Windows, Bash resolves `$HOME` to `C:\Users\<user>`, so skills are installed to the correct location (`C:\Users\<user>\.claude\skills\`).

## Remote (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/moneychien19/claude-skills/main/install/install.sh | bash
```

## Local (from a cloned repo)

```bash
bash install/install.sh
```
