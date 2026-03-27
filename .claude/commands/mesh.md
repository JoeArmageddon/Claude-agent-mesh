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
