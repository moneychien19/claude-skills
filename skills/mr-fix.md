# /fix-mr — Fix Merge Request Reviews Skill

## Purpose

This skill is used **after a Merge Request has been reviewed**.

Claude Code must:

1. Read **all MR review comments** (including unresolved & pending ones)
2. Classify them into **Tier A / B / C**
3. Produce a **clear fix plan**
4. Propose a **commit strategy with expected commit messages**
5. Provide **reply drafts** for reviewers

This skill focuses on **review-driven changes only**.  
Do not re-review the MR from scratch.

## Execution Mode

This skill operates in **planning-only mode**.

Claude Code must:

- ❌ NOT modify any source code
- ❌ NOT apply patches
- ❌ NOT create commits
- ❌ NOT stage or push changes

The output of this skill is **planning artifacts only**, including:
- tier classification
- fix strategy
- **proposed commit messages**
- reviewer reply drafts

Actual code changes are **explicitly out of scope** for `/fix-mr`.

## Input Format

The user may provide **one of the following**:

- **GitLab Merge Request URL**
- **GitLab Merge Request IID**
- **Nothing at all**

If no explicit input is provided, you **must infer the MR** by comparing:
- the current checked-out branch
- against its configured target branch (via GitLab metadata)

⚠️ You must **not ask the user for clarification**.  
⚠️ You must **determine which MR to operate on by yourself**.

You are responsible for identifying the correct MR and its context.

## Step 0 — Gather MR Context  
**(GitLab only, using MCP tools)**

### Objective

> **Understand what this MR is changing, why it exists, and where reviewers are concerned — without loading the full MR diff.**

This step defines the **source of truth** for all later steps.

### ⚠️ Hard Constraints

- ❌ Do **NOT** load the complete MR diff
- ❌ Do **NOT** scroll or fetch all file diffs
- ❌ Do **NOT** read code unless required later by a Tier A issue
- ✅ Use metadata, summaries, comment context, and file references
- ✅ Inspect specific hunks only if strictly necessary

### Step 0.1 Determine the Current Project (origin is the only reference)

1. Use `git rev-parse --show-toplevel` to confirm you are in a git repo
2. Use `git remote get-url origin` to get the origin
3. Treat the origin as the GitLab project this MR belongs to
4. If only an MR IID is provided, assume it belongs to this origin project

### Step 0.2 — Resolve the Target MR

Determine the MR using this priority order:

1. **MR URL provided**
   - Extract project + IID
   - Verify it matches `origin`
   - Abort only on clear mismatch

2. **MR IID provided**
   - Query MR from the `origin` project

3. **Nothing provided**
   - Infer MR by:
     - identifying current branch
     - finding an open MR whose source branch matches
   - If multiple MRs match:
     - prefer MR targeting default branch
     - otherwise choose most recently updated MR

⚠️ Do not ask the user to disambiguate.

### Step 0.3 — Fetch MR Metadata (NO DIFF)

Using MCP GitLab tools, retrieve:

- title
- description
- source branch
- target branch
- author
- reviewers / assignees
- labels
- draft / ready status
- pipeline status (if available)

❌ Do **NOT** fetch:
- full diff
- per-file diff
- inline hunks

### Step 0.4 — Infer MR Intent & Risk

From title + description:

- identify primary goal
- classify change type:
  - refactor
  - behavior change
  - infra / migration
  - bug fix
  - test-only
- note any stated constraints, risks, or follow-ups

If unclear:
- assume **higher risk**
- default toward conservative interpretation

### Step 0.5 — Collect Review Feedback (Source of Truth)

Retrieve **all review feedback**, including:

- discussion threads
- inline comments
- unresolved comments
- pending comments (if visible)

For each item, record:

- comment ID
- author
- timestamp
- file + line (if any)
- comment text
- resolved / unresolved
- thread context

⚠️ Unresolved and pending comments **must be included**.  
⚠️ No comment may be silently ignored.

### Step 0.6 — Build Mental Model (No Fixes Yet)

Before suggesting fixes:

- correlate comments with MR intent
- identify repeated themes
- note areas under architectural scrutiny

❌ Do NOT classify tiers yet  
❌ Do NOT suggest fixes yet  

## Step 1 — Tier Classification

Classify **every review item** into exactly one tier.

### Tier A — Must Fix / Must Reply First

Includes any comment that:

- affects architecture, layering, boundaries, ownership
- questions correctness, safety, performance, concurrency
- blocks approval or asks a direct question
- introduces operational or migration risk

✅ When unsure, default to Tier A.

### Tier B — Recommended Improvements

Includes comments that:

- improve readability or maintainability
- suggest alternative implementations without changing behavior
- suggest non-blocking test improvements
- are “should consider” rather than “must fix”

### Tier C — Nit / Minor

Includes comments that:

- start with “Nit:”
- formatting, naming preference, ordering
- typos, docs wording
- trivial logging or style tweaks

### Classification

For each item, specify:

- Tier (A / B / C)
- Item type:
  - `CODE_CHANGE`
  - `REPLY_ONLY`
  - `CODE_CHANGE + REPLY`
- One-sentence justification

## Step 2 — Commit Strategy Planning

### Rules

- **Tier A**
  - Each major concern gets its **own commit**
  - Group only if they share the same root cause
- **Tier B / C**
  - Batch small fixes into: `chore: fix mr reviews`
  - Create a separate commit only if the improvement is cohesive and non-trivial

## Step 3 — Fix Plan (Conceptual Only)

For each planned commit, describe:

- intent of the change
- reasoning behind the fix
- scope and affected areas (high level)
- risks or trade-offs
- which review items this commit addresses

⚠️ Do NOT:
- write code
- suggest exact implementations
- include diffs or snippets

This step exists solely to justify the **commit boundary and message**.

## Step 4 — Expected Commit Messages (Primary Output)

This is the **primary output** of `/fix-mr`.

For each commit, provide:

- commit message (required)
- short explanation of why this commit exists
- which Tier A / B / C items it covers

Commit messages must be:

- realistic
- reviewer-friendly
- suitable for direct use without modification

## Command Contract

When the user runs:

```text
/fix-mr <MR_URL | MR_IID | nothing>
```

Claude Code must output:

- full tiered review list
- commit plan with proposed commit messages
- reviewer reply drafts

Claude Code must NOT:

- modify code
- suggest patches
- apply fixes
- create commits

This command ends at decision-making, not execution.
