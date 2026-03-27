# How claude-agent-mesh works

A deep dive into the architecture, mechanics, and design decisions.

---

## The core problem

Most "multi-agent" setups are just prompt chaining with extra steps. Agent A outputs something, Agent B reads it. There's no quality control, no feedback loop, no way for agents to communicate mid-run. The result is that you get the quality floor of all agents, not the ceiling.

claude-agent-mesh is built around a different mechanic: every output is scored before it goes anywhere. Below the threshold, it goes back to the agent with specific feedback. Only approved outputs reach the Synthesizer.

---

## The five components

### 1. The Conductor

The Conductor is not a manager — it is a router. When you run `/mesh [task]`, the Conductor reads your task description and infers which agents to assemble. It uses a signal routing table: keywords and task patterns map to agent combinations.

The Conductor also writes `mission.md` — a shared document that every agent reads. It contains the task, constraints, and any specific requirements the Conductor extracts from your description.

**What the Conductor does NOT do:** it does not do any domain work. It coordinates, it does not contribute.

### 2. Domain Agents

These are the specialists: Architect, Full-Stack Dev, API Designer, UX Designer, and so on. Each lives in `agents/[domain]/[agent-id]/AGENT.md`. Each has:

- A defined output format (≤ 1,200 tokens)
- A token budget for reading source material
- Hard rules that define what it will never do
- A protocol for when it needs to talk to another agent

Agents work in their own Task context, which means each gets a full 200K context window. They never share a context with each other — the message bus is the only communication channel.

### 3. The Message Bus

The bus lives at `.mesh/messages/`. Every file is an **envelope**:

```
---
from: [agent-id]
to: [agent-id]
type: request | response | output | review | reject | approve | revision | escalate | halt
score: [1-10, only on review/approve/reject]
ref: [filename being replied to, if a response]
timestamp: [ISO 8601]
---

[body]
```

Typed envelopes matter. When the Quality Reviewer rejects an output, the rejection is a `reject` type message with a specific score and specific feedback. When an agent needs information from another agent before it can proceed, it posts a `request` message and waits. This is how the mesh coordinates without sharing context.

The bus is inspectable. After any run, you can read `.mesh/messages/` and reconstruct exactly what happened: who said what, in what order, with what scores.

### 4. The Quality Reviewer

The Quality Reviewer is always spawned — even for 2-agent runs. It scores every domain agent output on five dimensions:

| Dimension | Weight | What it checks |
|-----------|--------|----------------|
| Completeness | 25% | Did the agent fully address their brief? |
| Correctness | 30% | Is the output technically accurate? |
| Consistency | 20% | Does it align with other approved outputs? |
| Clarity | 15% | Is it well-structured and readable? |
| Constraint adherence | 10% | Does it follow mission.md constraints? |

Score = weighted average × 10. **Threshold: 8.0.**

Below 8.0, the Quality Reviewer posts a `reject` message with:
- The score for each dimension
- Specific feedback per dimension that failed
- A concrete statement of what needs to change

The agent revises and resubmits. Maximum 3 rounds. After round 3, the Conductor is escalated to decide whether to proceed with the best available output or halt.

This is what makes the mesh converge toward quality instead of averaging down.

### 5. The Synthesizer

The Synthesizer runs last — after all outputs are approved by the Quality Reviewer. It reads all approved outputs and merges them into a single coherent document.

The key rule: **prose is rewritten in one voice; code is preserved exactly.** A Synthesizer that pastes five sections together without unifying the voice produces a document that reads like a committee wrote it. The Synthesizer rewrites the connective tissue while keeping the technical content intact.

Output goes to `.mesh/final/output.md`.

---

## The run lifecycle

```
/mesh [task]
     ↓
Conductor reads task
     ↓
Conductor writes mission.md
     ↓
Conductor spawns domain agents
     ↓
Agents work (read mission, optionally request from each other)
     ↓
Each agent posts output → message bus
     ↓
Quality Reviewer scores each output
     ↓
Score ≥ 8.0 → approve → next agent proceeds
Score < 8.0 → reject (with feedback) → agent revises
     ↓
[Up to 3 revision rounds per agent]
     ↓
All outputs approved
     ↓
Synthesizer merges into .mesh/final/output.md
     ↓
Mesh complete
```

---

## The workspace

`.mesh/` is created fresh each run. It contains:

```
.mesh/
  mission.md          — task description + constraints from Conductor
  team.json           — which agents were assembled for this run
  messages/           — the message bus (all envelopes)
  outputs/            — agent outputs by agent ID
    architect/
      v1.md           — first submission
      v2.md           — revised submission (if rejected)
    full-stack-dev/
      v1.md
  quality/
    scores.md         — running quality ledger
  final/
    output.md         — synthesized final output
```

After a run completes, `.mesh/` is deleted. If you halt a run, it is archived to `.mesh-archive/[timestamp]/` for inspection.

This is intentional. The mesh is not a memory system. It is a computation. The output is what matters.

---

## Design decisions

**Why file-based communication?**
Files are permanent, inspectable, and versionable. A shared workspace (files) is a much better coordination primitive than shared context (which degrades and is not inspectable).

**Why a quality scoring threshold?**
Without a quality gate, multi-agent systems produce the average quality of all their agents. With a threshold, the system converges toward the quality of the best agents. The key is that rejection must include specific feedback — vague "improve this" does not produce revision; specific "the error handling section is missing the 429 rate limit case" does.

**Why max 8 agents?**
Coordination overhead grows faster than quality above 8 agents. The Conductor infers a team — users never specify agents manually.

**Why is the Synthesizer a separate step?**
Never synthesise mid-run. Partial synthesis creates inconsistency when later outputs need to update earlier sections. The Synthesizer has to see all approved outputs at once to merge them coherently.

**Why is `.mesh/` ephemeral?**
Stale context from previous runs is a source of contamination, not help. Each run starts clean.
