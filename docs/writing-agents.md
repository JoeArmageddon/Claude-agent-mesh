# Writing agents for claude-agent-mesh

A guide to adding new specialist agents to the mesh.

---

## Before you start

Read `agents/engineering/architect/AGENT.md`. It is the quality reference. Everything in this guide is about how to reach that standard.

Also read `protocol/PROTOCOL.md` for the message envelope format and `protocol/QUALITY-RUBRIC.md` for how agents are scored.

---

## The AGENT.md structure

Every agent is a single `AGENT.md` file. No other files in the agent directory.

```markdown
---
agent: kebab-case-id
role: One sentence — what this agent produces
token-budget: reads [what] ≤[N]K · writes ≤1.2K
---

# [Role Title]

## Identity
## Expertise
## Protocol           ← optional, only if coordination is needed
## Output format (≤ 1,200 tokens)
## Hard rules
```

Every output section must end with:
```
## Status: [complete / blocked — reason]
```

---

## The frontmatter

**`agent`** — kebab-case ID. This is how other agents address messages to this agent. It must be unique across the mesh.

**`role`** — one sentence stating exactly what this agent produces. Not what it does. What it *produces*. "REST/GraphQL contract design and OpenAPI specification" is a role. "Helps with APIs" is not.

**`token-budget`** — state what the agent reads and the budget for reading it, plus the output limit. All domain agents are Tier 4: reads ≤ 6,000 tokens total, writes ≤ 1,200 tokens.

---

## Writing Identity

The Identity section is the most important and the most commonly weak. It should be:

- **First person** — "I design before anyone builds" not "This agent designs..."
- **A mindset statement** — what this agent cares about, what they never do
- **Not a job description** — it is not a list of responsibilities
- **2–4 sentences** — longer is not better

Bad:
> The API Designer is responsible for creating OpenAPI specifications and REST contracts. It handles endpoint design, authentication, and error formats.

Good:
> I design the contract between systems — not the implementation, the interface. My output is the source of truth that every integration team, SDK generator, and test harness will depend on. I am precise about names, exact about schemas, and unambiguous about error codes.

The test: does it sound like a person with strong opinions, or a job posting?

---

## Writing Expertise

List specific tools, frameworks, and methodologies. Be precise.

Bad:
> API design, performance testing, data validation, error handling

Good:
> OpenAPI 3.0/3.1, REST resource modelling, GraphQL schema design, JSON Schema, HTTP semantics, idempotency keys, pagination patterns (cursor, offset, keyset), versioning strategies (URL path, header, content negotiation), rate limiting headers (X-RateLimit-*), OAuth 2.0 flows

The test: could you replace any item in the list with a synonym and not lose information? If yes, it is too vague.

---

## Writing the Protocol section

Only include Protocol if the agent must coordinate with another agent before producing output. Not all agents need this.

If included, Protocol should specify:
1. What the agent reads first
2. Whether it needs to request from another agent (and which one)
3. Where it writes its output
4. What message it posts when done

Example:
```markdown
## Protocol

1. Read mission.md and your brief.
2. Post a `request` to `architect` for the component breakdown if not already in the message bus.
3. Wait for the `response` before writing endpoints.
4. Write output to `.mesh/outputs/api-designer/v1.md`.
5. Post an `output` message announcing it.
```

---

## Designing the output format

The output format is a markdown template that the agent fills in. Design it to:

1. **Capture exactly what this agent is supposed to produce** — no more, no less
2. **Be completable within 1,200 tokens** — every section has a token budget
3. **End with `## Status: [complete / blocked — reason]`**

Show the template with placeholder descriptions in brackets, e.g.:
```markdown
## Architecture decisions
[The key structural choices — ≤ 400 tokens]
- Decision: [what] — Rationale: [why]
```

Sum the token budgets across all sections. The total must be ≤ 1,200 tokens.

---

## Writing Hard rules

Hard rules are the guard rails that prevent the most common failures for this specific agent. They must be:

- **Specific** — not "be accurate" but "every endpoint must have at least one documented error response"
- **Actionable** — someone reading it knows exactly when to apply it
- **Failure-relevant** — violating the rule would cause a real failure in the output
- **5–8 rules maximum** — more than 8 dilutes the force of the rules
- **Formatted as "Always X" or "Never Y"**

Test each rule by asking: "If an agent violated this rule, would the output fail Quality Review?" If no, cut it.

---

## Token budget reference

| Item | Limit |
|------|-------|
| Total reads (mission + other sources) | ≤ 6,000 tokens |
| Own output | ≤ 1,200 tokens |
| Request message to another agent | ≤ 200 tokens |
| Response to another agent's request | ≤ 500 tokens |
| Sub-agent spawning | Never — domain agents cannot spawn sub-agents |

---

## Inter-agent coordination patterns

Some agents must wait for another agent's output before they can proceed. Common patterns:

| Agent | Waits for |
|-------|-----------|
| api-designer | architect component breakdown |
| ux-designer | product-strategist feature spec |
| full-stack-dev | database-designer schema |
| test-engineer | full-stack-dev implementation |
| financial-modeler | market-analyst TAM/SAM/SOM |
| pricing-strategist | market-analyst + financial-modeler |

If your agent needs another agent's output, include a Protocol section with a `request` message to that agent.

---

## CI validation

Before submitting, run:
```bash
python .github/scripts/validate_agents.py
```

The validator checks:
- Frontmatter fields present: `agent`, `role`, `token-budget`
- Required sections present: `## Identity`, `## Expertise`, `## Output format`, `## Hard rules`
- Each output section ends with a Status line

---

## Quality checklist

Before submitting an AGENT.md:

- [ ] Identity is first-person and reads like a mindset statement, not a job description
- [ ] Expertise lists specific tools/frameworks (not generic categories)
- [ ] Output format sections have explicit token budgets that sum to ≤ 1,200
- [ ] Hard rules are specific and failure-relevant (not generic good practices)
- [ ] Status line is included in the output format template
- [ ] CI validation passes
- [ ] You have read `agents/engineering/architect/AGENT.md` and your agent reaches that quality bar
