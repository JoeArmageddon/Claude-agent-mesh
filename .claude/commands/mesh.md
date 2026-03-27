# /mesh

Deploy a dynamic agent mesh for a complex task.

Read `core/conductor/AGENT.md` and follow it exactly.

$ARGUMENTS: the task description. If empty, ask: "What do you need the mesh to work on? Be as specific as possible — team size and quality both depend on it."

## How it works

1. The **Conductor** analyses the task and selects 2–8 agents from the 80-agent roster
2. **Only selected agents are activated** via their individual skill commands — all others stay dormant
3. Each activated agent reads its brief and produces output to `.mesh/outputs/[agent]/v1.md`
4. The **Quality Reviewer** scores every output (1–10). Anything below 8.0 is rejected with feedback
5. Agents revise until approved (max 3 rounds)
6. The **Synthesizer** merges all approved outputs into `.mesh/final/output.md`

## Steps

1. Parse $ARGUMENTS as the task
2. Run the Conductor protocol from `core/conductor/AGENT.md` — Steps 1 through 8
3. Present `.mesh/final/output.md` to the user when complete
4. Output the mesh run summary:
   ```
   Mesh complete.
   Team: [agent list with their skill commands]
   Dormant: [count of agents not activated]
   Revisions: [total across all agents]
   Avg quality: [X]/10
   Output: .mesh/final/output.md
   ```

## Quick patterns

| Keyword | Agents activated (skills invoked) |
|---------|----------------------------------|
| `build [feature]` | `/architect` `/full-stack` `/database` `/security` `/test-engineer` |
| `api [name]` | `/architect` `/api-designer` `/backend` `/security` `/test-engineer` |
| `frontend [feature]` | `/architect` `/frontend` `/ux` `/ui` `/accessibility` |
| `mobile [app]` | `/architect` `/mobile` `/ux` `/ui` `/security` |
| `launch [thing]` | `/product-strategist` `/content-strategist` `/copywriter` `/tech-writer` |
| `market [thing]` | `/market-analyst` `/competitive` `/pricing` `/financial-model` |
| `design [feature]` | `/product-strategist` `/ux` `/ui` `/user-researcher` `/accessibility` |
| `data [pipeline]` | `/data-engineer` `/analytics` `/dataviz` `/data-scientist` |
| `ml [model]` | `/ml-engineer` `/ml-specialist` `/data-engineer` `/data-scientist` |
| `audit [scope]` | `/security` `/compliance` `/privacy` `/risk` |
| `hire [role]` | `/hrbp` `/recruiter` `/compensation` `/dei` |
| `grow [metric]` | `/growth-pm` `/analytics` `/seo` `/email-marketing` |
| `fund [round]` | `/investor-relations` `/financial-model` `/strategy` `/competitive` |
| `sell [product]` | `/sales` `/sdr` `/sales-enablement` `/revops` |
| `plan [project]` | `/project` `/risk` `/process` `/financial-analyst` |

## Dormancy guarantee

Agents NOT selected by the Conductor are **never invoked**. Their skill files exist but are never called. Only the Conductor, Quality Reviewer, Synthesizer, and the selected domain agents ever activate during a run.

Examples:
```
/mesh build a rate-limited JWT auth endpoint with refresh tokens
/mesh design the onboarding flow for a B2B SaaS product
/mesh audit our infrastructure for SOC 2 Type II compliance
/mesh build a hiring process for a senior backend engineer
/mesh create a go-to-market strategy for our Series A launch
```
