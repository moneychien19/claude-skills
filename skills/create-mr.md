---
name: create-mr
description: "Create a Bridgewell GitLab Merge Request end-to-end — discover branch context, fill the repo's MR template (whatever sections it defines), surface a dry run for human confirmation, then post via the GitLab MCP. Trigger when the user says 開 MR, create an MR, send PR, or finishes a git push and asks for a merge request. Do NOT use for replying to MR feedback or merging — those are separate skills."
---

# Create MR

## Why this skill exists

Creating an MR by hand is six-plus tool calls every time, and the recurring traps (wrong target branch, wrong squash setting, missing template sections, leaking `appsettings.json` overrides into the diff, mistyped project path) reliably bite. This skill encodes the playbook so each new MR follows the same shape and the human only has to confirm the dry run.

## Pre-conditions

- Branch is already pushed to the GitLab remote. This skill does **not** push. If the working tree is dirty or the branch is unpushed, stop and tell the user.
- The repo lives on `gitlab.local.bridgewell.com`. For repos on other hosts, use a different skill.

## Phase 1 — Discover context (run in parallel)

Issue all four in one batch:

1. `git config --get remote.origin.url` → strip the `https://gitlab.local.bridgewell.com/` prefix and `.git` suffix to get the `<group>/<repo>` path. Use this verbatim as `project_id`. Do not guess the path.
2. `git branch --show-current` → `source_branch`.
3. `git log --oneline <candidate_target>..HEAD` for each plausible target (`release/auth`, `release/<x>`, `develop`, `master`). The candidate with the **smallest non-empty diff** is the real fork point and therefore the correct target. Do **not** default to `develop` blindly — check memory and recent commit themes first (auth-track work targets `release/auth`).
4. Glob `.gitlab/merge_request_templates/*.md` and read whichever template matches the branch prefix (typically `feature.md`; `deploy.md` for `deploy/*`, `hotfix.md` for `hotfix/*`).

Also load the deferred GitLab MCP tools via ToolSearch:

```
select:mcp__plugin_bw-devkit_gitlab__create_merge_request,mcp__plugin_bw-devkit_gitlab__get_users
```

## Phase 2 — Decide settings

| Setting | Rule |
|---|---|
| `target_branch` | From Phase 1 step 3. Auth/login/permission/user-graph work → `release/auth`. |
| `squash` | Read the template from Phase 1 first — if it spells out a squash rule (e.g. "tick Squash when source branch is feature"), follow it. Otherwise fall back to: `feature/*` → `true`; `hotfix/*` / `deploy/*` → `false`. |
| `remove_source_branch` | `true` for `feature/*`. |
| `title` | Use the main commit subject (the `feat:` / `fix:` one). Keep `type: subject` format, ≤70 chars. |
| `assignee_ids` | Ask the user. Resolve via `mcp__plugin_bw-devkit_gitlab__get_users`. |
| `reviewer_ids` | Ask the user, or default to none. |

## Phase 3 — Fill the template (don't rewrite it)

GitLab MR templates live at `.gitlab/merge_request_templates/<name>.md`. Each repo decides its own structure, so **this skill must not assume section names**. Treat the template body you read in Phase 1 as the contract and walk it top-to-bottom:

1. **Top-level checklist items** (`* [ ]` lines that appear before any `##` heading) — tick only the ones you can honestly tick from work that's actually been done. Leave the rest unticked for the human.
2. **Each `##` section** — fill the body using the heading text plus any inline `<!-- comment -->` hints. Do **not**:
   - Rename a section
   - Drop a section the template has
   - Add a section the template doesn't have
   - Insert filler when you have nothing to say — write `n/a` and move on
3. **Content sourcing (infer from heading semantics, not exact section names)**:
   - Heading contains `issue` / `slack` / `link` → branch name + recent commit messages + conversation context. Ask the user if any link is missing.
   - Heading contains `description` / `summary` → one or two sentences on *why*. Don't recap the diff (the diff is the *what*).
   - Heading contains `驗證` / `檢查` / `test` / `verify` / `上線` / "how to check" → for API/SQL changes, include the DB setup SQL (respect FK order, generated columns, unique constraints; verify schema with the MySQL MCP if unsure) + the query to run + an expected-result table.
   - Heading contains `post-merge` / `上線後` / "after merge" → a punch list of follow-ups (issue update, slack notify, monitoring).
4. **Language** — match the language the template body already uses. Bridgewell repos commonly mix English scaffolding with Chinese body content; preserve that mix per repo.

**Multi-template selection**: if the repo has several templates (e.g. `feature.md`, `deploy.md`, `hotfix.md`), pick the one matching the branch prefix (`feature/*` → `feature.md`, `deploy/*` → `deploy.md`). Fall back to `feature.md` or `default.md` if no prefix match.

## Phase 4 — Dry run

**Always show the dry run first.** Render:

- A small fixed-width table with `Title`, `Source → Target`, `Squash`, `Remove source`, `Assignee`, `Reviewer`.
- The full description as a fenced markdown block, exactly as it would be posted.

End with: `要我送出嗎？` (or the English equivalent if the conversation is in English).

Iterate on user feedback (trim sections, swap reviewer, change target) before posting. Do **not** call `create_merge_request` until the user explicitly confirms.

## Phase 5 — Create

Call `mcp__plugin_bw-devkit_gitlab__create_merge_request` with the confirmed fields. Use the **exact** project path from Phase 1.

Report back:
- MR IID + web URL
- Initial `merge_status` (`checking` is normal — tell the user the pipeline is still running)
- Punch list of remaining manual items (integration test run, slack notify, post-merge issue update)

## Common pitfalls

- **Wrong project path** — `bwdsp/controlpanelapi` is NOT `bwdsp/dsp_backend/controlpanelapi`. Always derive from `remote.origin.url`.
- **Wrong target branch** — defaulting to `develop` for an auth-track branch produces a 100-commit diff. Check memory + branch fork point.
- **Leaked dev overrides in commits** — if `git status` shows `appsettings.json` / `.csproj` modified in the working tree, do not push them. (Should already be enforced before push, but flag the user if seen.)
- **Squash with hotfix** — silently breaks the merge graph. Honour the template rule.
- **Dry run skipped** — never. Even one-line MRs go through dry run.

## Tools used

- `Bash` — git inspection
- `Read` + `Glob` — find and read the MR template
- `Grep` — recover issue numbers from commit messages if needed
- `ToolSearch` — load the deferred GitLab MCP tools
- `mcp__plugin_bw-devkit_gitlab__get_users`
- `mcp__plugin_bw-devkit_gitlab__create_merge_request`
- `mcp__plugin_bw-devkit_mysql__*_execute_sql` — only when schema lookup is needed for the verification SQL
