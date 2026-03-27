# Message protocol

Every communication between agents uses a structured message envelope. This is the only way agents communicate — no direct calls, no shared memory, no implicit state.

---

## Envelope format

Every message is a markdown file at `.mesh/messages/[timestamp]-[from]-[to]-[type].md`.

Filename format: `[YYYYMMDDTHHmmss]-[from-id]-[to-id]-[type].md`

Example: `20260327T143022-architect-quality-reviewer-response.md`

### File structure

```markdown
---
from: [agent-id]
to: [agent-id | broadcast]
type: [see types below]
score: [1-10, only on review/approve/reject messages]
ref: [filename of message being replied to, if a response]
timestamp: [ISO 8601]
---

[message body — free markdown, max 800 tokens]
```

---

## Message types

| Type | Sent by | Meaning |
|------|---------|---------|
| `brief` | Conductor | Initial task assignment to an agent |
| `request` | Any agent | Asking another agent for specific input or clarification |
| `response` | Any agent | Responding to a `request` |
| `output` | Any agent | Announcing a deliverable is ready at `.mesh/outputs/[id]/v[n].md` |
| `review` | Quality Reviewer | Score + feedback on an output |
| `reject` | Quality Reviewer | Score < 8 — output must be revised |
| `approve` | Quality Reviewer | Score ≥ 8 — output accepted |
| `revision` | Any agent | Announcing a revised deliverable after rejection |
| `escalate` | Any agent | Flagging a blocker that requires Conductor intervention |
| `halt` | Conductor | Emergency stop — all agents cease work |

---

## Agent IDs

Use kebab-case, lowercase. Examples:

- `conductor`
- `quality-reviewer`  
- `synthesizer`
- `architect`
- `full-stack-dev`
- `database-designer`
- `devops-engineer`
- `security-analyst`
- `performance-engineer`
- `test-engineer`
- `api-designer`
- `product-strategist`
- `ux-designer`
- `user-researcher`
- `content-strategist`
- `accessibility-analyst`
- `market-analyst`
- `financial-modeler`
- `pricing-strategist`
- `competitive-analyst`
- `data-engineer`
- `analytics-specialist`
- `ml-specialist`
- `viz-designer`
- `technical-writer`
- `copywriter`
- `editor`
- `docs-specialist`
- `contract-analyst`
- `compliance-specialist`
- `ip-analyst`
- `privacy-officer`
- `project-coordinator`
- `risk-analyst`
- `process-designer`

---

## Agent inbox protocol

When an agent is spawned, it must:

1. Read `.mesh/mission.md` — understand the overall task
2. Read its own `brief` message from the Conductor at `.mesh/messages/*-conductor-[my-id]-brief.md`
3. Read any `request` messages addressed to it
4. Produce its output
5. Post an `output` message announcing the deliverable
6. Then wait — do not proceed further until a `review`, `approve`, or `reject` message arrives

When a `reject` arrives:
1. Read the rejection feedback carefully
2. Revise the output (increment version: v1 → v2)
3. Post a `revision` message
4. Maximum 3 revision rounds — if still rejected at v3, post an `escalate` message

---

## Inter-agent requests

An agent can request specific input from any other agent. This is what makes the mesh bidirectional.

Example: Full-Stack Dev asking Database Designer about schema:

```markdown
---
from: full-stack-dev
to: database-designer
type: request
timestamp: 2026-03-27T14:35:00Z
---

I'm implementing the auth endpoint. I need:
1. Exact column names for the users table
2. Whether refresh_tokens has an index on user_id
3. The RLS policy for selecting user records

Please respond before I finalise v1.
```

The Database Designer reads this, responds via a `response` message, and Full-Stack Dev reads the response before producing their output.

---

## Quality review message format

```markdown
---
from: quality-reviewer
to: [agent-id]
type: reject
score: 6.2
ref: 20260327T143500-full-stack-dev-quality-reviewer-output.md
timestamp: 2026-03-27T14:40:00Z
---

## Score: 6.2/10 — revision required

| Dimension | Score | Notes |
|-----------|-------|-------|
| Completeness | 5/10 | Rate limiting middleware not implemented |
| Correctness | 7/10 | Auth logic correct but error codes non-standard |
| Consistency | 7/10 | Matches DB schema from database-designer |
| Clarity | 8/10 | Code is readable |
| Constraint adherence | 4/10 | Mission requires RFC 7807 error format — not used |

## Required changes for v2
1. Add `express-rate-limit` middleware on the `/auth` route (see mission.md constraint #3)
2. Replace all error returns with RFC 7807 format: `{ type, title, status, detail }`
3. Handle the 429 rate limit case explicitly

## Not required to change
- The JWT signing logic is correct
- The password hashing approach is appropriate
```

---

## Broadcast messages

Use `to: broadcast` for messages all agents should read (rare):

- Conductor sends a `halt` to `broadcast` to stop all agents
- Conductor may send a `brief` update to `broadcast` if a constraint changes mid-run

---

## Message size limits

| Message type | Max tokens |
|-------------|-----------|
| `brief` | 300 |
| `request` | 200 |
| `response` | 500 |
| `output` announcement | 100 (path + 1-line summary only) |
| `review` | 400 |
| `reject` | 500 |
| `approve` | 100 |
| `revision` | 100 |
| `escalate` | 200 |

The message is not the deliverable — it announces or requests. Deliverables live in `.mesh/outputs/`.
