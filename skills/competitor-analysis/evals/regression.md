# Regression Evaluation Cases

Edge cases that have historically been easy to get wrong. Each should be
checked whenever the skill's references or SKILL.md are modified.

---

## Eval 1 — Insufficient input

**Input:**
> 帮我做个竞品分析

**Expected behaviour:**
- The only blocking question is which competitor(s) to analyze — that's the sole hard requirement for Mode ①.
- Does NOT also ask for our brand/positioning or a single analysis purpose as preconditions — those are optional context with sensible defaults (standalone competitor profile; full five-dimension coverage), per `SKILL.md`'s Mode ① input rules.

---

## Eval 1b — Competitor given, no "our brand" context

**Input:**
> 帮我分析竞品韶音

**Expected behaviour:**
- Skill does not ask "你自己的品牌/产品是什么？" as a precondition.
- Proceeds directly to a standalone five-dimension profile of 韶音 (asking at most for Quick/Deep or scope clarification if genuinely needed — not for our brand).
- Ends with a one-line offer that providing our brand/positioning would unlock a gap analysis and prioritized action recommendations, rather than fabricating "我方" strategies with no "我方" given.

---

## Eval 1c — Competitor given, purpose not narrowed

**Input:**
> 帮我分析一下竞品飞书，我们是做低代码平台的

**Expected behaviour:**
- Skill does not ask the user to pick one purpose (定位/内容/定价/渠道/差异化) from a list.
- Defaults to full five-dimension coverage since a purpose wasn't specified and the user didn't ask to narrow it.
- Uses "我们是做低代码平台的" as our positioning context to build the comparison/gap analysis, without demanding more detail than was given.

---

## Eval 2 — Auto-discovered competitors not yet confirmed

**Input:**
> 帮我找找我们这个赛道还有哪些竞品，然后做深度分析

**Expected behaviour:**
- Skill searches for candidates, classifies them (direct/substitute/manual workaround/adjacent threat/rule-setter/ecosystem partner), and presents the classification to the user.
- Does NOT proceed straight into Deep five-dimension analysis on all candidates before the user confirms which ones to deep-dive.

---

## Eval 3 — Fewer than 100 review comments

**Input:** User pastes 34 reviews for sentiment analysis.

**Expected behaviour:**
- Skill proceeds but labels the output "小样本" prominently.
- States the raw/deduped/invalid counts.

---

## Eval 4 — Duplicate reviews in the pasted data

**Input:** User pastes 200 lines, but 60 are exact or near-exact duplicates (copy-paste template text).

**Expected behaviour:**
- Skill deduplicates before computing sentiment distribution.
- Reports raw count (200) vs. deduped count (140) vs. any additional invalid exclusions.

---

## Eval 5 — Reviews missing dates and source attribution

**Input:** User pastes review text with no dates, no platform indicated.

**Expected behaviour:**
- Skill proceeds with the analysis but marks Published/Accessed date fields as "未知" where applicable in any evidence entries, rather than guessing a date.
- Does not claim a specific time range ("近30天") that wasn't substantiated.

---

## Eval 6 — Only one negative review found

**Input:** Among 120 reviews, only 1 clearly negative comment exists on a given theme.

**Expected behaviour:**
- That theme is labeled "个案/弱证据" per the evidence-strength rule, not presented as a representative "负面口碑TOP3主题" alongside stronger multi-quote themes.

---

## Eval 7 — Conflicting sources

**Input:** Two sources give different prices for the same competitor product (e.g., official site says ¥299, a review mentions ¥199).

**Expected behaviour:**
- Skill surfaces both figures with their respective sources and dates rather than silently picking one.
- Flags the conflict and suggests it as a "待核实" item, since pricing is a high-risk claim category requiring cross-verification.

---

## Eval 8 — "Not found" mistakenly written as "does not have"

**Input:** Competitor's refund policy page could not be located via search or on the site.

**Expected behaviour:**
- Comparison table cell is marked "未知", not "否".
- Report text says something like "未查到退款政策相关页面" rather than "该竞品没有退款政策".

---

## Eval 9 — Price or sales claims without evidence

**Input:**
> 为什么竞品卖得比我们好？

**Expected behaviour:**
- If no sales data is available, skill outputs "可能驱动购买的公开信号" framing rather than asserting actual sales performance or causes.
- Does not fabricate sales figures or market share numbers.

---

## Eval 10 — First-time report generation

**Input:** No prior `runs/` directory exists.

**Expected behaviour:**
- Output is labeled "首次基线".
- No period-over-period comparison language appears anywhere in the report.

---

## Eval 11 — Same-day repeat run

**Input:** User runs the competitor report twice in one day.

**Expected behaviour:**
- Second run is saved under a new `runs/YYYY-MM-DD-HHmm/` timestamp rather than overwriting the first.

---

## Eval 12 — Last report file is corrupted/unreadable

**Setup:** The most recent `runs/.../report.md` is empty or malformed.

**Expected behaviour:**
- Skill detects it cannot use that run as a baseline, falls back to the next most recent valid run (or treats this as a first-time baseline if none exists), and notes this explicitly in the output rather than failing silently or fabricating a comparison.

---

## Eval 13 — Config scope changed since last report

**Input:** `config.md` now lists a different set of competitors than the last saved report.

**Expected behaviour:**
- Skill detects the scope mismatch and starts a new baseline instead of force-comparing against the old scope.
- States explicitly in the report: "配置范围已变化，本期为新基线".

---

## Eval 14 — Partial source failure in a competitor report run

**Input:** 2 of 5 competitor sources fail to load during this period's run; 3 succeed.

**Expected behaviour:**
- The 3 successful sources are analyzed normally.
- The 2 failed sources are listed under "获取失败的来源" and their prior-period conclusions are not silently carried forward as if reconfirmed.

---

## Eval 15 — All sources fail in a competitor report run

**Input:** Every competitor source is unreachable this period (e.g., network issue).

**Expected behaviour:**
- Output is "本期数据不足" — never "没有变化".
- This run does NOT overwrite the last valid baseline for future comparisons.

---

## Eval 16 — Sentiment category counts don't sum to total

**Setup (internal consistency check):** A draft sentiment report shows positive+neutral+negative percentages/counts that don't add up to the reported total sample size.

**Expected behaviour:**
- Before finalizing, the skill reconciles counts so that categorized totals (including any excluded/invalid bucket) sum to the reported sample size, or clearly explains the discrepancy (e.g., some reviews were multi-labeled or excluded) rather than presenting inconsistent numbers.
