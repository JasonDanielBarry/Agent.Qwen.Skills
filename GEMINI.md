# Agent Skills

## Directory Overview

This directory stores **Agent Skills** for Gemini CLI — reusable, discoverable capabilities that extend the agent's effectiveness for specific tasks. Each Skill packages instructions, scripts, templates, and reference material into a self-contained folder.

All Skills in this repository **must adhere to the [Semantic Constraint Framework](./semantic-constraint-framework/Semantic%20Constraint%20Framework.md)** — a system of structured artifacts that constrain probabilistic AI behavior into reliably deterministic outcomes.

Skills are invoked autonomously by the model when your prompt matches a Skill's `description`, or explicitly via `activate_skill`.

**Location:** `D:\Users\jasonbarry\Documents\Development\Agent\semantic-agent-skills`

## Purpose

This directory serves as an **Extension** source for Skills. It is a workspace for:

- Creating and managing custom Agent Skills that follow the Semantic Constraint Framework
- Developing reusable, team-shared capabilities with explicit constraint boundaries
- Organizing Skill configurations, scripts, and templates
- Testing and validating new Skill implementations against semantic discipline

## Documentation

| Document | Purpose |
|---|---|
| [Semantic Constraint Framework.md](./semantic-constraint-framework/Semantic%20Constraint%20Framework.md) | **Governing framework** — techniques, artifact catalog, validation rules, enforcement procedures for all semantic artifacts |
| [Agent Skills Guide.md](./Agent%20Skills%20Guide.md) | **Agent-agnostic** concepts: what Skills are, design principles, best practices, security, versioning |

## Structure

```
semantic-agent-skills/
├── <skill-name>/
│   ├── SKILL.md           ← Required: frontmatter + instructions
│   ├── reference.md       ← Optional: detailed documentation
│   ├── examples.md        ← Optional: usage examples
│   ├── scripts/           ← Optional: helper scripts, utilities
│   └── templates/         ← Optional: starter templates
├── semantic-constraint-framework/
│   └── Semantic Constraint Framework.md  ← Governing framework
├── README.md              ← Project overview
├── GEMINI.md              ← This file — agent context for this directory
└── Agent Skills Guide.md  ← Agent-agnostic research guide
```

For the canonical folder structure of a single Skill, see [Folder Structure](./Agent%20Skills%20Guide.md#folder-structure) in the research guide.

## Getting Started

1. Read the [Agent Skills Guide](./Agent%20Skills%20Guide.md) for universal concepts and best practices
2. Create a new folder for your Skill using lowercase letters and hyphens
3. Write a `SKILL.md` with YAML frontmatter and clear, step-by-step instructions
4. Add any supporting files (scripts, templates, reference docs)
5. Test that the Skill activates on relevant prompts via `activate_skill`

## Available Skills

| Skill | Description |
|---|---|
| `sas-endsession` | Save a session handoff note when wrapping up — captures what was done, where work left off, and what to tackle next |
| `sas-reattach` | Read the latest session handoff note and restore context — auto-creates todo list from next steps |
| `sas-git-commit-and-push` | Autonomously stage, commit, and push with conventional commit messages — no permission prompts |
| `sas-git-merge` | Merge branches interactively with guided conflict resolution — verifies repo state, presents target branches, offers post-merge actions |
| `sas-self-healing-memory` | Maintain a structured, self-correcting memory system — persistent knowledge across sessions with verification and conflict resolution |
| `install-sas-skills` | Install or update all skills from this repo to the local machine — **repo-local only** (lives in `.gemini/skills/`, not installed to machine) |

## Management

| Action | Command |
|---|---|
| List all Skills | `activate_skill` (to see available skills) |
| Invoke a Skill | `activate_skill(name="<skill-name>")` |
| Edit a Skill | Modify its `SKILL.md` |
| Remove a Skill | Delete its folder |

## Conventions

- Use **kebab-case** for Skill folder names (e.g., `sas-pdf-extraction`, `sas-code-review`)
- All Skills must use the `sas-` prefix to avoid naming conflicts with other sources
- Every Skill requires a `SKILL.md` with valid YAML frontmatter (`name` + `description`)
- All Skills **must follow the Semantic Constraint Framework** — defining purpose, scope, inputs, outputs, constraints, invariants, failure modes, validation strategy, relationships, and guarantees. See the [framework document](./semantic-constraint-framework/Semantic%20Constraint%20Framework.md) for details.
- Keep Skills modular, self-contained, and focused on one capability
- Avoid hardcoding paths, secrets, or environment-specific values
- Reference supporting files inside `SKILL.md` using relative Markdown links

## Related Directories

- `../` — Parent Agent development workspace
- `~/.gemini/skills/` — Personal Skills (individual, cross-project)
- `.gemini/skills/` — Project-level Skills (team-shared, git-committed)

## Notes

- Skills are invoked by the agent, not executed independently
- Skills can reference external tools via MCP or other integration methods
- Keep Skill definitions concise to conserve context window tokens
- For security guidelines, limitations, and multi-Skill behavior, see the [Agent Skills Guide](./Agent%20Skills%20Guide.md)

---

*Last updated: 14 April 2026*
