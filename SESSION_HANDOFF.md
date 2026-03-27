# claude-agent-mesh — Session Handoff
**From:** Claude.ai session 2026-03-27
**Continue in:** Claude Code, any directory
**Repo will live at:** Create a new GitHub repo (separate from claude-session-master)

---

## WHAT THIS PROJECT IS

`claude-agent-mesh` is a **standalone** multi-agent framework for Claude Code.

It is philosophically and technically different from `claude-session-master`:

| | claude-session-master | claude-agent-mesh |
|--|---|---|
| Purpose | Session memory, context, phases | Deploy specialist agents against a task |
| Trigger | `/start-session` | `/mesh [task]` |
| Structure | Hierarchical org chart | Dynamic mesh assembled per task |
| Communication | File writing (one-way) | Bidirectional message bus |
| Quality control | Phase reflection (manual) | Built-in scoring loop, auto-reject < 8.0 |
| Revision | Manual | Agents auto-revise on rejection |
| Memory files | SESSION_LOG, MEMORY, PHASES | `.mesh/` workspace (deleted after run) |
| Install | Into project + global | Into project only |
| GitHub repo | JoeArmageddon/Claude-Master-Skill | NEW REPO: claude-agent-mesh |

**The core mechanic:** Conductor reads task → infers which agents are needed → assembles team → agents post outputs to message bus → Quality Reviewer scores every output 1-10 → below 8.0 gets rejected with specific feedback → agent revises and resubmits → when all pass, Synthesizer merges into final output.

---

## COMPLETE FILE STATUS

### EXISTS AND COMPLETE ✓

```
README.md                                    ✓ (full product page)
protocol/PROTOCOL.md                         ✓ (message bus spec, envelope format, all types)
protocol/QUALITY-RUBRIC.md                   ✓ (5-dimension scoring, thresholds, ledger format)
core/conductor/AGENT.md                      ✓ (signal routing table, full 8-step protocol)
core/quality-reviewer/AGENT.md              ✓ (scoring, rejection format, convergence gating)
core/synthesizer/AGENT.md                   ✓ (merge rules, voice unification, output spec)
agents/engineering/architect/AGENT.md       ✓
agents/engineering/full-stack-dev/AGENT.md  ✓
agents/engineering/database-designer/AGENT.md ✓
agents/engineering/devops-engineer/AGENT.md ✓
agents/engineering/security-analyst/AGENT.md ✓
agents/engineering/performance-engineer/AGENT.md ✓
agents/engineering/test-engineer/AGENT.md   ✓
```

### DIRECTORIES EXIST — AGENT.md MISSING ✗

Every path below needs an `AGENT.md` written to it.

```
agents/engineering/api-designer/AGENT.md
agents/product/product-strategist/AGENT.md
agents/product/ux-designer/AGENT.md
agents/product/user-researcher/AGENT.md
agents/product/content-strategist/AGENT.md
agents/product/accessibility-analyst/AGENT.md
agents/business/market-analyst/AGENT.md
agents/business/financial-modeler/AGENT.md
agents/business/pricing-strategist/AGENT.md
agents/business/competitive-analyst/AGENT.md
agents/data/data-engineer/AGENT.md
agents/data/analytics-specialist/AGENT.md
agents/data/ml-specialist/AGENT.md
agents/data/viz-designer/AGENT.md
agents/writing/technical-writer/AGENT.md
agents/writing/copywriter/AGENT.md
agents/writing/editor/AGENT.md
agents/writing/docs-specialist/AGENT.md
agents/legal/contract-analyst/AGENT.md
agents/legal/compliance-specialist/AGENT.md
agents/legal/ip-analyst/AGENT.md
agents/legal/privacy-officer/AGENT.md
agents/ops/project-coordinator/AGENT.md
agents/ops/risk-analyst/AGENT.md
agents/ops/process-designer/AGENT.md
```

### DOESN'T EXIST YET — CREATE FROM SCRATCH ✗

