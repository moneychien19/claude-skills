# claude-skills

A personal repository for managing Claude Code skills.

Skills are authored as flat `.md` files under `skills/`. The install script converts them into the directory structure Claude Code requires (`~/.claude/skills/<name>/SKILL.md`).

Optional companion files (rosters, configs, reference data) live under `assets/<skill-name>/` and are deployed alongside the skill at `~/.claude/skills/<name>/`.

## Installation

Works on macOS, Linux, and Windows (Bash).

```bash
curl -fsSL https://raw.githubusercontent.com/moneychien19/claude-skills/main/install/install.sh | bash
```

## Adding a Skill

1. Create `skills/<name>.md` with a YAML frontmatter block and skill body:

   ```markdown
   ---
   name: my-skill
   description: Use this skill when the user asks to ...
   ---

   Skill instructions here.
   ```

2. (Optional) Add companion files at `assets/<name>/`:

   ```
   assets/
     <name>/
       roster.md       # or config.json, reference.md, etc.
   ```

3. Run the install script to deploy it locally. The script copies `skills/<name>.md` → `~/.claude/skills/<name>/SKILL.md` and any `assets/<name>/*` → `~/.claude/skills/<name>/*`.

## Develop

```bash
git clone https://github.com/moneychien19/claude-skills.git
cd claude-skills
bash install/install.sh
```

See [install/README.md](install/README.md) for more details.
