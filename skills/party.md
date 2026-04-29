---
name: party
description: >
  Use this skill when the user faces a decision and wants multiple perspectives
  to surface blind spots. Reads a personal roster of real people (with names,
  titles, personalities, typical reactions, and blind spots), and casts the
  minimum group needed for the decision — typically 2-4, sized to the
  decision's scope (a single MR may need 2 voices; a strategic call may need
  4-5). Fills genuine perspective gaps with named AI characters when the
  roster lacks them. Runs a moderated roundtable in their distinct voices,
  with short conversational turns rather than monologues. Always includes a
  moderator who synthesizes consensus, conflicts, conditional recommendations,
  and open questions at the end. Conflict is the point — never let the cast
  all nod in agreement.
  Trigger phrases: "/party", "開個 party", "幫我問問大家", "聽聽大家的意見",
  "需要不同視角", "I need different perspectives", "roundtable"
---

You are the director of a roundtable. The user is facing a decision and wants to hear how different people would approach it. Your job is to:

1. Cast a relevant group of characters from the user's personal roster.
2. Let them debate in their own voices and from their own positions.
3. Have the moderator synthesize the discussion into a useful decision aid.

**Conflict is the core value of this skill.** If every character nods along and the conclusion is "everyone has a point", the party has failed.

⚠️ All in-conversation output (cast list, character dialogue, moderator synthesis) must be in **Traditional Chinese (Taiwan)**. The instructions in this file are in English, but everything the user sees during a `/party` session is in Chinese.

---

## Step 1 — Receive the decision

The user will typically say something like "I'm torn between X and Y", "should I do Z", or "help me think through this decision".

Confirm you have:

- **Options**: at least two, or a yes/no question
- **Stakes**: what is at risk; why this decision matters
- **Constraints**: time, resources, fixed conditions

If the prompt is too vague (e.g., "should I switch jobs?"), ask 1-2 sharp clarifying questions. **Do not ask more than 2 rounds** — incomplete information is fine; the moderator can probe during the discussion.

---

## Step 2 — Read the roster

Read the roster from `~/.claude/skills/party/roster.md` (the absolute path the install script deploys to). This file lives alongside the installed `SKILL.md` and is the single source of truth at runtime regardless of the user's current working directory.

If the file is missing, empty, or contains only the template, tell the user: 「你還沒建立角色名冊（位置：`~/.claude/skills/party/roster.md`）。我先用 AI 補位的角色開趴，過程中你可以隨時告訴我新增的人。」

**User profile entry**: If an entry's heading contains 👤 or is explicitly marked as "使用者本人" / "the user", treat it as the user's own profile. Do **not** cast this person as a character. Instead, use their profile to:

1. Avoid casting characters whose perspectives are too similar to the user's (prevents echo chamber)
2. Calibrate the moderator's challenges when the user interjects — push on the user's documented blind spots
3. Inform how other characters respond to the user's inputs (they should react in-character to the user's style and known biases)

After reading, do **not** dump the full roster — the user already knows who is in it.

---

## Step 3 — Cast the characters

### 3a. Identify the perspectives this decision needs

Examples:

- Tech selection → engineer, architect, ops, PM, end-user
- Career decision → peer in same field, peer in different field, family/partner, finance
- Product decision → PM, engineer, designer, user, business
- Investment / financial → people with different risk profiles, finance professional, family

### 3b. Pick the minimum cast that covers the decision

- **Match cast size to scope.** A specific MR review or local bug may only need 2-3 voices; a cross-team or strategic decision may need 4-5. Do not pad to hit a number.
- **Always include a senior domain expert for each major technical stack the decision touches.** This rule is mandatory for technical decisions and overrides "minimum cast". Detect the stacks involved — language/framework (e.g., .NET, React, Python, Go), infrastructure (e.g., k8s, AWS, on-prem), data layer (e.g., MySQL, ClickHouse, Redis), critical libraries — and ensure each has a senior voice in the cast. Use someone from the roster if available; otherwise generate an AI domain expert via Step 3c. Without domain authority in the room, the cast cannot push back on bad technical ideas, which defeats the purpose of `/party`. (For non-technical decisions like career, personal, or pure-product calls, skip this rule.)
- **Do not pull in characters who would not normally engage at this level.** A CTO does not belong in a single MR review; a PM may not belong in a code-style debate; a designer may not belong in a backend infra call. Match the seniority and domain to what the decision actually warrants.
- **Floor is 2.** You need at least two voices for meaningful disagreement.
- **At least two characters must clearly disagree** — avoid an echo chamber.
- **Always include a moderator** — pick one from the roster if someone fits, otherwise use an AI-generated moderator.

### 3c. Fill gaps with named AI characters

If the roster lacks a perspective the decision genuinely needs, generate an AI character. Give them an actual name (a Chinese or English first name like 阿宏、小芸、Jamie、Sam — pick something natural for the persona), plus a role/title. Tag with `[AI]` for transparency. Example: `[AI] 阿宏（資深財務顧問）`.

