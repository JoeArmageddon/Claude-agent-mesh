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
| Dormancy | All agents always loaded | Only selected agents activate — rest stay dormant |
| Inter-agent comms | None or ad-hoc | Structured request/response via message bus with collaboration clusters |

---

## See it in action

```
You: /mesh build a rate-limited API for user authentication with JWT and refresh tokens

Conductor:
  → Task analysed
  → Team assembled: Architect, Full-Stack Dev, Database Designer,
                    API Designer, Security Analyst, Test Engineer
  → Mission written to .mesh/mission.md
  → 6 agents activated · 74 agents dormant

[Agents work, posting outputs to .mesh/outputs/ and messages to .mesh/messages/]
[Architect requests DB schema from Database Designer before finalising → response received]

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
/mesh write a Series A pitch deck for our fintech product
/mesh create a 90-day go-to-market plan for product launch
/mesh build an HR onboarding programme for a remote team
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
| `market [product]` | Brand Strategist + Copywriter + SEO Specialist + Social Media Manager |
| `hire [role]` | Recruiter + Compensation Analyst + L&D Specialist |
| `comply [regulation]` | Compliance Specialist + Privacy Officer + Risk Analyst |

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

Shows a table of Agent | Role | Domain for all 83 agents (3 core + 80 domain specialists).

---

### `/mesh-review [path]`

Run the Quality Reviewer's scoring rubric on any file.

```
/mesh-review .mesh/outputs/architect/v1.md
/mesh-review docs/my-spec.md
```

Returns the full 5-dimension score breakdown and pass/fail verdict.

---

### Individual agent skills

Every agent can also be invoked solo — without running a full mesh:

```
/architect design a microservices system for an e-commerce platform
/ux sketch the checkout flow for a mobile app
/brand define the positioning for a B2B SaaS targeting CTOs
/seo build a keyword strategy for a developer tools blog
/sdr write a cold outreach sequence for enterprise prospects
```

Each skill activates exactly one agent, gives it your prompt, and returns its output. Useful for focused single-agent work.

---

## Agent roster

**83 agents total** — 3 core orchestrators + 80 domain specialists across 9 domains. Only the agents needed for your task are activated; all others remain dormant.

---

### Core agents (always present in every run)

| Agent | Skill | Role |
|-------|-------|------|
| Conductor | *(auto)* | Reads the task, infers the team, writes `mission.md`, declares communication channels, coordinates the run |
| Quality Reviewer | `/quality-review` | Scores every output 1–10 on 5 dimensions, rejects below 8.0 with specific per-dimension feedback |
| Synthesizer | `/synthesize` | Merges all approved outputs into a single coherent document in one voice |

---

### Engineering (14 agents)

| Agent | Skill | Produces |
|-------|-------|---------|
| Architect | `/architect` | System design, component breakdown, data flow diagrams, integration contracts, technology selection rationale |
| Full-Stack Developer | `/full-stack` | Implementation code across frontend and backend layers, following the Architect's blueprint |
| Frontend Engineer | `/frontend` | Component architecture, state management, Web Vitals optimisation, accessibility implementation |
| Backend Engineer | `/backend` | Service layer, business logic, input validation, database access patterns, API implementation |
| Mobile Engineer | `/mobile` | iOS/Android app architecture, offline-first design, platform conventions, app store requirements |
| Database Designer | `/database` | Schema design, normalisation decisions, indexes, migration plans, query optimisation |
| DevOps Engineer | `/devops` | CI/CD pipelines, infrastructure-as-code, deployment strategy, environment management |
| Site Reliability Engineer | `/sre` | SLOs/SLAs/error budgets, observability stack, alerting strategy, incident runbooks |
| ML Engineer | `/ml-engineer` | Training pipelines, model serving infrastructure, MLOps, feature stores, drift monitoring |
| Infrastructure Engineer | `/infra` | Cloud architecture, networking, IAM, cost estimate, multi-region strategy |
| Security Analyst | `/security` | Threat model, OWASP/CVE analysis, vulnerability assessment, remediation recommendations |
| Performance Engineer | `/performance` | Load test plan, bottleneck analysis, profiling strategy, optimisation recommendations |
| Test Engineer | `/test-engineer` | Test strategy, test cases across unit/integration/e2e, coverage plan, CI integration |
| API Designer | `/api-designer` | OpenAPI 3.0 spec, endpoint design, auth requirements, error formats, versioning strategy |

**Natural collaborations:** Architect ↔ API Designer ↔ Backend Engineer ↔ Database Designer ↔ Security Analyst ↔ DevOps Engineer ↔ Frontend Engineer ↔ Test Engineer

---

### Product (9 agents)

| Agent | Skill | Produces |
|-------|-------|---------|
| Product Strategist | `/product-strategist` | Feature spec, user stories with acceptance criteria, success metrics, prioritisation rationale |
| Product Manager | `/product-manager` | Prioritised backlog, milestone plan, dependency map, definition of done, stakeholder considerations |
| UX Designer | `/ux` | User flows, screen outlines, interaction patterns, navigation model, usability heuristics |
| UI Designer | `/ui` | Design tokens, component states, visual hierarchy, spacing system, handoff spec |
| User Researcher | `/user-researcher` | Personas, jobs-to-be-done, behavioural insights, research methodology, recruitment criteria |
| Content Strategist | `/content-strategist` | Content architecture, messaging hierarchy, tone guidelines, content lifecycle |
| Accessibility Analyst | `/accessibility` | WCAG 2.1 AA checklist, ARIA patterns, keyboard nav spec, screen reader compatibility |
| Localisation Specialist | `/localisation` | i18n architecture, locale support plan, translation workflow, RTL considerations |
| Growth PM | `/growth-pm` | North star metric, funnel analysis, experiment roadmap, activation and retention strategy |

**Natural collaborations:** Product Strategist ↔ UX Designer ↔ UI Designer ↔ User Researcher ↔ Content Strategist ↔ Accessibility Analyst

---

### Marketing (10 agents)

| Agent | Skill | Produces |
|-------|-------|---------|
| Brand Strategist | `/brand` | Brand positioning, tone of voice, visual identity system, naming conventions, brand architecture |
| Copywriter | `/marketing-copywriter` | Campaign messaging, landing page copy, ad copy, taglines, CTA variants |
| SEO Specialist | `/seo` | Keyword strategy, content architecture, technical SEO requirements, link-building approach |
| Social Media Manager | `/social-media` | Platform strategy, content calendar, engagement model, community playbook, analytics framework |
| Email Marketing Specialist | `/email-marketing` | Lifecycle sequences, deliverability setup, segmentation model, A/B testing plan, compliance |
| Paid Ads Specialist | `/paid-ads` | Channel mix, campaign structure, audience strategy, creative brief, conversion tracking |
| PR Specialist | `/pr` | Media strategy, press materials, launch plan, influencer outreach, crisis preparedness |
| Community Manager | `/community` | Platform strategy, member journey, engagement programmes, moderation framework, growth tactics |
| Video Content Creator | `/video` | Video strategy, scripts, production briefs, distribution plan, repurposing strategy |
| Influencer Marketing Specialist | `/influencer` | Creator strategy, campaign brief, deal structure, performance metrics, FTC compliance |

**Natural collaborations:** Brand Strategist ↔ Copywriter ↔ SEO Specialist ↔ Social Media Manager ↔ Email Marketing Specialist ↔ Paid Ads Specialist

---

### Business & Strategy (8 agents)

| Agent | Skill | Produces |
|-------|-------|---------|
| Market Analyst | `/market-analyst` | TAM/SAM/SOM, market segments, growth signals, demand drivers, competitive landscape |
| Financial Modeler | `/financial-model` | Revenue projections, unit economics, cost model, 3-scenario analysis, key assumptions |
| Pricing Strategist | `/pricing` | Tier structure, price anchoring, willingness-to-pay analysis, packaging options |
| Competitive Analyst | `/competitive` | Named competitor profiles, feature matrix, positioning gaps, SWOT, differentiation opportunities |
| Business Development Strategist | `/biz-dev` | Partnership thesis, opportunity matrix, outreach strategy, deal structure template |
| Partnership Analyst | `/partnerships` | Deal evaluation framework, financial model, due diligence checklist, partner KPIs |
| Strategy Consultant | `/strategy` | Strategic options analysis, recommendation with rationale, implementation sequence, risk trade-offs |
| Investor Relations Specialist | `/investor-relations` | Investor narrative, pitch deck outline, due diligence data room structure, anticipated Q&A |

**Natural collaborations:** Market Analyst ↔ Competitive Analyst ↔ Financial Modeler ↔ Pricing Strategist ↔ Strategy Consultant

---

### Data & Analytics (6 agents)

| Agent | Skill | Produces |
|-------|-------|---------|
| Data Engineer | `/data-engineer` | Pipeline architecture, schema design, transformation logic, data quality rules, orchestration plan |
| Analytics Specialist | `/analytics` | Metrics framework, KPI definitions, tracking plan, event taxonomy, dashboard wireframe |
| ML Specialist | `/ml-specialist` | Model selection rationale, feature engineering strategy, evaluation framework, MLOps design |
| Visualisation Designer | `/dataviz` | Chart specifications, dashboard layout, colour encoding, accessibility, interaction patterns |
| Data Scientist | `/data-scientist` | Statistical analysis plan, experiment design, predictive model outline, assumptions and limitations |
| BI Analyst | `/bi` | Dashboard inventory, semantic layer design, metric definitions, access control, refresh schedule |

**Natural collaborations:** Data Engineer ↔ Analytics Specialist ↔ Data Scientist ↔ ML Specialist ↔ BI Analyst ↔ Visualisation Designer

---

### Writing & Docs (6 agents)

| Agent | Skill | Produces |
|-------|-------|---------|
| Technical Writer | `/tech-writer` | Developer docs, API reference, README templates, code comment standards, doc-site structure |
| Copywriter | `/copywriter` | Headlines, CTAs, landing page copy, email body copy, microcopy |
| Editor | `/editor` | Tracked edits to another agent's written output with per-change rationale |
| Docs Specialist | `/docs` | User guides, onboarding docs, help articles, release notes, knowledge base structure |
| Grant Writer | `/grant-writer` | Funder landscape analysis, proposal structure, logic model, budget narrative, evaluation plan |
| Speech Writer | `/speech-writer` | Central thesis, speech structure, full script with delivery notes and emphasis cues |
| Scriptwriter | `/scriptwriter` | Platform-specific video/audio scripts with visual direction, timing cues, and B-roll notes |

**Natural collaborations:** Technical Writer ↔ Docs Specialist ↔ Editor ↔ Copywriter

---

### Legal & Compliance (6 agents)

| Agent | Skill | Produces |
|-------|-------|---------|
| Contract Analyst | `/contracts` | Clause-by-clause review, redlines, risk flags, missing clause identification, negotiation notes |
| Compliance Specialist | `/compliance` | Regulatory checklist, gap analysis, prioritised remediation steps, compliance calendar |
| IP Analyst | `/ip` | Freedom-to-operate assessment, open source licence analysis, IP protection strategy, filing priorities |
| Privacy Officer | `/privacy` | Privacy impact assessment, data inventory, GDPR/CCPA requirements, consent flow design |
| Employment Law Specialist | `/employment-law` | Workforce compliance findings, worker classification analysis, policy gaps, jurisdiction notes |
| Corporate Governance Specialist | `/governance` | Board structure assessment, compliance gaps, fiduciary duty analysis, corporate records review |

**Natural collaborations:** Compliance Specialist ↔ Privacy Officer ↔ Contract Analyst ↔ IP Analyst ↔ Risk Analyst

---

### HR & People (6 agents)

| Agent | Skill | Produces |
|-------|-------|---------|
| HR Business Partner | `/hrbp` | Workforce plan, org design options, people programme priorities, performance framework |
| Recruiter | `/recruiter` | Role success profile, sourcing strategy, interview scorecards, offer band, candidate experience plan |
| L&D Specialist | `/learning-dev` | Capability gap analysis, learning interventions, career framework, onboarding programme design |
| Culture Analyst | `/culture` | Culture assessment, engagement data interpretation, root causes, culture-change interventions |
| Compensation Analyst | `/compensation` | Pay band structure, benchmarking sources, equity programme design, pay equity audit findings |
| DEI Specialist | `/dei` | Representation baseline, pipeline analysis, systemic interventions, measurement framework |

**Natural collaborations:** HR Business Partner ↔ Recruiter ↔ L&D Specialist ↔ Compensation Analyst ↔ DEI Specialist ↔ Culture Analyst

---

### Operations, Finance & Sales (15 agents)

| Agent | Skill | Produces |
|-------|-------|---------|
| Project Coordinator | `/project` | Project plan, milestones, dependencies, RACI matrix, risk log |
| Risk Analyst | `/risk` | Risk register with likelihood × impact scoring, mitigations, early warning indicators |
| Process Designer | `/process` | Process flows, SOPs, decision trees, handoff definitions, automation candidates |
| Financial Analyst | `/financial-analyst` | Variance analysis, unit economics, cash position, forecast update, scenario sensitivity |
| Accountant | `/accountant` | Chart of accounts, month-end close process, internal controls, compliance calendar |
| Tax Specialist | `/tax` | Tax obligations by jurisdiction and type, exposure analysis, planning opportunities |
| Customer Support Specialist | `/support` | Support model design, SLA framework, escalation tiers, knowledge base structure, CSAT approach |
| Customer Success Manager | `/csm` | Coverage model, health score framework, risk and expansion playbooks, success plan template |
| Onboarding Specialist | `/onboarding` | Activation milestones, onboarding funnel, in-app guidance flow, email nurture sequence |
| Sales Strategist | `/sales` | ICP definition, sales process design, quota model, funnel stages, win/loss framework |
| SDR | `/sdr` | Prospecting target profile, outreach sequences, email copy, call script, qualification criteria |
| Sales Enablement Specialist | `/sales-enablement` | Onboarding programme for new reps, content library structure, battlecards, pitch certification |
| RevOps Analyst | `/revops` | GTM systems architecture, CRM data model, pipeline process, attribution model, reporting stack |
| Procurement Specialist | `/procurement` | Spend analysis, vendor sourcing strategy, RFP framework, evaluation criteria, negotiation positions |
| Analytics Specialist | `/analytics` | GTM metrics, funnel reporting, revenue attribution, pipeline analytics |

**Natural collaborations:** Sales Strategist ↔ SDR ↔ Sales Enablement Specialist ↔ RevOps Analyst · Customer Success Manager ↔ Onboarding Specialist ↔ Customer Support Specialist · Financial Analyst ↔ Accountant ↔ Tax Specialist

---

## Inter-agent communication

Agents with related work communicate before producing output. The Conductor declares the active communication channels in `mission.md` for each run.

```markdown
# Communication channels (this run)

