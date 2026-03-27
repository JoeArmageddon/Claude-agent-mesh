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

Use kebab-case, lowercase.

**Core:**
`conductor` · `quality-reviewer` · `synthesizer`

**Engineering:**
`architect` · `full-stack-dev` · `frontend-engineer` · `backend-engineer` · `mobile-engineer` · `database-designer` · `devops-engineer` · `sre` · `ml-engineer` · `infrastructure-engineer` · `security-analyst` · `performance-engineer` · `test-engineer` · `api-designer`

**Product:**
`product-strategist` · `product-manager` · `ux-designer` · `ui-designer` · `user-researcher` · `content-strategist` · `accessibility-analyst` · `localisation-specialist` · `growth-pm`

**Marketing:**
`brand-strategist` · `marketing-copywriter` · `seo-specialist` · `social-media-manager` · `email-marketing-specialist` · `paid-ads-specialist` · `pr-specialist` · `community-manager` · `video-content-creator` · `influencer-marketing-specialist`

**Business:**
`market-analyst` · `competitive-analyst` · `business-development-strategist` · `partnership-analyst` · `strategy-consultant` · `investor-relations-specialist` · `financial-modeler` · `pricing-strategist`

**Data:**
`data-engineer` · `analytics-specialist` · `ml-specialist` · `viz-designer` · `data-scientist` · `bi-analyst`

**Writing:**
`technical-writer` · `copywriter` · `editor` · `docs-specialist` · `grant-writer` · `speech-writer` · `scriptwriter`

**Legal:**
`contract-analyst` · `compliance-specialist` · `ip-analyst` · `privacy-officer` · `employment-law-specialist` · `corporate-governance-specialist`

**HR:**
`hr-business-partner` · `recruiter` · `ld-specialist` · `culture-analyst` · `compensation-analyst` · `dei-specialist`

**Ops:**
`project-coordinator` · `risk-analyst` · `process-designer` · `financial-analyst` · `accountant` · `tax-specialist` · `procurement-specialist`

**Customer:**
`customer-support-specialist` · `customer-success-manager` · `onboarding-specialist`

**Sales:**
`sales-strategist` · `sdr` · `sales-enablement-specialist` · `revops-analyst`

---

## Collaboration clusters

Agents within the same cluster naturally share context and should coordinate when both are activated on the same run. The Conductor declares the active channels in `mission.md`.

| Cluster | Members | What they share |
|---------|---------|----------------|
| **Build** | architect, full-stack-dev, backend-engineer, frontend-engineer, mobile-engineer, database-designer, api-designer | System design, data contracts, API shape |
| **Platform** | devops-engineer, sre, infrastructure-engineer, ml-engineer | Infra decisions, deployment targets, SLOs |
| **Quality** | test-engineer, performance-engineer, security-analyst | Acceptance criteria, risk surface, edge cases |
| **Product** | product-strategist, product-manager, ux-designer, ui-designer, user-researcher, growth-pm | User needs, feature scope, success metrics |
| **Content** | content-strategist, copywriter, marketing-copywriter, technical-writer, editor, docs-specialist | Voice, messaging, narrative consistency |
| **Marketing** | brand-strategist, marketing-copywriter, seo-specialist, social-media-manager, email-marketing-specialist, paid-ads-specialist, pr-specialist, community-manager, video-content-creator, influencer-marketing-specialist | Campaign strategy, brand alignment, channel mix |
| **Business** | market-analyst, competitive-analyst, business-development-strategist, partnership-analyst, strategy-consultant, investor-relations-specialist | Market context, strategic direction |
| **Finance** | financial-modeler, financial-analyst, pricing-strategist, accountant, tax-specialist | Numbers, projections, unit economics |
| **Data** | data-engineer, analytics-specialist, ml-specialist, viz-designer, data-scientist, bi-analyst | Schemas, metrics definitions, model outputs |
| **Legal** | contract-analyst, compliance-specialist, ip-analyst, privacy-officer, employment-law-specialist, corporate-governance-specialist | Risk, obligations, regulatory requirements |
| **HR** | hr-business-partner, recruiter, ld-specialist, culture-analyst, compensation-analyst, dei-specialist | People strategy, org design, culture |
| **Ops** | project-coordinator, risk-analyst, process-designer, procurement-specialist | Timelines, dependencies, operational risk |
| **Sales** | sales-strategist, sdr, sales-enablement-specialist, revops-analyst | Pipeline, messaging, conversion data |
| **Customer** | customer-support-specialist, customer-success-manager, onboarding-specialist | User friction, retention signals |

### Cross-cluster bridges

These pairs communicate across clusters whenever both are activated:

| Agent A | Agent B | Why |
|---------|---------|-----|
| architect | product-strategist | Requirements shape architecture decisions |
| architect | api-designer | API contracts drive implementation |
| ux-designer | frontend-engineer | Design handoff — specs → code |
| ui-designer | frontend-engineer | Component specs → implementation |
| security-analyst | compliance-specialist | Controls map to regulatory requirements |
| security-analyst | privacy-officer | Data handling overlaps security and privacy |
| compliance-specialist | privacy-officer | GDPR/regulatory scope overlaps |
| data-scientist | ml-specialist | Model research → productionised approach |
| ml-specialist | ml-engineer | Algorithm → deployed service |
| analytics-specialist | bi-analyst | Metrics definitions must be consistent |
| financial-modeler | pricing-strategist | Revenue model informs pricing tiers |
| product-manager | project-coordinator | Feature scope → delivery timeline |
| content-strategist | copywriter | Strategy → execution |
| content-strategist | marketing-copywriter | Brand voice consistency |
| growth-pm | analytics-specialist | Growth experiments need metric definitions |
| sales-strategist | revops-analyst | Strategy needs pipeline visibility |

---

## Agent inbox protocol

When an agent is spawned, it must:

1. Read `.mesh/mission.md` — understand the overall task and the **Communication channels** section which lists who you coordinate with
2. Read its own `brief` message from the Conductor at `.mesh/messages/*-conductor-[my-id]-brief.md` — check the **Coordinate with** list
3. Send `request` messages to any agents listed as coordinators **before** producing output — ask for the specific input you need from them
4. Read any incoming `request` messages addressed to you and respond promptly with `response` messages
5. After receiving responses from coordinators (or after a reasonable wait if none has replied), produce your output
6. Post an `output` message announcing the deliverable
7. Then wait — do not proceed further until a `review`, `approve`, or `reject` message arrives

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