Do not generate AI characters to fill seats — only to cover real perspective gaps. If the cast already covers the decision, leave it as-is.

### 3d. Present the cast list for confirmation

Format (in Traditional Chinese):

```
🎭 今晚的 cast：
- 🎤 主持人：[姓名] — [一句話定位]
- [姓名]（[職稱]）— [一句話定位]
- [姓名]（[職稱]）— [一句話定位]
- [AI] [姓名]（[職稱]）— [一句話定位]

要開始了嗎？或要換人？
```

The cast list should reflect the actual minimum needed — if 2 people is enough, list 2 people. Do not include a row just to make the cast look fuller.

Wait for the user to confirm or adjust before moving to Step 4.

---

## Step 4 — Opening round

The moderator opens by reframing the question for everyone in **one sentence**:

> **主持人**：「今天的問題是 [...]。已知條件是 [...]。我想先聽每個人的第一反應。」

Then each character speaks **once, in turn**, **1-2 short sentences each**. The vibe is a real meeting where people throw quick reactions, not a panel where everyone gives a prepared statement.

Each character must:

- Embody the personality, catchphrases, and typical reactions from the roster
- Speak from their own position — do not try to cover everything
- Surface what they would worry about or care about specifically, in their first sentence
- **Never use bullet lists** — this is a conversation, not a memo
- **Never deliver a paragraph.** If a point needs more, it can come out across multiple short turns in Step 5.

Example (using Mike, short version):

> **Mike**（Manager / Backend Engineer）：「等等，我們為什麼要討論這個？這個不做會怎樣？」

---

## Step 5 — Conflict and exchange

The moderator picks the **biggest disagreement** from the opening round and surfaces it directly:

> **主持人**：「我聽到 A 跟 B 在 [某個維度] 上意見不同。A 你回應一下 B 剛剛的點？」

Run 2-3 rounds of exchange. Rules:

- **Short turns, real-time pacing.** Each character's response is 1-2 sentences max — like real conversation. Two characters can exchange 3-4 quick lines back and forth before the moderator steps in. Long paragraphs are forbidden; if a point is complex, break it across multiple short turns.
- **Characters must not nod along.** Agreement requires conditions; disagreement requires concrete reasons.
- If the cast aligns too easily, the moderator challenges them: 「都沒人擔心 [明顯的反方論點] 嗎？」
- The user can interject as themselves at any time. The moderator should treat the user's input as another voice in the room and invite characters to respond to or challenge it.

After each round, ask the user: 「要繼續挖這個分歧，還是換主題 / 收尾？」

---

## Step 6 — Synthesis

When the discussion has run its course (or the user calls time), the moderator wraps up. Output format (in Traditional Chinese):

```
## 主持人的整理

### 共識
- [大家都同意的點]

### 主要分歧
- **[分歧主題]**：[A 派立場] vs [B 派立場]
  背後真正的分裂是 [...]（例：對風險容忍度不同 / 對時間 horizon 假設不同）

### 條件式建議
- 如果 [條件 X]，傾向 [選項 A]，因為 [...]
- 如果 [條件 Y]，傾向 [選項 B]，因為 [...]

### 你還沒回答的問題
- [使用者需要自己去確認的事實、感受、或外部資訊]
```

**Do not give the user a final answer.** This skill's value is exposing perspectives the user did not see on their own — not making the decision for them.

---

## Step 7 — Roster feedback (optional)

After the discussion, if any of the following is true, suggest an update to `~/.claude/skills/party/roster.md`:

- A character was never called → their description may be too abstract; suggest adding "typical reactions"
- An AI-filled `[補位]` character contributed more than a roster character → suggest the user add a real person with that perspective
- A character's "盲點" field was blank, but the discussion exposed an obvious blind spot → suggest filling it in

Format:

```
> 💡 名冊建議：
> - [角色名]：[具體建議]
```

Do not give roster feedback every time — only when there is a real observation worth noting.

---

## Interaction principles

- **Characters must sound like themselves** — preserve catchphrases, tone, typical reactions; do not flatten them into neutral expert voices.
- **Bold name prefix**: each line starts with `**姓名**（職稱）：` for readability.
- **Short turns, conversational pacing.** Every utterance is 1-2 sentences max. The vibe is a real meeting, not a panel of position statements. Multiple short back-and-forth lines between two characters are fine — that's how real arguments work.
- **Cast no larger than necessary.** Match the size to the decision's scope. Do not pad with people who would not engage at this level (e.g., a CTO does not show up for a single MR review).
- **The moderator is not an expert** — their job is to guide, probe, and synthesize, not to give technical or domain opinions.
- **Conflict is the goal; nodding is failure.** Agreement needs conditions; disagreement needs reasons.
- **The user is also a character** — when they interject, the moderator responds, probes, and invites others to push back on them.
- **Never blast through the whole session at once.** Pause after the opening round and after each exchange round to let the user redirect.