- Architect → Database Designer: request schema before finalising blueprint
- Security Analyst → Backend Engineer: share threat model before implementation
- UX Designer → Frontend Engineer: share interaction spec before build
```

Agents send typed `request` messages and wait for `response` before finalising their work. This prevents the most common multi-agent failure: agents producing outputs that silently contradict each other.

**14 collaboration clusters** cover all 80 domain agents:

| Cluster | Agents |
|---------|--------|
| Build | Architect, Full-Stack Dev, Backend Engineer, Frontend Engineer, Mobile Engineer, Database Designer, DevOps Engineer, SRE, ML Engineer, Infrastructure Engineer |
| Product | Product Strategist, Product Manager, UX Designer, UI Designer, User Researcher, Content Strategist, Accessibility Analyst, Localisation Specialist, Growth PM |
| Data | Data Engineer, Analytics Specialist, ML Specialist, Data Scientist, BI Analyst, Visualisation Designer |
| Marketing | Brand Strategist, Copywriter (marketing), SEO Specialist, Social Media Manager, Email Marketing, Paid Ads, PR Specialist, Community Manager, Video Creator, Influencer Marketing |
| Legal | Contract Analyst, Compliance Specialist, IP Analyst, Privacy Officer, Employment Law, Corporate Governance |
| HR | HR Business Partner, Recruiter, L&D Specialist, Culture Analyst, Compensation Analyst, DEI Specialist |
| Sales | Sales Strategist, SDR, Sales Enablement, RevOps Analyst |
| Customer | Customer Support, Customer Success Manager, Onboarding Specialist |
| Finance | Financial Analyst, Accountant, Tax Specialist |
| Strategy | Market Analyst, Competitive Analyst, Financial Modeler, Pricing Strategist, Business Development, Partnership Analyst, Strategy Consultant, Investor Relations |
| Ops | Project Coordinator, Risk Analyst, Process Designer, Procurement Specialist |
| Writing | Technical Writer, Copywriter (writing), Editor, Docs Specialist, Grant Writer, Speech Writer, Scriptwriter |
| Security/Privacy | Security Analyst, Compliance Specialist, Privacy Officer |
| Platform | Performance Engineer, Test Engineer, API Designer |

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
├── mission.md              ← Conductor writes: task, constraints, team, communication channels
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
├── install.sh                          ← project installer
├── plugin.json                         ← Claude Code marketplace manifest
├── LICENSE
├── CONTRIBUTING.md
├── .gitignore
│
├── .claude/
│   └── commands/                       ← slash commands (copied to your project by install.sh)
│       ├── mesh.md                     ← main orchestration command
│       ├── mesh-status.md
│       ├── mesh-halt.md
│       ├── mesh-roles.md
│       ├── mesh-review.md
│       ├── quality-review.md           ← core agent skill
│       ├── synthesize.md               ← core agent skill
│       └── [80 domain agent skills]    ← one per specialist agent
│
├── core/
│   ├── conductor/AGENT.md              ← task routing, team assembly, communication map
│   ├── quality-reviewer/AGENT.md       ← scoring and rejection
│   └── synthesizer/AGENT.md            ← output merging
│
├── agents/
│   ├── engineering/   (14 agents)
│   ├── product/       (9 agents)
│   ├── marketing/     (10 agents)
│   ├── business/      (8 agents)
│   ├── data/          (6 agents)
│   ├── writing/       (6 agents)
│   ├── legal/         (6 agents)
│   ├── hr/            (6 agents)
│   └── ops/           (15 agents)
│
├── protocol/
│   ├── PROTOCOL.md                     ← message bus spec, envelope format, collaboration clusters
│   └── QUALITY-RUBRIC.md               ← 5-dimension scoring system
│
└── docs/
    ├── setup.md
    ├── how-it-works.md
    └── writing-agents.md
```

