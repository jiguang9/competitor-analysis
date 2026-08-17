# Basic Evaluation Cases

Four normal-path scenarios, one per mode. Run manually or use as regression
benchmarks when updating the skill.

---

## Eval 1 — Mode ① Full competitor analysis (Quick)

**Input:**
> 我们是一个做 SaaS 项目管理工具的团队，帮我分析一下竞品 Asana 和 Monday.com，想了解他们和我们的定位差异，用来做产品规划参考。

**Expected behaviour:**
1. Skill triggers Mode ①.
2. Confirms our product/positioning is already given; does not re-ask for it.
3. Classifies Asana and Monday.com (likely "direct competitor") and states the classification before deep-diving — since the user named them directly, may proceed but should still surface the classification.
4. Defaults to Quick depth (no explicit "深入/完整" request, more than... well 2 competitors is ≤3, but no explicit deep request — should still default Quick unless asked).
5. Builds a unified five-dimension comparison table for both competitors using the same rows.
6. Any cell without solid evidence is marked "未知" — never silently left blank or guessed as "否".
7. Output includes: data coverage/missing-evidence section, comparison table, evidence-based SWOT, 3 actionable strategies each with rationale/priority/next verification step/success metric.

**Must NOT:**
- Assert specific sales, revenue, or market-share numbers without a cited source.
- Give both competitors different sets of comparison questions.

---

## Eval 2 — Mode ② Sentiment analysis

**Input:** User pastes 150 lines of e-commerce reviews for a competitor skincare brand and asks: "帮我分析一下这些竞品评论，看看用户在抱怨什么。"

**Expected behaviour:**
1. Skill triggers Mode ②.
2. Reports raw sample count, deduped count, and invalid/excluded count — the three numbers should be consistent with each other.
3. Sentiment distribution is labeled as either exact percentages (if every review was individually categorized) or "估算分布" if not — never presented as precise without that determination being made explicit.
4. Top-3 positive and top-3 negative themes each come with at least 2 anonymized quotes; any theme backed by only 1 quote is labeled "个案/弱证据".
5. Includes a sample-bias disclaimer (reviewers are self-selecting, negative sentiment often overrepresented).
6. Ends with 3 differentiation opportunities and a note on what additional data would help.

**Must NOT:**
- Report percentages with false precision (e.g., "23.47%") for an eyeballed/estimated distribution.
- Include real usernames or contact info in quoted excerpts.

---

## Eval 3 — Mode ③ Content reverse-engineering

**Input:** User pastes 8 competitor blog post titles + opening paragraphs and asks: "分析一下这些竞品爆款内容的结构，帮我们找几个可以写的角度。"

**Expected behaviour:**
1. Skill triggers Mode ③.
2. Separates content facts (titles, structure) from performance claims — does not invent engagement numbers that weren't provided.
3. Identifies recurring structural patterns (hook style, opening type, argument structure).
4. Produces a topic-gap list, each item labeled with evidence strength (强/中/弱).
5. Produces 3 "same structure, different angle" content frameworks — structural templates, not finished copy that mimics the competitor's wording.
6. Notes at least one content pattern that should NOT be imitated, with a reason.

**Must NOT:**
- Reproduce competitor sentences or case studies verbatim as "inspiration."
- Claim a piece "went viral" or cite specific view/like counts not provided by the user.

---

## Eval 4 — Mode ④ Second weekly report run (valid comparison)

**Setup:** `competitor-analysis-reports/config.md` exists with a confirmed competitor list and tracked dimensions. A prior valid run exists at `runs/2026-08-03-0900/` with the same scope.

**Input:**
> 生成本周的竞品周报

**Expected behaviour:**
1. Skill triggers Mode ④, reads `config.md` and locates the scope-compatible prior run as baseline.
2. Confirms competitor list/dimensions/market scope still match; if they do, proceeds with a normal comparison (not a new baseline).
3. Collects this period's public info and records each source's status (success / fetch-failed / login-or-paywall / not-found).
4. Filters out noise (page-structure-only diffs, duplicate info) before doing strategic analysis.
5. Output includes: monitoring health, top-3 competitor moves with intent, changes vs. last period, 2 impacts, 2 recommended actions, 跟/缓/不跟 verdict, items to verify, failed sources.
6. This run becomes the new baseline only if at least partially valid.

**Must NOT:**
- Output "本周无变化" if some or all sources failed.
- Silently start a new baseline when the scope hasn't changed.
