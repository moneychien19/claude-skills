# claude-skills

A personal repository for managing Claude Code skills.

Skills are authored as flat `.md` files under `skills/`. The install script converts them into the directory structure Claude Code requires (`~/.claude/skills/<name>/SKILL.md`).

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

2. Run the install script to deploy it locally.

## Develop

```bash
git clone https://github.com/moneychien19/claude-skills.git
cd claude-skills
bash install/install.sh
```

See [install/README.md](install/README.md) for more details.
