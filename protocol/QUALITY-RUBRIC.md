# Quality scoring rubric

The Quality Reviewer applies this rubric to every agent output. Scores below 8.0 trigger automatic rejection with specific feedback. The agent must revise and resubmit.

---

## The five dimensions

### 1. Completeness (25%)
Does the output fully address everything in the agent's brief?

| Score | Criteria |
|-------|----------|
| 9–10 | Every item in the brief addressed, nothing missing, no shortcuts |
| 7–8 | Mostly complete — minor items unaddressed or thin |
| 5–6 | Key deliverables missing or seriously underdeveloped |
| 3–4 | Significant portions of the brief not attempted |
| 1–2 | Output barely relates to the brief |

### 2. Correctness (30%)
Is the content technically accurate, bug-free, and factually sound?

| Score | Criteria |
|-------|----------|
| 9–10 | No errors; logic, syntax, and facts are correct |
| 7–8 | Minor errors that don't affect functionality |
| 5–6 | Notable errors — would cause bugs or mislead |
| 3–4 | Major errors — output would fail in use |
| 1–2 | Fundamentally incorrect |

### 3. Consistency (20%)
Does the output align with other agents' outputs and the mission constraints?

| Score | Criteria |
|-------|----------|
| 9–10 | Perfectly consistent with all other approved outputs |
| 7–8 | Minor inconsistencies — easily reconciled |
| 5–6 | Notable conflicts with another agent's output |
| 3–4 | Contradicts core decisions from another agent |
| 1–2 | Incompatible with the rest of the team's work |

To score this dimension, read all outputs in `.mesh/outputs/` before reviewing.

### 4. Clarity (15%)
Is the output well-structured and clearly communicated?

| Score | Criteria |
|-------|----------|
| 9–10 | Exemplary structure; easy to follow; no ambiguity |
| 7–8 | Clear with minor structural issues |
| 5–6 | Hard to follow in places; some ambiguity |
| 3–4 | Poorly structured; reader must infer meaning |
| 1–2 | Incomprehensible |

### 5. Constraint adherence (10%)
Does the output respect every constraint listed in `mission.md`?

| Score | Criteria |
|-------|----------|
| 9–10 | Every constraint followed without exception |
| 7–8 | Minor constraint slip — does not affect outcome |
| 5–6 | One or more constraints not followed |
| 3–4 | Multiple constraints violated |
| 1–2 | Constraints ignored |

---

## Calculating the score

```
Score = (Completeness × 0.25) + (Correctness × 0.30) + (Consistency × 0.20) + (Clarity × 0.15) + (Constraint adherence × 0.10)
```

Example: 7, 9, 8, 8, 6 → (7×0.25) + (9×0.30) + (8×0.20) + (8×0.15) + (6×0.10) = 1.75 + 2.70 + 1.60 + 1.20 + 0.60 = **7.85** → reject

---

## Thresholds

| Score | Action |
|-------|--------|
| ≥ 8.0 | Approve — post `approve` message |
| 6.0–7.9 | Reject — post `reject` with specific feedback |
| < 6.0 | Reject with escalate flag — notify Conductor this may not converge |

---

## What rejection feedback must contain

Every `reject` message must include:

1. The score table (one row per dimension)
2. Which dimensions caused the failure
3. Specific, actionable changes required — not vague ("improve completeness") but exact ("add error handling for the 401 case in the /auth route")
4. What is correct and does not need to change — prevents agents from fixing things that don't need fixing

---

## Convergence rules

- Maximum 3 revision rounds per agent output
- If an output is still below 8.0 after round 3, the Quality Reviewer posts an `escalate` message to the Conductor
- The Conductor decides: accept at current score, re-brief the agent with a narrower scope, or exclude from synthesis
- These decisions are logged in `.mesh/quality/scores.md`

---

## Scores ledger format

`.mesh/quality/scores.md` is maintained by the Quality Reviewer throughout the run:

```markdown
# Quality ledger

| Agent | v1 | v2 | v3 | Status |
|-------|----|----|-----|--------|
| architect | 9.1 | — | — | approved |
| full-stack-dev | 6.2 | 8.7 | — | approved |
| database-designer | 8.3 | — | — | approved |
| security-analyst | 7.4 | 8.1 | — | approved |
| test-engineer | — | — | — | pending |
| api-designer | — | — | — | pending |

**Team average (approved outputs):** 8.6
**Pending:** 2
```
