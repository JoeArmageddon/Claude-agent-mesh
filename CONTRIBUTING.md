# Contributing to claude-agent-mesh

## What you can contribute

- **New agents** — add a specialist to any domain
- **Improved agent quality** — sharpen an existing AGENT.md
- **Bug fixes** — fix incorrect protocol behaviour or formatting errors
- **Documentation** — improve clarity in docs/ or protocol/

## Adding a new agent

1. Create a directory: `agents/[domain]/[agent-name]/`
2. Write `AGENT.md` following the template in `SESSION_HANDOFF.md`
3. Match the depth and quality of `agents/engineering/architect/AGENT.md`
4. All agents are Tier 4 specialists — token budgets are fixed (see handoff)
5. Run CI validation: `python .github/scripts/validate_agents.py`

The required structure:
```
---
agent: kebab-case-id
role: One sentence — what this agent produces
token-budget: reads [what] ≤[N]K · writes ≤1.2K
---

# Title

## Identity
## Expertise
## Output format (≤ 1,200 tokens)
## Hard rules
```

Every output must end with `## Status: [complete / blocked — reason]`

## Improving an existing agent

- Keep changes focused — one improvement per PR
- If you're changing the output format, update the CI validation script if needed
- Explain what was wrong and why your change improves it

## Pull request checklist

- [ ] CI passes (frontmatter validation + section checks)
- [ ] Agent follows token budget requirements
- [ ] Hard rules are actionable (each would cause a real failure if violated)
- [ ] Identity section is first-person and strong-voiced, not a job description
- [ ] Expertise section lists specific tools/frameworks, not generic capabilities

## What not to contribute

- Changes to `protocol/PROTOCOL.md` or `core/` agents without an issue discussion first — these are load-bearing
- Agents that duplicate an existing agent's responsibility
- Non-AGENT.md files in agent directories

## Reporting issues

Use GitHub Issues. Include:
- The agent or file involved
- What you expected vs what happened
- A minimal example if applicable
