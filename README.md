# Agent Skills (SAS)

A repository of custom Agent Skills for Gemini CLI — all adhering to the **Semantic Constraint Framework**.

## Overview

This repository contains custom Skills — modular capabilities that extend Gemini CLI's effectiveness for specific tasks. Each Skill packages instructions, scripts, templates, and reference material into a self-contained folder that the agent can discover and invoke autonomously.

### Core Documentation

| Document | Purpose |
|---|---|
| [Semantic Constraint Framework.md](./semantic-constraint-framework/Semantic%20Constraint%20Framework.md) | **Governing framework** — techniques, artifact catalog, validation rules, enforcement procedures |
| [Agent Skills Guide.md](./Agent%20Skills%20Guide.md) | **Agent-agnostic** concepts — what Skills are, design principles, best practices, security, versioning |
| [GEMINI.md](./GEMINI.md) | **Gemini CLI-specific** — agent context for this directory, discovery paths, SKILL.md format |

## Repository Structure

```
semantic-agent-skills/
├── skills/
│   ├── sas-endsession/     ← Skill for session handoff
│   ├── sas-reattach/       ← Skill for resuming session
│   ├── ...                 ← Other custom Skills
├── semantic-constraint-framework/
│   └── Semantic Constraint Framework.md  ← Governing framework
├── GEMINI.md               ← Agent context for this directory
├── Agent Skills Guide.md   ← Agent-agnostic research guide
└── README.md               ← This file
```

## Getting Started

1. Read the [Agent Skills Guide](./Agent%20Skills%20Guide.md) for universal concepts and best practices
2. Read the [GEMINI.md](./GEMINI.md) for Gemini-specific details (paths, format, commands)
3. Create a new folder in `skills/` for your Skill using lowercase letters and hyphens
4. Write a `SKILL.md` with YAML frontmatter and clear, step-by-step instructions
5. Add any supporting files (scripts, templates, reference docs)
6. Install the skills and test that the Skill activates on relevant prompts via `activate_skill`

## Installation

Skills in this repo are **Personal Skills** — installed to `~/.gemini/skills/` for cross-project use.

### Automated Installation (Recommended)

Run the included PowerShell script from the repository root:

```powershell
.\install-sas-skills.ps1
```

### Manual Installation

1. Create `~/.gemini/skills/` if it doesn't exist
2. Copy all skills from `skills/` to `~/.gemini/skills/`

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.gemini\skills" -Force
Copy-Item -Path "skills\*" -Destination "$env:USERPROFILE\.gemini\skills" -Recurse -Force
```

**Windows (CMD):**
```cmd
mkdir "%USERPROFILE%\.gemini\skills"
xcopy /E /I /Y skills "%USERPROFILE%\.gemini\skills"
```

## Available Skills

| Skill | Description |
|---|---|
| `sas-endsession` | Save a session handoff note when wrapping up — captures what was done, where work left off, and what to tackle next |
| `sas-reattach` | Read the latest session handoff note and restore context — auto-creates todo list from next steps |
| `sas-git-commit-and-push` | Autonomously stage, commit, and push with conventional commit messages — no permission prompts |
| `sas-git-merge` | Merge branches interactively with guided conflict resolution — verifies repo state, presents target branches, offers post-merge actions |
| `sas-self-healing-memory` | Maintain a structured, self-correcting memory system — persistent knowledge across sessions with verification and conflict resolution |
| `install-sas-skills` | Install or update all skills from this repo to the local machine via `install-sas-skills.ps1` — **repo-local only** |

## Management

| Action | Command |
|---|---|
| List all Skills | `activate_skill` (to see available skills) |
| Invoke a Skill | `activate_skill(name="<skill-name>")` |
| Edit a Skill | Modify its `SKILL.md` |

For detailed troubleshooting and known edge cases, see the [GEMINI.md](./GEMINI.md) file.