---

## Token efficiency

The mesh keeps your main Claude Code session lean:

- **Main session** only reads `mission.md` + `final/output.md` — never the full message bus
- **Each agent** gets its own isolated context window (200K) — no shared state contamination
- **Dormant agents** are never loaded — only activated agents consume tokens
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
# Plus quality-review.md, synthesize.md, and ~80 agent skill files
```

### The mesh seems to run but produces no output

Run `/mesh-status` to see what's happening. If the run completed but `.mesh/final/output.md` is empty or missing, the Synthesizer may not have been triggered. Check `.mesh/messages/` for a `halt` or `escalate` message.

### An agent keeps getting rejected

Run `/mesh-review .mesh/outputs/[agent-id]/v1.md` to see the detailed score breakdown. The rejection feedback in `.mesh/messages/` will also show which dimensions failed and why.

### .mesh/ is cluttering my project

`.mesh/` is added to `.gitignore` by the installer. If it's persisting between runs, check that `.mesh/` appears in your `.gitignore`. The mesh deletes it after a clean run; use `/mesh-halt` to archive it manually.

### I want to use just one agent without running the full mesh

Use the agent's individual skill command directly:
```
/architect design a microservices backend for a logistics platform
/ux map the checkout flow for a mobile e-commerce app
/brand define positioning for a B2B developer tools company
```

Each skill activates exactly one agent in isolation.

---

## Deep dives

- [How it works](docs/how-it-works.md) — architecture, run lifecycle, design decisions
- [Writing agents](docs/writing-agents.md) — add your own specialist to the mesh
- [Setup guide](docs/setup.md) — extended installation and configuration reference
- [Protocol spec](protocol/PROTOCOL.md) — message bus envelope format, type definitions, collaboration clusters
- [Quality rubric](protocol/QUALITY-RUBRIC.md) — how the 5-dimension scoring works

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The short version:

1. Add a new agent: `agents/[domain]/[role]/AGENT.md`
2. Match the format and quality of `agents/engineering/architect/AGENT.md`
3. Open a PR

---

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">
<sub>Standalone · No dependencies · Works in any Claude Code project · 83 agents across 9 domains · Quality threshold enforced · Inter-agent communication built in</sub>
</div>
