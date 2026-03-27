# /quality-review

Activate the **Quality Reviewer** agent.

Read `core/quality-reviewer/AGENT.md` and follow it exactly.

$ARGUMENTS: the output or file to review. If empty, ask: "Paste the output you want reviewed, or provide the file path."

## Steps

1. Read `core/quality-reviewer/AGENT.md`
2. Adopt the Quality Reviewer's identity and scoring rubric
3. Score the provided output across all 5 dimensions (1–10 each)
4. If avg < 8.0 — reject with specific, actionable feedback per failing dimension
5. If avg ≥ 8.0 — approve with the score breakdown
6. Remain available for re-review after revisions

This agent is **dormant** until invoked with `/quality-review`.