```
.claude/commands/mesh.md            (main /mesh command)
.claude/commands/mesh-status.md     (/mesh-status)
.claude/commands/mesh-halt.md       (/mesh-halt)
.claude/commands/mesh-roles.md      (/mesh-roles)
.claude/commands/mesh-review.md     (/mesh-review)
install.sh                          (standalone installer)
.gitignore
LICENSE                             (MIT)
CONTRIBUTING.md
plugin.json                         (Claude Code marketplace manifest)
docs/how-it-works.md               (deep dive explainer)
docs/writing-agents.md             (guide to adding new agents)
.github/workflows/ci.yml           (validates AGENT.md format)
.github/ISSUE_TEMPLATE/bug_report.md
.github/ISSUE_TEMPLATE/feature_request.md
```

---

## AGENT.md TEMPLATE — USE THIS FOR EVERY MISSING AGENT

Every AGENT.md follows this exact structure. Match the depth and quality of `agents/engineering/architect/AGENT.md` (the gold standard). Read it before writing any others.

```markdown
---
agent: [kebab-case-id]
role: [One sentence — what this agent produces]
token-budget: reads [what] ≤[N]K · writes ≤1.2K
---

# [Role Title]

## Identity
[2-4 sentences: what this agent cares about, their standards, what they never do.
First person. Strong voice. Not a job description — a mindset statement.]

## Expertise
[Comma-separated list of specific tools, frameworks, methodologies.
Be specific: "Zod validation" not "input validation". "k6 load testing" not "performance testing".]

## Protocol
[Optional — only include if agent has specific coordination steps, e.g. must wait for another agent's output before starting]

## Output format (≤ 1,200 tokens)

[Markdown template showing exact sections and token budgets within each]

## Hard rules
[Bullet list — absolute non-negotiables. "Always X" or "Never Y".
5-8 rules maximum. Every rule must be something that would cause a real failure if violated.]
```

---

## TOKEN BUDGETS — APPLY TO EVERY AGENT

All domain agents are **Tier 4** (specialists). Use these budgets:

| Budget item | Limit |
|-------------|-------|
| Source material reads (total) | ≤ 6,000 tokens |
| Own output | ≤ 1,200 tokens |
| Message to another agent (`request`) | ≤ 200 tokens |
| Response to another agent | ≤ 500 tokens |
| Sub-spawning | Never — domain agents do not spawn sub-agents |

Every AGENT.md must state these in the frontmatter `token-budget` field.

Every output must end with:
```
## Status: [complete / blocked — reason]
```

---

## THE MESSAGE BUS — HOW AGENTS COMMUNICATE

This is what makes the mesh different from a hierarchy. Agents talk to each other.

The bus lives at `.mesh/messages/`. Every file is an envelope:

```markdown
---
from: [agent-id]
to: [agent-id]
type: request | response | output | review | reject | approve | revision | escalate | halt
score: [1-10, only on review/approve/reject]
ref: [filename being replied to, if a response]
timestamp: [ISO 8601]
---

[body — max tokens per type in PROTOCOL.md]
```

**Key inter-agent request patterns agents commonly need:**
- `full-stack-dev` → requests schema from `database-designer` before writing code
- `security-analyst` → reads `full-stack-dev` output then requests a fix before QR review
- `test-engineer` → reads `full-stack-dev` output to write tests against real implementation
- `api-designer` → requests architect's component breakdown before writing API spec
- `ux-designer` → requests `product-strategist` feature spec before designing flows

---

## QUALITY SCORING — HOW IT WORKS

The Quality Reviewer scores every output on 5 dimensions:

| Dimension | Weight | Checks |
|-----------|--------|--------|
| Completeness | 25% | Did agent fully address their brief? |
| Correctness | 30% | Technically accurate, no bugs? |
| Consistency | 20% | Aligns with other approved outputs? |
| Clarity | 15% | Well-structured, readable? |
| Constraint adherence | 10% | Follows mission.md constraints? |

Score = weighted average × 10. **Threshold: 8.0.** Below = auto-reject with feedback.
Max 3 revision rounds before escalation to Conductor.

---

## WHAT EACH MISSING AGENT SHOULD PRODUCE

Use this as a guide for what each agent's output section should contain:

### Engineering / API Designer
Produces: OpenAPI 3.0 spec or equivalent REST/GraphQL contract. Endpoint definitions, request/response schemas, auth requirements, error response formats, versioning strategy, rate limit headers.

### Product / Product Strategist
Produces: Feature spec with user stories, acceptance criteria, scope definition, edge cases, out-of-scope list, success metrics.

