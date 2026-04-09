# Agents.Skills

A repository of custom Agent Skills for Qwen Code.

## Overview

This directory contains custom Skills — modular capabilities that extend Qwen Code's effectiveness for specific tasks. Each Skill packages instructions, scripts, templates, and reference material into a self-contained folder that the agent can discover and invoke autonomously.

## Documentation

| Document | Scope | Covers |
|---|---|---|
| [Agent Skills Research.md](./Agent%20Skills%20Research.md) | **Agent-agnostic** | What Skills are, design principles, best practices, security, token budget, versioning, lifecycle, testing methodology, distribution, agent design patterns |
| [Qwen Code Implementation Notes.md](./Qwen%20Code%20Implementation%20Notes.md) | **Qwen Code-specific** | Discovery paths, `SKILL.md` format, complete example, invocation commands, token budget by model, extension Skills, git workflow, debugging, edge cases |

Read the research guide first for universal concepts, then the implementation notes for Qwen Code specifics.

## Structure

```
Agents.Skills/
├── <skill-name>/
│   ├── SKILL.md           ← Required: frontmatter + instructions
│   ├── reference.md       ← Optional: detailed documentation
│   ├── examples.md        ← Optional: usage examples
│   ├── scripts/           ← Optional: helper scripts
│   └── templates/         ← Optional: starter templates
├── README.md              ← This file
├── QWEN.md                ← Agent context for this directory
├── Agent Skills Research.md  ← Agent-agnostic research guide
└── Qwen Code Implementation Notes.md  ← Qwen Code-specific details
```

## Getting Started

1. Read the [Agent Skills Research guide](./Agent%20Skills%20Research.md) for universal concepts and best practices
2. Read the [Qwen Code Implementation Notes](./Qwen%20Code%20Implementation%20Notes.md) for Qwen-specific details (paths, format, commands, model token budgets)
3. Create a new folder for your Skill using lowercase letters and hyphens
4. Write a `SKILL.md` with YAML frontmatter and clear, step-by-step instructions
5. Restart Qwen Code and test that the Skill activates on relevant prompts

For a quick validation checklist, see the [Quick-Start Checklist](./Agent%20Skills%20Research.md#quick-start-checklist) and [Testing Methodology](./Agent%20Skills%20Research.md#testing-methodology) in the research guide.

## Available Skills

| Skill | Description |
|---|---|
| *(none yet)* | *Create your first Skill to get started* |

## Management

| Action | Command |
|---|---|
| List all Skills | `/skills` |
| Invoke a Skill | `/skills <skill-name>` |
| Edit a Skill | Modify its `SKILL.md`, then restart Qwen Code |
| Remove a Skill | Delete its folder |
| Debug loading | Run `qwen --debug` to see YAML or path errors |

For detailed troubleshooting and known edge cases, see [Debugging](./Qwen%20Code%20Implementation%20Notes.md#debugging) and [Known Issues & Edge Cases](./Qwen%20Code%20Implementation%20Notes.md#known-issues--edge-cases) in the Qwen Code notes.

---

*Last updated: 9 April 2026*
