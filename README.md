# Agents.Skills

A repository of custom Agent Skills for Qwen Code.

## Overview

This directory contains custom Skills — modular capabilities that extend Qwen Code's effectiveness for specific tasks. Each Skill packages instructions, scripts, templates, and reference material into a self-contained folder that the agent can discover and invoke autonomously.

## Documentation

| Document | Scope | Covers |
|---|---|---|
| [Agent Skills Guide.md](./Agent%20Skills%20Guide.md) | **Agent-agnostic** | What Skills are, design principles, best practices, security, token budget, versioning, lifecycle, testing methodology, distribution, agent design patterns |
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
├── Agent Skills Guide.md  ← Agent-agnostic research guide
└── Qwen Code Implementation Notes.md  ← Qwen Code-specific details
```

## Naming Convention

To avoid naming conflicts with Skills from other sources (personal, project-level, or third-party), all Skills in this repository must use the `aqs-` prefix:

```
aqs-<skill-name>
```

Examples: `aqs-pdf-tool`, `aqs-code-review`, `aqs-data-migration`

This ensures clear scoping and prevents collisions when multiple Skill sources are active simultaneously.

## Getting Started

1. Read the [Agent Skills Guide](./Agent%20Skills%20Guide.md) for universal concepts and best practices
2. Read the [Qwen Code Implementation Notes](./Qwen%20Code%20Implementation%20Notes.md) for Qwen-specific details (paths, format, commands, model token budgets)
3. Create a new folder using the `aqs-` prefix and kebab-case naming (e.g., `aqs-pdf-tool`)
4. Write a `SKILL.md` with YAML frontmatter and clear, step-by-step instructions
5. Restart Qwen Code and test that the Skill activates on relevant prompts

For a quick validation checklist, see the [Quick-Start Checklist](./Agent%20Skills%20Guide.md#quick-start-checklist) and [Testing Methodology](./Agent%20Skills%20Guide.md#testing-methodology) in the research guide.

## Installation

Skills in this repo are **Personal Skills** — installed to `~/.qwen/skills/` for cross-project use.

### Install / Reinstall All Skills

Run the install script from the repo root:

**Windows (CMD):**
```cmd
install-skills.bat
```

**Windows (PowerShell):**
```powershell
.\install-skills.ps1
```

The script will:
1. Create `~/.qwen/skills/` if it doesn't exist
2. Copy all skills from `skills/` to `~/.qwen/skills/`
3. Replace any existing versions with the latest from this repo

> **Remember:** Restart Qwen Code after installing for changes to take effect.

### Manual Install

Copy a skill folder manually:
```cmd
xcopy /E /I /Y skills\aqs-endsession "%USERPROFILE%\.qwen\skills\aqs-endsession"
```

## Available Skills

| Skill | Description |
|---|---|
| `aqs-endsession` | Save a session handoff note when wrapping up — captures what was done, where work left off, and what to tackle next, so the next session resumes instantly |
| `aqs-reattach` | Read the latest session handoff note and restore context — surfaces accomplishments, stopping point, and next tasks; auto-creates a todo list |
| `aqs-git-commit-and-push` | Autonomously stage, commit, and push with conventional commit messages — handles upstream setup, merge conflict warnings, and edge cases without asking permission |
| `aqs-git-merge` | Merge branches interactively with guided conflict resolution — verifies repo state, presents target branches, and offers post-merge actions |

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

*Last updated: 10 April 2026*