### Product / UX Designer
Produces: User flow descriptions, wireframe-level screen outlines (text, not images), interaction patterns, component hierarchy, navigation model.

### Product / User Researcher
Produces: Research plan or synthesised findings. Persona definitions, key user jobs-to-be-done, pain points, behavioural insights. Can also produce interview scripts or survey designs.

### Product / Content Strategist
Produces: Content architecture, messaging hierarchy, tone guidelines, content types needed, editorial calendar structure (not the copy itself — that's the Copywriter).

### Product / Accessibility Analyst
Produces: WCAG 2.1 AA checklist for the feature, specific component-level accessibility requirements, ARIA patterns needed, keyboard navigation spec, screen reader behaviour spec.

### Business / Market Analyst
Produces: Market size, segment definitions, TAM/SAM/SOM, market trends, growth signals, competitive landscape overview.

### Business / Financial Modeler
Produces: Revenue projections, unit economics (CAC, LTV, payback period), cost model, break-even analysis, scenario modelling (base/bull/bear).

### Business / Pricing Strategist
Produces: Pricing recommendation with rationale, tier structure, price anchoring strategy, competitive price benchmarks, willingness-to-pay analysis.

### Business / Competitive Analyst
Produces: Named competitor analysis, feature matrix, positioning gaps, competitive moat assessment, differentiation opportunities.

### Data / Data Engineer
Produces: Pipeline architecture, data source definitions, transformation logic, schema for the data warehouse/lake, tooling choices (dbt, Airflow, etc.), data quality rules.

### Data / Analytics Specialist
Produces: Metrics framework, KPI definitions with formulas, tracking plan (event names, properties), analytics tooling recommendations, dashboard wireframe (text).

### Data / ML Specialist
Produces: Model selection rationale, feature engineering approach, training data requirements, evaluation metrics, inference pipeline design, MLOps considerations.

### Data / Visualisation Designer
Produces: Chart type recommendations per metric, dashboard layout spec, colour encoding rules, interactivity requirements, accessibility for data viz.

### Writing / Technical Writer
Produces: Documentation structure, API reference format, README template, code comment style guide, or full written documentation depending on brief.

### Writing / Copywriter
Produces: Marketing copy — headlines, CTAs, landing page copy, ad copy, email subject lines and body. Follows brand voice from Content Strategist if both active.

### Writing / Editor
Produces: Edited version of another agent's written output, with tracked changes described in text. Focuses on clarity, consistency, grammar, and tone alignment.

### Writing / Docs Specialist
Produces: Structured documentation — user guides, onboarding docs, help centre articles, changelogs, release notes. Distinct from Technical Writer who writes developer docs.

### Legal / Contract Analyst
Produces: Contract review with clause-by-clause analysis, redline suggestions, risk flags, missing clauses that should be added, deal-breaker identification.

### Legal / Compliance Specialist
Produces: Regulatory compliance checklist for the relevant jurisdiction/standard, gap analysis against current state, prioritised remediation steps.

### Legal / IP Analyst
Produces: IP landscape analysis, patent/trademark search results, freedom-to-operate assessment, licensing recommendations, IP protection strategy.

### Legal / Privacy Officer
Produces: Privacy impact assessment, data inventory for the feature, GDPR/CCPA compliance requirements, consent mechanism design, data retention policy.

### Ops / Project Coordinator
Produces: Project plan with milestones, timeline, dependencies, resource requirements, risk register, RACI matrix.

### Ops / Risk Analyst
Produces: Risk register with likelihood × impact scoring, mitigation strategies, early warning indicators, contingency plans.

### Ops / Process Designer
Produces: Process flow (text-based), SOPs, decision trees for operational workflows, handoff definitions between teams or systems.

---

## SLASH COMMANDS — EXACT SPEC

### `/mesh` — main command

```markdown
# /mesh

Deploy a dynamic agent mesh for a complex task.

Read core/conductor/AGENT.md and follow it exactly.

$ARGUMENTS: the task description. If empty, ask: "What do you need the mesh to work on? Be as specific as possible — team size and quality both depend on it."

## Steps

1. Parse $ARGUMENTS as the task
2. Run the Conductor protocol from core/conductor/AGENT.md — Steps 1 through 8
3. Present .mesh/final/output.md to the user when complete
4. Output the mesh run summary:
   ```
   Mesh complete.
   Team: [agent list]
   Revisions: [total across all agents]
   Avg quality: [X]/10
   Output: .mesh/final/output.md
   ```

## Quick patterns (pass as first word of $ARGUMENTS)

| Keyword | Team assembled |
|---------|---------------|
| `build [feature]` | Architect + Full-Stack Dev + Database Designer + Security Analyst + Test Engineer |
| `api [name]` | Architect + API Designer + Full-Stack Dev + Security Analyst + Test Engineer |
| `launch [thing]` | Product Strategist + Content Strategist + Copywriter + Technical Writer |
| `research [topic]` | Market Analyst + Competitive Analyst + Financial Modeler |
| `design [feature]` | Product Strategist + UX Designer + User Researcher + Accessibility Analyst |
| `audit [scope]` | Security Analyst + Compliance Specialist + Privacy Officer |
| `price [product]` | Pricing Strategist + Financial Modeler + Competitive Analyst + Market Analyst |
| `plan [project]` | Project Coordinator + Risk Analyst + Process Designer |
| `document [thing]` | Technical Writer + Docs Specialist + Editor |
| `data [pipeline]` | Data Engineer + Analytics Specialist + ML Specialist |

Examples:
/mesh build a rate-limited user authentication endpoint with JWT and refresh tokens
/mesh design the onboarding flow for new users in our SaaS product
/mesh audit our codebase for GDPR compliance before EU launch
/mesh price our enterprise tier with competitive benchmarking
```

### `/mesh-status`
```markdown
# /mesh-status
Show current mesh run status.
Read .mesh/quality/scores.md and .mesh/team.json
Output a formatted status table: agent, score(s), status, pending/complete.
If no .mesh/ exists: "No active mesh run."
```

### `/mesh-halt`
```markdown
# /mesh-halt
Stop the current mesh immediately.
Write a halt message to .mesh/messages/[timestamp]-conductor-broadcast-halt.md
Archive .mesh/ to .mesh-archive/[timestamp]/ for inspection
Output: "Mesh halted. Archive at .mesh-archive/[timestamp]/"
```

### `/mesh-roles`
```markdown
# /mesh-roles
List all available specialist agents.
Read the agents/ directory and list every agent with their role description (from AGENT.md frontmatter).
Group by domain: Engineering · Product · Business · Data · Writing · Legal · Ops
Format as a clean table: Agent | Role | Domain
```

### `/mesh-review`
```markdown
# /mesh-review
Run the Quality Reviewer on a specific file.
$ARGUMENTS: path to the file to review.
Read core/quality-reviewer/AGENT.md and apply the scoring rubric to $ARGUMENTS.
Output the full score breakdown and pass/fail verdict.
If no $ARGUMENTS: "Usage: /mesh-review [path/to/file.md]"
```

---

## INSTALL SCRIPT SPEC

`install.sh` must:
1. Copy `.claude/commands/*.md` to project's `.claude/commands/`
2. NOT install any global skills (this is project-only, unlike claude-session-master)
3. NOT touch `~/.claude/` at all
4. Create `.gitignore` entry for `.mesh/` and `.mesh-archive/`
5. Print coloured success output
6. Be safe to re-run (skip existing files)
7. Support `--dir=/path` flag for installing into a different directory

---

## PLUGIN.JSON SPEC

```json
{
  "name": "claude-agent-mesh",
  "version": "1.0.0",
  "description": "Dynamic multi-agent mesh for Claude Code. Assembles a specialist team from any task, runs a quality scoring loop, and delivers a synthesized output. Standalone — no dependency on other frameworks.",
  "license": "MIT",
  "keywords": ["multi-agent", "mesh", "ai-agents", "quality-control", "workflow"],
  "commands": [
    { "name": "mesh", "path": ".claude/commands/mesh.md", "scope": "project" },
    { "name": "mesh-status", "path": ".claude/commands/mesh-status.md", "scope": "project" },
    { "name": "mesh-halt", "path": ".claude/commands/mesh-halt.md", "scope": "project" },
    { "name": "mesh-roles", "path": ".claude/commands/mesh-roles.md", "scope": "project" },
    { "name": "mesh-review", "path": ".claude/commands/mesh-review.md", "scope": "project" }
  ]
}
```

---

## CI WORKFLOW SPEC

`.github/workflows/ci.yml` should:
1. Run on push and PR to main
2. Validate every AGENT.md has required frontmatter fields: `agent`, `role`, `token-budget`
3. Validate every AGENT.md has required sections: `## Identity`, `## Expertise`, `## Output format`, `## Hard rules`
4. Validate PROTOCOL.md hasn't lost any message types
5. Use a simple Python or bash script — no heavy dependencies
6. Run on ubuntu-latest

---

## KEY DESIGN DECISIONS — DO NOT CHANGE

1. **Completely standalone** — no imports from claude-session-master, no shared files, no shared commands
2. **`.mesh/` is ephemeral** — created per run, deleted or archived when done. It is NOT a memory system.
3. **Message bus is the only communication** — agents never call each other directly or share context windows
4. **Quality Reviewer is always spawned** — even if only 2 agents are active. It is mandatory.
5. **Synthesizer runs last, after all approvals** — never mid-run
6. **Agent IDs are kebab-case** — `full-stack-dev`, `database-designer`, not camelCase or spaces
7. **Output format is ≤ 1,200 tokens for all domain agents** — enforce this in the AGENT.md
8. **The Conductor infers the team** — user never manually specifies agents. They describe the task.
9. **Max 8 agents per run** — more degrades quality and coordination
10. **All agent dirs are flat** — `agents/engineering/architect/AGENT.md` — no sub-subdirectories

---

## PASTE THIS EXACT PROMPT INTO CLAUDE CODE

```
I'm building a new repo called claude-agent-mesh. It's a standalone multi-agent mesh framework for Claude Code — completely separate from claude-session-master.

The files built so far are in the zip I'm attaching (or at the path I tell you). Read SESSION_HANDOFF.md first — it has the complete spec, all file statuses, and exact instructions.

Your tasks in order:

1. Read SESSION_HANDOFF.md completely before touching any files.

2. Write AGENT.md for every path listed in the "DIRECTORIES EXIST — AGENT.md MISSING" section. Use the AGENT.md template and the "What each agent should produce" guide in the handoff. Match the quality of agents/engineering/architect/AGENT.md — read that file first as your reference.

3. Write all 5 slash commands to .claude/commands/ using the exact specs in the handoff.

4. Write install.sh, LICENSE (MIT), CONTRIBUTING.md, plugin.json, docs/how-it-works.md, docs/writing-agents.md, .github/workflows/ci.yml, and both issue templates.

5. Write a .gitignore that includes .mesh/, .mesh-archive/, node_modules/, .DS_Store, *.log.

6. Init git, commit everything with message "feat: initial release v1.0.0 — claude-agent-mesh", then push to the GitHub repo URL I give you.

Do not ask questions. Read the handoff, make decisions, build everything. If you hit a genuine blocker, flag it specifically and continue with everything else.
```

---

## RESEARCH THAT SHAPED THE DESIGN

These are the key insights from the research done in this session:

**On why file-based communication beats shared context:**
- Each agent in its own Task context = clean 200K window per agent
- Shared workspace (files) = permanent, inspectable, versionable
- Message bus = async, typed, traceable — vs implicit shared state which degrades

**On quality scoring as the convergence mechanism:**
- Without a quality gate, multi-agent systems produce the average quality of all agents
- With a scoring threshold (8.0), the system converges toward the quality of the best agents
- Specific rejection feedback (not vague "improve this") is what makes revision loops work
- 3-round maximum prevents infinite loops on truly broken tasks

**On the Conductor inferring the team:**
- User shouldn't need to know which agents exist
- Signal table (keywords → agents) is the right abstraction
- Max 8 agents is a hard cap — coordination overhead grows faster than quality above 8

**On synthesis as a distinct phase:**
- Never synthesise mid-run — partial synthesis creates inconsistency
- The Synthesizer must re-read all outputs, not just concatenate them
- Prose must be rewritten in one voice — code must be preserved exactly

**On token efficiency:**
- Main session context never reads below Synthesizer output
- Message bus files are small (typed envelopes, size-capped)
- Agent outputs are capped at 1,200 tokens — forces compression discipline
- `.mesh/` is deleted after run — no accumulation of stale context across runs
