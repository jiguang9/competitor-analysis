# Basic Evaluation Cases

Four normal-path scenarios, one per mode. Run manually or use as regression
benchmarks when updating the skill.

---

## Eval 1 — Mode ① Full competitor analysis (Quick)

**Input:**
> 我们是"云雀待办"，一个面向 10 人以下小团队的轻量项目管理 SaaS 工具，核心卖点是"5 分钟上手，不需要培训"。帮我分析一下竞品 Asana 和 Monday.com，想了解他们和我们的定位差异，用来做产品规划参考。

**Expected behaviour:**
1. Skill triggers Mode ①.
2. Our brand, product, positioning, competitor names, and analysis purpose are all already present in the input — does not re-ask for any of them.
3. Classifies Asana and Monday.com (likely "direct competitor") and states the classification before deep-diving — since the user named them directly, may proceed but should still surface the classification.
4. Defaults to Quick depth: the input contains no explicit "深入/完整/正式报告" request, so Deep must NOT be triggered even though there are only 2 competitors (≤3 only makes Deep *allowed*, never automatic — see SKILL.md's Quick/Deep table).
5. Builds a unified five-dimension comparison table for both competitors using the same rows.
6. Any cell without solid evidence is marked "未知" — never silently left blank or guessed as "否".
7. Output includes: data coverage/missing-evidence section, comparison table, evidence-based SWOT, 3 actionable strategies each with rationale/priority/next verification step/success metric.

**Must NOT:**
- Assert specific sales, revenue, or market-share numbers without a cited source.
- Give both competitors different sets of comparison questions.

---

## Eval 2 — Mode ② Sentiment analysis

**Input:** User pastes the fixed 24-line fixture below (a fictional competitor skincare brand, "竞品优肤") and asks: "帮我分析一下这些竞品评论，看看用户在抱怨什么。" This fixture is intentionally small and fixed so dedup/counting/anonymization can be checked deterministically — real usage should still recommend ≥100 reviews per `references/sentiment.md`.

```text
1. 面膜用着还行，就是有点贵。
2. 价格太贵了，同品质的国货更划算。
3. 客服态度很好，问了很多问题都耐心解答。
4. 面膜用着还行，就是有点贵。
5. 宣传效果和实际差距有点大，没有说的那么神。
6. 包装很精美，送人有面子。
7. 过敏了，脸红了两天，客服说是正常排毒反应。
8. 价格太贵了，同品质的国货更划算。
9. 😍😍😍😍😍
10. 还可以，一般般。
11. 回购第三次了，效果很稳定。
12. 客服态度很好，问了很多问题都耐心解答。
13. 宝贝很好，值得拥有，戳这里领券再减30元→[链接]
14. 用了一周没什么感觉，可能要再长期用用看。
15. 价格确实不便宜，但效果对得起这个价格。
16. 过敏了，脸红了两天，客服说是正常排毒反应。
17. 物流很快，第二天就到了。
18. 完全无效，闭口一点没改善，不会回购了。
19. 价格偏高，学生党买起来有点吃力。
20. 真的有帮助解决了我的敏感肌问题，比之前用的产品好太多了。
21. 机器人客服转了很久才转人工，体验很差。
22. 手机号13800001234，可以加我低价代购，比官方便宜。
23. 成分挺干净的，没有酒精和香精，敏感肌能用。
24. 退货流程太麻烦了，客服一直踢皮球。
```

**Ground truth for this fixture** (the skill should arrive at these exact numbers):
- Raw = 24. Duplicates removed = 4 (#4 dups #1, #8 dups #2, #12 dups #3, #16 dups #7). Other invalid = 3 (#9 pure emoji; #13 promotional/coupon-link solicitation; #22 resale solicitation containing a phone number). Valid = 17. Check: 4 + 3 + 17 = 24.
- Sentiment on the 17 valid reviews: positive = 7 (#3, #6, #11, #15, #17, #20, #23), negative = 7 (#2, #5, #7, #18, #19, #21, #24), neutral = 3 (#1, #10, #14). Check: 7 + 7 + 3 = 17.

**Expected behaviour:**
1. Skill triggers Mode ②.
2. Reports raw / duplicates-removed / other-invalid / valid counts matching the ground truth above, and explains *why* #9, #13, #22 were excluded (not just that they were).
3. Because valid = 17 (< 100), the report opens with a "小样本" flag per `references/sentiment.md` — reliability is explicitly limited.
4. Sentiment distribution matches the ground truth exactly (all 17 valid reviews were individually classified, so this is an **exact** count, not "估算分布" — the skill should say so).
5. Negative themes: price (#2, #19) and service/refund (#21, #24) and efficacy gap (#5, #18) each have ≥2 quotes and can be presented as solid themes; the allergy report (#7) has only 1 supporting quote and, if surfaced, must be labeled "个案/弱证据" rather than folded into a themed count.
6. Positive themes: repeat-purchase/efficacy (#11, #20) has 2 quotes; other positive mentions (packaging #6, ingredients #23, logistics #17, value #15, service #3) are single-quote each — any of these presented as a "top" theme must be labeled "个案/弱证据".
7. #22's phone number is never reproduced in the report, even redacted-looking — it's excluded from analysis entirely, not quoted.
8. Includes a sample-bias disclaimer (reviewers are self-selecting, negative sentiment often overrepresented).
9. Ends with 3 differentiation opportunities and a note on what additional data would help (starting with "collect more reviews to get past 小样本").

**Must NOT:**
- Report percentages with false precision for a distribution that was actually estimated, and inversely must not hedge with "估算" language for this fixture since every valid review was in fact individually classified.
- Include the phone number, or any other contact info, in quoted excerpts.
- Count #9, #13, or #22 toward the valid sample or sentiment distribution.

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
