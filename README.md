<div align="center">

# claude-agent-mesh

**A dynamic multi-agent network for Claude Code.**
Describe a task. The mesh assembles the right team of specialists, has them message each other, score each other's work, reject outputs below quality threshold, and converge toward a final result — automatically.

[![License: MIT](https://img.shields.io/badge/License-MIT-6366f1.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-0ea5e9.svg)](https://claude.ai/code)
[![Install](https://img.shields.io/badge/install-bash%20install.sh-22c55e.svg)](#installation)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-f59e0b.svg)](CONTRIBUTING.md)

</div>

---

## What this is

`claude-agent-mesh` is a **standalone** multi-agent framework that runs inside Claude Code. It is not a session manager, not a memory system, and not a chat wrapper. It is a self-contained system for deploying a coordinated team of specialist agents against any complex task.

You describe what you need. The mesh figures out who should work on it, coordinates their work through a structured message bus, enforces quality through a scoring loop, and delivers a single synthesized output.

### How it differs from other approaches

| | Typical approach | claude-agent-mesh |
|--|---|---|
| Team structure | Fixed roles or manual selection | Assembled dynamically from the task description |
| Communication | One-way prompts / file dumps | Bidirectional typed message bus |
| Quality control | Manual review | Built-in 5-dimension scoring, auto-reject < 8.0/10 |
| Revision | Re-run manually | Agents automatically revise on rejection with specific feedback |
| Convergence | No guarantee | Runs until quality threshold met or max 3 revision rounds |
| Context usage | Shared, grows linearly | Isolated per agent — each gets a clean 200K window |
| Output | Last agent's output | Synthesizer merges all approved outputs in one voice |

---

## See it in action

```
You: /mesh build a rate-limited API for user authentication with JWT and refresh tokens

Conductor:
  → Task analysed
  → Team assembled: Architect, Full-Stack Dev, Database Designer,
                    API Designer, Security Analyst, Test Engineer
  → Mission written to .mesh/mission.md
  → 6 agents activated

[Agents work, posting outputs to .mesh/outputs/ and messages to .mesh/messages/]

Quality Reviewer:
  → Architect v1: 9.2/10 ✓ approved
  → Full-Stack Dev v1: 6.4/10 ✗ rejected
      Completeness: 5/10 — rate limit middleware not implemented
      Correctness:  6/10 — refresh token rotation missing on reuse
      Clarity:      8/10 — well structured
  → Full-Stack Dev revising (v2)...
  → Full-Stack Dev v2: 8.7/10 ✓ approved
  → Security Analyst v1: 9.1/10 ✓ approved
  → API Designer v1: 8.5/10 ✓ approved
  → Database Designer v1: 9.3/10 ✓ approved
  → Test Engineer v1: 8.8/10 ✓ approved

Synthesizer:
  → Reading all 6 approved outputs
  → Final output written to .mesh/final/output.md

Mesh complete.
Team: 6 agents · 7 outputs (1 revision) · Avg quality: 8.93/10
Output: .mesh/final/output.md
```

---

## Requirements

- **Claude Code** installed (the Anthropic CLI tool)
- **Git** (for cloning)
- **bash** (macOS/Linux native; Windows via Git Bash, WSL, or MSYS2)
- No Node.js, no Python, no API keys beyond your existing Claude Code setup

---

## Installation

### macOS

```bash
# 1. Clone the repo
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git
cd Claude-agent-mesh

# 2. Navigate to your project directory
cd /path/to/your/project

# 3. Run the installer, pointing to where you cloned the mesh
bash /path/to/Claude-agent-mesh/install.sh

# Or install from within the mesh directory into a different project:
bash install.sh --dir=/path/to/your/project

# 4. Open Claude Code in your project
claude

# 5. Run your first mesh
/mesh build a user authentication system with email and OAuth
```

**Verification:** After running `install.sh`, you should see `.claude/commands/mesh.md` (and 4 other mesh commands) inside your project directory.

---

### Windows

Claude Code on Windows runs best with **Git Bash** (included with Git for Windows) or **WSL2**. Both are supported.

#### Option A — Git Bash (recommended for most Windows users)

```bash
# 1. Install Git for Windows if you haven't:
#    https://git-scm.com/download/win
#    During install, choose "Git Bash Here" option

# 2. Open Git Bash (right-click any folder → "Git Bash Here")

# 3. Clone the repo
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git
cd Claude-agent-mesh

# 4. Navigate to your project
cd /c/Users/YourName/Projects/your-project

# 5. Run the installer
bash /c/path/to/Claude-agent-mesh/install.sh

# Or with --dir flag:
bash /c/path/to/Claude-agent-mesh/install.sh --dir=/c/Users/YourName/Projects/your-project

# 6. Open Claude Code
claude

# 7. Run your first mesh
/mesh build a user authentication system with email and OAuth
```

**Important Windows paths:** Git Bash uses Unix-style paths. `C:\Users\Joe\Projects` becomes `/c/Users/Joe/Projects`.

#### Option B — WSL2 (Windows Subsystem for Linux)

WSL2 gives you a full Linux environment and is the most compatible option for development tools.

```bash
# 1. Install WSL2 (if not already installed) — run in PowerShell as Administrator:
wsl --install

# 2. Open your WSL terminal (Ubuntu by default)

# 3. Clone the repo
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git
cd Claude-agent-mesh

# 4. Navigate to your project
#    WSL mounts Windows drives at /mnt/c/
cd /mnt/c/Users/YourName/Projects/your-project

# 5. Run the installer
bash /path/to/Claude-agent-mesh/install.sh

# 6. Make sure Claude Code is accessible from WSL
#    If installed on Windows, you may need to add it to your WSL PATH:
export PATH="$PATH:/mnt/c/Users/YourName/AppData/Local/Programs/claude-code"

# 7. Open Claude Code
claude

# 8. Run your first mesh
/mesh build a user authentication system with email and OAuth
```

#### Option C — PowerShell / Command Prompt

The install script requires bash. If you don't have Git Bash or WSL, you can manually copy the files:

```powershell
# In PowerShell:
# 1. Clone the repo
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git

# 2. Create the .claude/commands directory in your project
New-Item -ItemType Directory -Force -Path "C:\path\to\your-project\.claude\commands"

# 3. Copy the commands
Copy-Item "C:\path\to\Claude-agent-mesh\.claude\commands\*.md" `
          "C:\path\to\your-project\.claude\commands\"

# 4. Add .mesh/ and .mesh-archive/ to your .gitignore
Add-Content "C:\path\to\your-project\.gitignore" "`n.mesh/`n.mesh-archive/"

# 5. Open Claude Code
claude
```

---

### Linux

```bash
# 1. Clone the repo
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git
cd Claude-agent-mesh

# 2. Make the installer executable (first time only)
chmod +x install.sh

# 3. Navigate to your project
cd /path/to/your/project

# 4. Run the installer
bash /path/to/Claude-agent-mesh/install.sh

# Or with --dir flag:
/path/to/Claude-agent-mesh/install.sh --dir=/path/to/your/project

# 5. Open Claude Code
claude

# 6. Run your first mesh
/mesh build a user authentication system with email and OAuth
```

**Distro-specific notes:**
- **Ubuntu/Debian:** bash is pre-installed. No additional setup needed.
- **Fedora/RHEL:** bash is pre-installed.
- **Arch:** bash is pre-installed.
- **Alpine:** Uses ash by default. Install bash: `apk add bash`

---

## What the installer does

`install.sh` is safe to re-run. It:

1. Creates `.claude/commands/` in your project (if not present)
2. Copies `mesh.md`, `mesh-status.md`, `mesh-halt.md`, `mesh-roles.md`, `mesh-review.md` into it — skips any that already exist
3. Adds `.mesh/` and `.mesh-archive/` entries to your `.gitignore` — skips if already present
4. Does **not** touch `~/.claude/` — this is a project-level install only
5. Does **not** install any global skills or modify system files

To install into a specific directory without `cd`-ing there:
```bash
bash install.sh --dir=/absolute/path/to/project
```

---

## Slash commands

Once installed, these commands are available in Claude Code:

### `/mesh [task]`

The main command. Describe your task and the mesh assembles the right team.

```
/mesh build a rate-limited authentication API with JWT
/mesh design the onboarding flow for new users in our SaaS
/mesh audit our app for GDPR compliance before EU launch
/mesh price our enterprise tier with competitive benchmarking
/mesh plan the Q2 infrastructure migration project
/mesh document the payment processing integration
```

**Quick-start keywords** (optional — the first word assembles a preset team):

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

If you don't use a keyword, the Conductor infers the team from your description.

---

### `/mesh-status`

Show the current mesh run status — agent scores, outputs, and pending/complete state.

```
/mesh-status
```

Output: a table of agent | score(s) | status for the active run. If no run is active: "No active mesh run."

---

### `/mesh-halt`

Stop the current mesh immediately. Archives the workspace for inspection.

```
/mesh-halt
```

The `.mesh/` workspace is archived to `.mesh-archive/[timestamp]/`. You can inspect what was completed before the halt.

---

### `/mesh-roles`

List every available specialist agent, grouped by domain.

```
/mesh-roles
```

Shows a table of Agent | Role | Domain for all 28 specialists.

---

### `/mesh-review [path]`

Run the Quality Reviewer's scoring rubric on any file.

```
/mesh-review .mesh/outputs/architect/v1.md
/mesh-review docs/my-spec.md
```

Returns the full 5-dimension score breakdown and pass/fail verdict.

---

## Agent roster

28 specialist agents across 7 domains. Only the agents needed for your task are activated.

### Core agents (always present in every run)

| Agent | Role |
|-------|------|
| Conductor | Reads the task, infers the team, writes mission.md, coordinates the run |
| Quality Reviewer | Scores every output 1–10 on 5 dimensions, rejects below 8.0 with specific feedback |
| Synthesizer | Merges all approved outputs into a single coherent document in one voice |

### Engineering (14 agents)

| Agent | Produces |
|-------|---------|
| Architect | System design, component breakdown, data flow, integration contracts |
| Full-Stack Developer | Implementation code across frontend and backend |
| Frontend Engineer | Component architecture, state management, Web Vitals, accessibility |
| Backend Engineer | Service layer, business logic, input validation, API implementation |
| Mobile Engineer | iOS/Android app architecture, offline-first design, platform conventions |
| Database Designer | Schema design, indexes, migration plans, query optimisation |
| DevOps Engineer | CI/CD pipelines, infrastructure-as-code, deployment strategy |
| Site Reliability Engineer | SLOs, observability stack, alerting strategy, incident runbooks |
| ML Engineer | Training pipelines, model serving, MLOps, drift monitoring |
| Infrastructure Engineer | Cloud architecture, networking, IAM, cost estimate |
| Security Analyst | Threat model, vulnerability assessment, remediation recommendations |
| Performance Engineer | Load test plan, bottleneck analysis, optimisation strategy |
| Test Engineer | Test strategy, test cases, coverage plan |
| API Designer | OpenAPI 3.0 spec, endpoint design, auth requirements, error formats |

### Product (9 agents)

| Agent | Produces |
|-------|---------|
| Product Strategist | Feature spec, user stories with acceptance criteria, success metrics |
| Product Manager | Prioritised backlog, milestones, dependency map, definition of done |
| UX Designer | User flows, screen outlines, interaction patterns, navigation model |
| UI Designer | Design tokens, component states, visual hierarchy, handoff spec |
| User Researcher | Personas, jobs-to-be-done, behavioural insights, research plan |
| Content Strategist | Content architecture, messaging hierarchy, tone guidelines |
| Accessibility Analyst | WCAG 2.1 AA checklist, ARIA patterns, keyboard/screen reader spec |
| Localisation Specialist | i18n architecture, locale support plan, translation workflow |
| Growth PM | North star metric, funnel analysis, experiment roadmap, retention strategy |

### Marketing (10 agents)

| Agent | Produces |
|-------|---------|
| Brand Strategist | Positioning, tone of voice, visual identity system, brand architecture |
| Copywriter | Campaign messaging, landing page copy, ad copy, CTA variants |
| SEO Specialist | Keyword strategy, content architecture, technical SEO requirements |
| Social Media Manager | Platform strategy, content calendar, engagement model, community playbook |
| Email Marketing Specialist | Lifecycle sequences, deliverability setup, segmentation, compliance |
| Paid Ads Specialist | Channel mix, campaign structure, audience strategy, conversion tracking |
| PR Specialist | Media strategy, press materials, launch plan, crisis preparedness |
| Community Manager | Platform strategy, member journey, engagement programmes, moderation framework |
| Video Content Creator | Video strategy, scripts, production briefs, distribution plan |
| Influencer Marketing Specialist | Creator strategy, campaign brief, deal structure, FTC compliance |

### Business & Strategy (8 agents)

| Agent | Produces |
|-------|---------|
| Market Analyst | TAM/SAM/SOM, market segments, growth signals, competitive landscape |
| Financial Modeler | Revenue projections, unit economics, cost model, 3-scenario analysis |
| Pricing Strategist | Tier structure, price anchoring, willingness-to-pay analysis |
| Competitive Analyst | Named competitor profiles, feature matrix, positioning gaps |
| Business Development Strategist | Partnership thesis, opportunity matrix, deal structure template |
| Partnership Analyst | Deal evaluation, financial model, due diligence checklist, partner KPIs |
| Strategy Consultant | Strategic options analysis, recommendation with rationale, implementation sequence |
| Investor Relations Specialist | Investor narrative, pitch deck outline, due diligence data room, anticipated Q&A |

### Data & Analytics (6 agents)

| Agent | Produces |
|-------|---------|
| Data Engineer | Pipeline architecture, schema design, transformation logic, data quality rules |
| Analytics Specialist | Metrics framework, KPI definitions, tracking plan, dashboard wireframe |
| ML Specialist | Model selection, feature engineering, evaluation framework, MLOps design |
| Visualisation Designer | Chart specifications, dashboard layout, colour encoding, accessibility |
| Data Scientist | Statistical analysis, experiment design, predictive model plan, limitations |
| BI Analyst | Dashboard inventory, semantic layer, metric definitions, access control |

### Writing & Docs (6 agents)

| Agent | Produces |
|-------|---------|
| Technical Writer | Developer docs, API reference, README template, code comment standards |
| Copywriter | Headlines, CTAs, landing page copy, email content |
| Editor | Tracked edits to another agent's written output with reasons |
| Docs Specialist | User guides, onboarding docs, help articles, release notes |
| Grant Writer | Funder analysis, proposal structure, logic model, evaluation plan |
| Speech Writer | Central idea, speech structure, full script with delivery notes |
| Scriptwriter | Platform-specific video/audio scripts with visual direction |

### Legal & Compliance (6 agents)

| Agent | Produces |
|-------|---------|
| Contract Analyst | Clause-by-clause review, redlines, risk flags, missing clause identification |
| Compliance Specialist | Regulatory checklist, gap analysis, prioritised remediation steps |
| IP Analyst | Freedom-to-operate assessment, open source licence analysis, IP protection strategy |
| Privacy Officer | Privacy impact assessment, data inventory, GDPR/CCPA requirements, consent design |
| Employment Law Specialist | Workforce compliance findings, classification analysis, policy gaps |
| Corporate Governance Specialist | Board structure assessment, compliance gaps, corporate records review |

### HR & People (6 agents)

| Agent | Produces |
|-------|---------|
| HR Business Partner | Workforce plan, org design, people programme priorities, performance framework |
| Recruiter | Role success profile, sourcing strategy, interview scorecards, offer strategy |
| L&D Specialist | Capability gap analysis, learning interventions, career framework, onboarding design |
| Culture Analyst | Culture assessment, engagement data, root causes, culture-change interventions |
| Compensation Analyst | Pay band structure, benchmarking sources, equity programme, pay equity findings |
| DEI Specialist | Representation baseline, systemic interventions, measurement framework |

### Operations, Finance & Sales (14 agents)

| Agent | Produces |
|-------|---------|
| Project Coordinator | Project plan, milestones, dependencies, RACI matrix |
| Risk Analyst | Risk register with likelihood × impact scoring, mitigations, early warning indicators |
| Process Designer | Process flows, SOPs, decision trees, handoff definitions |
| Financial Analyst | Variance analysis, unit economics, cash position, forecast update |
| Accountant | Chart of accounts, month-end close process, internal controls, compliance calendar |
| Tax Specialist | Tax obligations by type, exposure analysis, planning opportunities, compliance calendar |
| Customer Support Specialist | Support model, SLA framework, escalation tiers, knowledge base structure |
| Customer Success Manager | Coverage model, health score, playbooks, success plan template |
| Onboarding Specialist | Activation milestone, onboarding funnel, in-app flow, email sequence |
| Sales Strategist | ICP definition, sales process, quota design, funnel model |
| SDR | Prospecting target profile, outreach sequences, email copy, qualification criteria |
| Sales Enablement Specialist | Onboarding programme, content library, battlecards, pitch certification |
| RevOps Analyst | GTM systems architecture, CRM data model, pipeline process, attribution model |
| Procurement Specialist | Spend analysis, sourcing strategy, RFP framework, negotiation positions |

---

## Quality scoring

The Quality Reviewer scores every output before it can proceed to the Synthesizer.

| Dimension | Weight | What it checks |
|-----------|--------|----------------|
| Completeness | 25% | Did the agent fully address their brief? |
| Correctness | 30% | Is it technically accurate? No errors? |
| Consistency | 20% | Does it align with other approved outputs? |
| Clarity | 15% | Is it well-structured and readable? |
| Constraint adherence | 10% | Does it follow mission.md constraints? |

**Score = weighted average × 10. Threshold: 8.0.**

Below 8.0 → the agent receives a rejection message with scores per dimension and specific feedback. The agent revises and resubmits. Maximum 3 revision rounds. After round 3, the Conductor is escalated.

This is what prevents the common multi-agent failure mode: averaging down to mediocrity. With a threshold and specific feedback, the mesh converges toward quality.

---

## The message bus

All inter-agent communication uses structured envelopes in `.mesh/messages/`. No agent talks to another directly — everything goes through typed messages.

```markdown
---
from: full-stack-dev
to: quality-reviewer
type: output
score:
ref:
timestamp: 2026-03-27T14:23:11Z
---

[agent output body]
```

Message types: `request` · `response` · `output` · `review` · `reject` · `approve` · `revision` · `escalate` · `halt`

The bus is fully inspectable. After any run, read `.mesh/messages/` to see exactly what happened.

---

## Workspace layout

`.mesh/` is created fresh each run and deleted (or archived) when done.

```
.mesh/
├── mission.md              ← Conductor writes: task, constraints, team
├── team.json               ← which agents are active for this run
├── messages/               ← the message bus
│   └── [ts]-[from]-[to]-[type].md
├── outputs/                ← versioned agent deliverables
│   ├── architect/
│   │   └── v1.md
│   ├── full-stack-dev/
│   │   ├── v1.md           ← rejected
│   │   └── v2.md           ← approved
│   └── [agent-id]/
│       └── v1.md
├── quality/
│   └── scores.md           ← running quality ledger
└── final/
    └── output.md           ← synthesized result — this is your deliverable
```

`.mesh-archive/` is where halted runs are stored. Each archived run gets its own timestamped subdirectory.

---

## Project structure

```
claude-agent-mesh/
├── README.md
├── install.sh                      ← project installer
├── plugin.json                     ← Claude Code marketplace manifest
├── LICENSE
├── CONTRIBUTING.md
├── .gitignore
│
├── .claude/
│   └── commands/                   ← slash commands (copied to your project)
│       ├── mesh.md
│       ├── mesh-status.md
│       ├── mesh-halt.md
│       ├── mesh-roles.md
│       └── mesh-review.md
│
├── core/
│   ├── conductor/AGENT.md          ← task routing, team assembly
│   ├── quality-reviewer/AGENT.md   ← scoring and rejection
│   └── synthesizer/AGENT.md        ← output merging
│
├── agents/
│   ├── engineering/
│   │   ├── architect/AGENT.md
│   │   ├── full-stack-dev/AGENT.md
│   │   ├── database-designer/AGENT.md
│   │   ├── devops-engineer/AGENT.md
│   │   ├── security-analyst/AGENT.md
│   │   ├── performance-engineer/AGENT.md
│   │   ├── test-engineer/AGENT.md
│   │   └── api-designer/AGENT.md
│   ├── product/
│   │   ├── product-strategist/AGENT.md
│   │   ├── ux-designer/AGENT.md
│   │   ├── user-researcher/AGENT.md
│   │   ├── content-strategist/AGENT.md
│   │   └── accessibility-analyst/AGENT.md
│   ├── business/
│   │   ├── market-analyst/AGENT.md
│   │   ├── financial-modeler/AGENT.md
│   │   ├── pricing-strategist/AGENT.md
│   │   └── competitive-analyst/AGENT.md
│   ├── data/
│   │   ├── data-engineer/AGENT.md
│   │   ├── analytics-specialist/AGENT.md
│   │   ├── ml-specialist/AGENT.md
│   │   └── viz-designer/AGENT.md
│   ├── writing/
│   │   ├── technical-writer/AGENT.md
│   │   ├── copywriter/AGENT.md
│   │   ├── editor/AGENT.md
│   │   └── docs-specialist/AGENT.md
│   ├── legal/
│   │   ├── contract-analyst/AGENT.md
│   │   ├── compliance-specialist/AGENT.md
│   │   ├── ip-analyst/AGENT.md
│   │   └── privacy-officer/AGENT.md
│   └── ops/
│       ├── project-coordinator/AGENT.md
│       ├── risk-analyst/AGENT.md
│       └── process-designer/AGENT.md
│
├── protocol/
│   ├── PROTOCOL.md                 ← message bus spec, envelope format
│   └── QUALITY-RUBRIC.md           ← 5-dimension scoring system
│
└── docs/
    ├── setup.md                    ← detailed setup guide (this file expanded)
    ├── how-it-works.md             ← architecture deep dive
    └── writing-agents.md           ← guide to adding new agents
```

---

## Token efficiency

The mesh keeps your main Claude Code session lean:

- **Main session** only reads `mission.md` + `final/output.md` — never the full message bus
- **Each agent** gets its own isolated context window (200K) — no shared state contamination
- **Message bus files** are capped by type (requests ≤ 200 tokens, outputs ≤ 1,200 tokens)
- **Quality scores** are numbers — the ledger never grows large
- **`.mesh/` is deleted** after the run — no stale context accumulates across runs

---

## Troubleshooting

### "No such file or directory" when running install.sh on Windows

You're in Command Prompt or PowerShell, not bash. Open Git Bash instead:
- Right-click your project folder → "Git Bash Here"
- Then run the install command

### Claude Code doesn't recognise /mesh after install

The commands are installed at the **project level** (`.claude/commands/`), not globally. Make sure you opened Claude Code from inside the project directory where you ran `install.sh`.

Check the commands are there:
```bash
ls .claude/commands/
# Should show: mesh.md mesh-status.md mesh-halt.md mesh-roles.md mesh-review.md
```

### The mesh seems to run but produces no output

Run `/mesh-status` to see what's happening. If the run completed but `.mesh/final/output.md` is empty or missing, the Synthesizer may not have been triggered. Check `.mesh/messages/` for a `halt` or `escalate` message.

### An agent keeps getting rejected

Run `/mesh-review .mesh/outputs/[agent-id]/v1.md` to see the detailed score breakdown. The rejection feedback in `.mesh/messages/` will also show which dimensions failed and why.

### .mesh/ is cluttering my project

`.mesh/` is added to `.gitignore` by the installer. If it's persisting between runs, check that `.mesh/` appears in your `.gitignore`. The mesh deletes it after a clean run; use `/mesh-halt` to archive it manually.

---

## Deep dives

- [How it works](docs/how-it-works.md) — architecture, run lifecycle, design decisions
- [Writing agents](docs/writing-agents.md) — add your own specialist to the mesh
- [Setup guide](docs/setup.md) — extended installation and configuration reference
- [Protocol spec](protocol/PROTOCOL.md) — message bus envelope format and type definitions
- [Quality rubric](protocol/QUALITY-RUBRIC.md) — how the 5-dimension scoring works

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The short version:

1. Add a new agent: `agents/[domain]/[role]/AGENT.md`
2. Match the format and quality of `agents/engineering/architect/AGENT.md`
3. Run `python .github/scripts/validate_agents.py`
4. Open a PR

---

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">
<sub>Standalone · No dependency on other frameworks · Works in any Claude Code project · 28 specialists · Quality threshold enforced</sub>
</div>
