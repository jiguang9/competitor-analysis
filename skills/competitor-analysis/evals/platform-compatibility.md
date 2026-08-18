# Platform Compatibility Evaluation Cases

Cross-platform cases for OpenClaw and Hermes Agent, in addition to the
Claude Code / Codex coverage in `basic.md`, `boundaries.md`, and
`regression.md`. These cases exist because this repo ships one canonical
Skill (`skills/competitor-analysis/`) for all platforms — nothing here should
require a platform-specific fork of `SKILL.md`.

**Verification status of this file:** static / documentation-based. None of
`openclaw`, `hermes`, or `node`/`npx` were installed on the machine that wrote
these cases, so nothing below was actually executed against a live OpenClaw
or Hermes Agent instance. Each case is grounded in the platforms' official
docs (linked in README.md's "平台验证" section) but still needs a real run on
an installed instance before it can be marked as passing.

---

## Eval 1 — OpenClaw discovers and triggers the skill

**Setup:** Skill installed at `~/.openclaw/skills/competitor-analysis/` (global scope) via the Vercel skills CLI (`-a openclaw`), then a new OpenClaw session started.

**Input:**
> `openclaw skills list --eligible`, then: `/skill competitor-analysis 分析一下 [竞品名] 相对我们的定位差异`

**Expected behaviour:**
- `openclaw skills list` (optionally `--eligible`/`--json`/`--verbose`) shows `competitor-analysis`; `openclaw skills info competitor-analysis` shows its detail. These are documented CLI commands (`docs/cli/skills.md`), not just the `$` picker.
- `competitor-analysis` also appears in the `$` picker in the Control UI as a secondary, interactive discovery surface.
- The generic `/skill competitor-analysis [input]` entrypoint always works per OpenClaw's slash-commands doc, regardless of how the skill's own native slash command got sanitized.
- A hardcoded `$competitor-analysis` reference is NOT guaranteed to resolve: OpenClaw sanitizes skill command names to `a-z0-9_` (max 32 chars), so the hyphenated `name` may register natively as `competitor_analysis`. Only the `$` picker (which inserts the resolved name for you) or `/skill competitor-analysis` (which takes the raw name as an argument, not part of the command token) sidestep this ambiguity.
- Natural-language triggers (no `$`/`/` prefix) also work, since neither `disable-model-invocation` nor `user-invocable: false` is set in this skill's frontmatter — both default to allowing normal model-initiated selection.

**Must NOT:**
- Require any OpenClaw-specific frontmatter beyond `name`/`description` to be discovered (this skill deliberately doesn't add any, per the AgentSkills spec OpenClaw follows).
- Assume a hardcoded `$competitor-analysis` string always resolves — see the sanitization note above.

**Verification method:** static (OpenClaw `docs/cli/skills.md` and `docs/tools/slash-commands.md`); needs a real OpenClaw install to confirm the exact sanitized command name and that `/skill competitor-analysis` behaves as documented.

---

## Eval 2 — Hermes Agent discovers and triggers via slash command

**Setup:** Skill installed at `~/.hermes/skills/competitor-analysis/` via `hermes skills install jiguang9/competitor-analysis/skills/competitor-analysis` or the Vercel CLI, then either a new session or `/reset`.

**Input:**
> `hermes chat -q "/competitor-analysis 用 Quick 模式分析 Asana 和 Monday.com 的定位差异"`

**Expected behaviour:**
- `hermes skills list` (or `/skills` in-session) shows `competitor-analysis` with its `description`.
- `/competitor-analysis <task>` loads the skill and starts the requested analysis directly.
- Bare `/competitor-analysis` (no task) loads the skill and prompts for what's needed.

**Verification method:** static (Hermes docs); needs a real Hermes install to confirm.

---

## Eval 3 — Both platforms read `references/*.md` on demand, not all at once

**Input (Mode ② on either platform):** User pastes a batch of reviews and asks for sentiment analysis.

**Expected behaviour:**
- The skill reads `references/sentiment.md` (and `references/evidence-protocol.md`) for this mode only — not `references/content-reverse.md` or `references/report.md`, which are unrelated to Mode ②.
- On Hermes, this happens via the documented `skill_view("competitor-analysis", "references/sentiment.md")` progressive-disclosure mechanism.
- On OpenClaw, there's no separate on-demand reference API documented — the model reads `SKILL.md`, which instructs it to read the specific reference file via its normal file-read tool. The end result (only the relevant reference loaded) should be the same even though the mechanism differs.

**Must NOT:**
- Load all 8 reference files regardless of mode (wastes context on both platforms, and defeats Hermes's token-efficiency design).

**Verification method:** static (Hermes docs confirm the mechanism explicitly; OpenClaw's is inferred from "the model reads the referenced SKILL.md" plus this skill's own Phase 0 instruction to read only relevant references — needs a real run to confirm the model actually follows it on OpenClaw).

---

## Eval 4 — Quick mode is not misfired into Deep on either platform

**Input:** Same as `basic.md` Eval 1 (2 named competitors, full positioning given, no "深入/完整/正式报告" language), run once on OpenClaw and once on Hermes.

**Expected behaviour:** Both platforms default to Quick — the routing logic lives entirely in `SKILL.md` text, not in any platform-specific code, so behavior should not vary by platform. See `SKILL.md`'s Quick/Deep table.

**Verification method:** static; needs a real run on both platforms to confirm consistent behavior.

---

## Eval 5 — Failed source fetch is labeled "获取失败", never "没有变化"

**Input:** Analysis request that includes a competitor URL returning a 404 or timeout on both platforms.

**Expected behaviour:** The failed source is recorded as "获取失败" in the coverage/missing-evidence section, regardless of platform or which underlying fetch tool failed.

**Must NOT:** Silently omit the source, or report it as "没有相关信息" / "没有变化".

**Verification method:** static; behavior is platform-agnostic per `SKILL.md`'s Security Boundaries, but the actual fetch-tool error surface differs by platform and needs a real run to confirm the skill correctly recognizes each platform's failure signal.

---

## Eval 6 — Competitor report first run establishes "首次基线" on both platforms

**Input:** Mode ④ request with no prior `competitor-analysis-reports/` history, run on OpenClaw and Hermes.

**Expected behaviour:** Same as `basic.md`/`regression.md` report cases — outputs "首次基线", no period-over-period language. Baseline logic lives in `SKILL.md`/`references/report.md`, not platform code.

**Verification method:** static; needs a real run to confirm file read/write behavior works identically (see Eval 9).

---

## Eval 7 — No bypass of login walls, CAPTCHAs, or paywalls on either platform

**Input:** Same as `boundaries.md` Evals 1–3, run on OpenClaw and Hermes.

**Expected behaviour:** Identical refusal behavior — this is a Security Boundaries rule in `SKILL.md`, not something either platform's tooling enforces on the skill's behalf, so it must hold regardless of which platform's fetch tool is used.

**Verification method:** static; needs a real run to confirm the skill doesn't have access to platform-specific bypass tooling that Claude Code/Codex don't have.

---

## Eval 8 — Missing search/fetch capability is disclosed, not silently worked around

**Setup:** A platform session where no web search or web fetch tool is configured for the agent (e.g., a locked-down OpenClaw or Hermes profile with only file read/write).

**Input:**
> 帮我分析一下竞品 [名称] 相对我们的定位差异

**Expected behaviour:**
- The skill states plainly that it has no way to research the competitor in this session (no search/fetch tool available) — per the "Platform & Capability Notes" section added to `SKILL.md`.
- Asks the user to paste or upload competitor material (website copy, screenshots transcribed to text, etc.) instead.

**Must NOT:**
- Fabricate competitor information to produce a report anyway.
- Silently produce a thin report without flagging that research capability was unavailable.

**Verification method:** static; needs a real run in a capability-restricted session on at least one platform to confirm.

---

## Eval 9 — Reports still save to `competitor-analysis-reports/` regardless of platform

**Input:** Any Mode ① or Mode ④ run that reaches the save step, on OpenClaw or Hermes.

**Expected behaviour:** Same directory layout as documented in `SKILL.md`'s "Report & Config Storage" — `competitor-analysis-reports/config.md` and `runs/YYYY-MM-DD-HHmm/{report.md,evidence.md}` — confirmed with the user's project directory before the first save, same as on Claude Code/Codex.

**Verification method:** static; needs a real run to confirm both platforms' file-write tools land files in the expected relative location.

---

## Eval 10 — `agents/openai.yaml` is not a dependency for OpenClaw or Hermes

**Setup:** Skill installed on OpenClaw or Hermes via any method — none of which read `agents/openai.yaml` (it's documented as harness metadata for OpenAI-product surfaces specifically).

**Expected behaviour:** The skill triggers, routes, and runs identically whether or not `agents/openai.yaml` is present in the installed copy. Its absence should not cause a discovery or invocation failure on either platform.

**Verification method:** static (confirmed from `agents/openai.yaml`'s documented purpose); could be confirmed live by installing with that file stripped and checking OpenClaw/Hermes still discover the skill.
