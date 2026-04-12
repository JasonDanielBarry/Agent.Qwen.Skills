# Agent Skills — Universal Research & Reference Guide

A knowledge base on what Agent Skills are, how they work, and how to design effective ones. This guide is **agent-agnostic** — the concepts apply to any CLI agent that supports pluggable Skills, capabilities, or modules.

---

## Table of Contents

1. [What Are Agent Skills?](#what-are-agent-skills)
2. [How Skills Work](#how-skills-work)
3. [Skill Discovery Sources](#skill-discovery-sources)
4. [Skill Precedence](#skill-precedence)
5. [Folder Structure](#folder-structure)
6. [Skill Definition Format](#skill-definition-format)
7. [Creating a Skill](#creating-a-skill)
8. [Quick-Start Checklist](#quick-start-checklist)
9. [Best Practices](#best-practices)
10. [What Skills Cannot Do](#what-skills-cannot-do)
11. [Multiple Skills in One Prompt](#multiple-skills-in-one-prompt)
12. [Security Considerations](#security-considerations)
13. [Token Budget & Context Impact](#token-budget--context-impact)
14. [Versioning & Changelog](#versioning--changelog)
15. [Management & Debugging](#management--debugging)
16. [Skill Lifecycle](#skill-lifecycle)
17. [Testing Methodology](#testing-methodology)
18. [Skill Distribution](#skill-distribution)
19. [Agent Design Patterns](#agent-design-patterns)
20. [Error Handling Best Practices](#error-handling-best-practices)
21. [Resources](#resources)

---

## What Are Agent Skills?

Agent Skills are **modular capabilities** that package expertise into organized directories. Each Skill extends an agent's effectiveness for specific tasks by providing:

- **Instructions** — structured guidance the model follows when the Skill is active
- **Supporting assets** — scripts, templates, documentation, and examples

Skills let you encode specialized knowledge once and have the agent apply it consistently, without repeating context in every prompt.

---

## How Skills Work

Skills are activated through a **progressive disclosure** process:

### 1. Discovery
At startup, the agent scans all configured directories, parses the metadata from each Skill definition file, and builds a lightweight registry of available Skills. Only the `name` and `description` fields are indexed at this stage — full instruction files are NOT loaded into context yet. This keeps token overhead minimal even with hundreds of Skills installed.

### 2. Semantic Matching
When you send a prompt, the model semantically matches your request against the indexed `description` fields of all available Skills. This is **semantic matching by the LLM**, not simple keyword matching — the model understands intent, synonyms, and related concepts.

### 3. Execution (Progressive Disclosure)
When a Skill is matched, its full `SKILL.md` is loaded into context. The model then follows the instructions, dynamically reading reference files or executing bundled scripts **only when required**, preserving context window space.

### Invocation Modes

**Autonomous Invocation (Primary Mode):** The model decides to load a Skill based on matching your prompt against the Skill's description. You don't need to manually trigger anything.

**Explicit Invocation:** Manually trigger a Skill by name using the agent's command interface (e.g., `/skills <skill-name>`). Useful for verification or when autonomous matching doesn't trigger as expected.

---

## Skill Discovery Sources

Most agents support three tiers of Skill discovery:

| Source | Typical Path | Scope |
|---|---|---|
| **Personal** | User config directory (e.g., `~/.config/<agent>/skills/`) | Individual, cross-project |
| **Project** | Project-level directory (e.g., `<project>/.<agent>/skills/`) | Team-shared, version-controlled |
| **Extension** | Plugin/extension directories | Installed capabilities |

Agents scan these sources at startup and build an index of available Skills. Changes to Skill definition files typically require an agent restart to take effect.

---

## Skill Precedence

When Skills with the **same name** exist in multiple discovery sources, most agents load them in this priority order (highest first):

1. **Project** — overrides Personal and Extension
2. **Personal** — overrides Extension only
3. **Extension** — lowest priority, serves as fallback

This means a teammate can override a global Skill by creating a project-local one with the same name.

When **different Skills** could match the same prompt, the model uses the description field to pick the best match. If multiple Skills are relevant, the model may load several simultaneously (see [Multiple Skills in One Prompt](#multiple-skills-in-one-prompt)).

---

## Folder Structure

```
my-skill/
├── SKILL.md           ← REQUIRED: definition + instructions (name varies by agent)
├── reference.md       ← Optional: detailed documentation
├── examples.md        ← Optional: usage examples
├── scripts/           ← Optional: helper scripts, utilities
│   └── helper.py
└── templates/         ← Optional: starter templates
    └── template.txt
```

> **Note:** The main definition file is conventionally called `SKILL.md` in Qwen Code. Other agents may use `SKILL.yaml`, `config.json`, or similar. The pattern — a single required definition file plus optional supporting assets — is consistent across agents.

### File Conventions

| File | Purpose |
|---|---|
| Definition file (e.g., `SKILL.md`) | **Required.** Contains metadata (name, description, triggers) and the core instructions the model follows. |
| `reference.md` | Detailed reference documentation, API docs, config details, etc. |
| `examples.md` | Concrete usage examples, edge cases, and sample outputs. |
| `scripts/` | Helper scripts the agent can execute (Python, Bash, etc.). |
| `templates/` | Starter templates the agent can copy and fill in. |

Reference any additional file directly inside the main Skill definition file using relative links. For nested code blocks, use indentation to avoid fence conflicts:

```markdown
See [reference.md](reference.md) for full API documentation.

Run the helper script:

    ```bash
    python scripts/helper.py
    ```
```

---

## Skill Definition Format

Most agents require a definition file with **validated metadata** followed by Markdown instructions. The exact format varies by agent, but the pattern is consistent:

### Metadata

```yaml
---
name: my-skill-name
description: Brief description of what this Skill does and when to use it
---
```

**Common rules across agents:**
- `name` and `description` are **required** and must be non-empty strings
- Use **lowercase letters, numbers, and hyphens** for `name`
- The `description` is the primary matching signal — make it specific and keyword-rich
- The definition file must start with the metadata delimiter

### Body

After the metadata, write clear Markdown instructions:

```markdown
# Skill Name

## Instructions
Step-by-step guidance for the agent. Be specific about:
- When to invoke this Skill
- What inputs to expect
- What steps to follow
- What output to produce

## Examples
Concrete usage examples showing the Skill in action.

## Notes
Edge cases, limitations, or additional context.
```

> **Note:** The exact metadata format and validation rules vary by agent. See your agent's implementation guide for details. For Qwen Code, see [Qwen Code Implementation Notes](./Qwen%20Code%20Implementation%20Notes.md#skillmd-format).

---

## Creating a Skill

### Step 1: Create the Folder

```bash
mkdir <skill-name>
```

Use lowercase letters, numbers, and hyphens.

### Step 2: Write the Skill Definition

Create the definition file with metadata and instructions:

```yaml
---
name: pdf-extractor
description: Extract text, tables, and metadata from PDF files. Use when working with PDFs, forms, invoices, or document parsing.
---
```

```markdown
# PDF Extractor

## Instructions
1. When the user provides a PDF file, open and parse it using the appropriate tool
2. Extract text content, tables, and metadata (author, creation date, page count)
3. Present extracted content in a structured format
4. If the PDF is encrypted, prompt the user for a password

## Examples
- "Extract the text from report.pdf"
- "What tables are in this invoice PDF?"
- "Get the metadata from this document"
```

### Step 3: Add Supporting Files (Optional)

```bash
mkdir scripts templates
```

Add helper scripts the agent can execute, or templates it can fill in.

### Step 4: Test

1. Restart the agent
2. Prompt with keywords from your `description`
3. Verify the Skill loads and instructions are followed
4. Use the agent's explicit invocation command if needed

### This Project's Standard: Semantic Constraint Framework

While the concepts in this guide are universal, **all Skills in this repository must conform to the [Semantic Constraint Framework](./semantic-constraint-framework/Semantic%20Constraint%20Framework.md)** — a structured methodology for constraining probabilistic AI behavior into reliably deterministic outcomes.

The framework defines:
- **10 universal required sections** every semantic artifact must include (Purpose, Scope, Inputs, Outputs, Constraints, Invariants, Failure Modes, Validation Strategy, Relationships, Guarantees)
- **Type-specific sections** for each artifact type (Skills, Plans, Tools, Memory, etc.)
- **Proven constraint techniques** — prompt chaining, verification functions, formal invariants, the KERNEL framework, self-verification loops
- **Validation rules** for detecting and correcting constraint violations

When creating a Skill for this project, apply the framework's Skill-specific requirements on top of the universal base described in this guide. The framework is the governing standard; this guide provides the foundational concepts.

---

## Quick-Start Checklist

Before deploying a Skill, confirm each item:

- [ ] Definition file exists and starts with the correct delimiter on line 1
- [ ] Metadata has valid `name` (lowercase + hyphens) and non-empty `description`
- [ ] `description` includes specific trigger keywords users will actually type
- [ ] Instructions are step-by-step, not vague prose
- [ ] No hardcoded paths, secrets, or environment-specific values
- [ ] All referenced files (reference docs, scripts, templates) exist in the Skill folder
- [ ] **Conforms to the [Semantic Constraint Framework](./semantic-constraint-framework/Semantic%20Constraint%20Framework.md)** — all universal required sections present, type-specific sections satisfied
- [ ] Agent restarts and loads the Skill when prompted with description keywords
- [ ] Skill folder name matches the `name` in metadata
- [ ] Scripts handle missing dependencies gracefully

---

## Best Practices

### 1. Keep Skills Focused

**One Skill = one capability.** Split broad domains into specific Skills.

| ❌ Too Broad | ✅ Focused |
|---|---|
| `document-processing` | `pdf-extraction`, `excel-analysis`, `word-generation` |
| `data-science` | `data-visualization`, `statistical-testing`, `model-evaluation` |
| `web-development` | `react-component`, `api-endpoint`, `css-layout` |

Broad Skills dilute instruction clarity. Focused Skills are easier to discover, maintain, and update independently.

### 2. Write Trigger-Rich Descriptions

The `description` field is what the model matches against user prompts. Make it explicit with use-case keywords.

```yaml
# ✅ Good — specific use cases and trigger keywords
description: Extract text and tables from PDF files. Use when working with PDFs, forms, invoices, or document extraction.

# ❌ Vague — no trigger signals
description: Helps with documents.

# ✅ Good — includes tool names and scenarios
description: Create React components with TypeScript, Tailwind CSS, and proper props. Use when building UI components, forms, or dashboards.

# ❌ Vague
description: React development help.
```

### 3. Write Clear, Actionable Instructions

Structure instructions as step-by-step guidance:

```markdown
## Instructions
1. Identify the file type from the extension
2. Load the appropriate parser
3. Extract content in structured sections
4. Validate extraction completeness
5. Return results in a structured format
```

Avoid vague instructions like "help the user with their files." Be specific about what to do, how to do it, and what output to produce.

### 4. Test Activation

Before committing a Skill:

1. **Restart** the agent to pick up the new Skill
2. **Prompt** with keywords from your `description`
3. **Verify** the Skill loads automatically
4. If it doesn't auto-load, check for:
   - Metadata syntax errors
   - Path issues
   - Invalid or missing metadata fields

### 5. Test as a Team

For project-shared Skills:

- **Activation accuracy** — does it load when it should?
- **Instruction clarity** — does the agent follow instructions correctly?
- **Edge-case handling** — what happens with unusual inputs?

### 6. Make Skills Self-Contained

A Skill should work independently:

- Don't assume other Skills exist
- Don't rely on external dependencies not included in the Skill folder
- Include all needed scripts, templates, and references within the folder
- Scripts should handle missing dependencies gracefully

---

## What Skills Cannot Do

Skills are powerful but have inherent limitations. Know these before designing:

| Limitation | Explanation |
|---|---|
| **No persistent state** | Skills can't store data between sessions. Each session starts fresh. |
| **No built-in approval mechanisms** | Skills execute without human-in-the-loop confirmation gates. Production safety requires wrapping skill actions in custom review callbacks or adding explicit confirmation steps in instructions. |
| **No automatic dependency management** | Skills cannot guarantee dependencies are installed at runtime. Scripts must handle missing packages gracefully or instructions must direct the agent to verify prerequisites. |
| **No network guarantees** | Skills can reference URLs, but external APIs may be unavailable. Include fallback behavior. |
| **No inter-Skill direct calls** | Skills don't call each other through a framework API. However, a Skill's scripts *can* invoke other Skills' CLI tools or scripts directly, enabling workflow orchestration at the shell level (see [CLI-First Skill Design](#cli-first-skill-design)). |
| **No sandboxed execution** | Scripts run with the same permissions as the user. There is no containerization or sandboxing unless the agent itself provides it. |
| **Immediate update propagation** | When a Skill is updated, the change applies immediately to all users. There is no native version pinning or gradual rollout. |

Design Skills to be **stateless, self-contained, and graceful under failure**.

---

## Multiple Skills in One Prompt

A single user prompt can trigger **multiple Skills** simultaneously. For example:

> "Extract the data from this PDF and create a spreadsheet report"

This could activate both a `pdf-extraction` Skill and a `spreadsheet-generation` Skill.

### How the Model Handles It

1. The model scans all description fields against your prompt
2. It loads all relevant Skills into context
3. It coordinates execution — running one Skill's instructions, then the other's
4. It merges results into a single response

### Designing for Multi-Skill Scenarios

- **Define clear boundaries** — each Skill should own one phase of a workflow
- **Specify inputs and outputs** — so the model can chain Skills together
- **Avoid overlapping descriptions** — two Skills with nearly identical descriptions create ambiguity

```yaml
# ❌ Overlapping — model can't decide
description: Create spreadsheets and data reports.

# ✅ Distinct — clear ownership
description: Generate formatted spreadsheets from CSV or JSON data. Use when converting data files to spreadsheets.
```

---

## Security Considerations

Skills are instructions the agent **will follow**. Treat them with the same care as code you commit to a repository.

### What NOT to Include

| Risk | Example | Safer Alternative |
|---|---|---|
| **Secrets / API keys** | `export API_KEY=sk-12345` | Use environment variables: `export API_KEY=$MY_API_KEY` |
| **Hardcoded credentials** | `mysql -u admin -p password123` | Reference credential managers or `.env` files |
| **Destructive commands** | `rm -rf ~/project/data` | Use safe paths, dry-run flags, and add confirmation steps |
| **Personal information** | `Send report to john@company.com` | Use placeholders: `Send report to <recipient>` |

### Best Practices

- Assume **anyone with repo access can read your Skill files**
- Use **environment variables** or config files (`.env`, gitignored) for secrets
- Scripts should **validate inputs** before executing
- Add **confirmation steps** for destructive operations
- Review Skill files in **code review** the same way you review source code

---

## Token Budget & Context Impact

Every loaded Skill consumes tokens from the model's context window. A bloated definition file reduces the tokens available for actual task execution.

### Guidelines

| Metric | Recommendation |
|---|---|
| **Definition file size** | Most Skills should be 500–1,000 words. Keep under 2,000 words. |
| **Description length** | 1–3 sentences. Enough to be specific, not a paragraph. |
| **Instructions** | Use numbered steps and bullet points. Avoid lengthy prose. |
| **Referenced files** | The model loads these into context too. Keep reference docs concise. |

> **Note:** Exact token counts depend on the model's tokenizer. A rough estimate is 1 word ≈ 1–2 tokens for most tokenizers. Check your agent's model documentation for precise ratios.

### When a Skill Is Too Large

If your definition file is growing:

1. **Split it** into two focused Skills (see [Keep Skills Focused](#keep-skills-focused))
2. **Move detail** to a reference file and link to it
3. **Remove examples** that aren't critical — put them in a separate examples file

### Context Window Considerations

Different model variants have different context limits. Check your agent's model specs for exact numbers. The principle remains: **every Skill token is a task token spent**.

---

## Versioning & Changelog

As Skills evolve, track changes so your team knows what's new.

### Approach: Metadata Header

Add a version field in the metadata:

```yaml
---
name: pdf-extractor
description: Extract text and tables from PDF files. Use when working with PDFs, forms, invoices, or document parsing.
version: 1.2.0
---
```

### Changelog Section

Add a changelog section at the bottom of the definition file:

```markdown
## Changelog

| Version | Date | Change |
|---|---|---|
| 1.2.0 | 2026-04-09 | Added support for encrypted PDFs |
| 1.1.0 | 2026-03-15 | Improved table extraction accuracy |
| 1.0.0 | 2026-02-01 | Initial release |
```

### Semantic Versioning

Use [SemVer](https://semver.org/) conventions:

- **MAJOR** — breaking change in Skill behavior or interface
- **MINOR** — new capability, backward compatible
- **PATCH** — bug fix or instruction clarification

---

## Management & Debugging

### Common Commands

| Action | Typical Command |
|---|---|
| List all Skills | `/skills`, `skills list`, or equivalent |
| Invoke a Skill | `/skills <skill-name>` or equivalent |
| Edit a Skill | Modify the definition file, then restart the agent |
| Remove a Skill | Delete its folder |

### Debug Loading Issues

Most agents provide a debug or verbose mode. Common issues across agents:

| Issue | Cause | Fix |
|---|---|---|
| Skill not found | Wrong path or naming | Verify folder exists in a discovery source |
| Skill not loading | Metadata syntax error | Check delimiter, tabs vs spaces, required fields |
| Skill not matching | Vague description | Add specific trigger keywords and use cases |
| Scripts failing | Missing dependencies | Pre-install dependencies or add graceful fallbacks |

---

## Skill Lifecycle

Skills evolve through predictable stages. Managing each stage deliberately keeps your Skill registry healthy.

### Stages

| Stage | Activity | Key Decisions |
|---|---|---|
| **Creation** | Draft definition file, add scripts/templates | Scope, name, description quality |
| **Testing** | Validate activation, instructions, edge cases | Activation accuracy, instruction clarity |
| **Deployment** | Commit to git, share with team | Version number, changelog entry |
| **Maintenance** | Update instructions, fix bugs | Backward compatibility, version bumps |
| **Deprecation** | Mark as obsolete, migrate users | Migration path, sunset timeline |
| **Removal** | Delete folder, clean references | Archive or delete? |

### Deprecation Strategy

When retiring a Skill:

1. Add a deprecation notice at the top of the definition file
2. Explain why it's deprecated and what replaces it
3. Leave it in place long enough for users to notice
4. Then remove the folder

```markdown
> ⚠️ This Skill is deprecated as of 2026-04-09.
> Use `new-skill-name` instead.
> This Skill will be removed on 2026-05-01.
```

---

## Testing Methodology

Systematic testing catches issues before they frustrate users.

### Activation Testing

Verify the Skill loads when it should:

1. **Direct match** — prompt uses exact keywords from the `description`
2. **Synonym match** — prompt uses synonyms or related terms
3. **No false positives** — unrelated prompts do NOT trigger the Skill
4. **Multi-Skill scenario** — prompt that should trigger this Skill AND another

### Instruction Testing

Verify the agent follows instructions correctly:

1. **Step adherence** — does the agent execute steps in order?
2. **Input handling** — does it handle valid and invalid inputs?
3. **Output format** — does it produce the expected output structure?
4. **Edge cases** — empty inputs, unusual file types, missing dependencies
5. **Error recovery** — what happens when a script fails mid-execution?

### Team Testing Protocol

For project-shared Skills:

1. **Author tests** — the Skill creator validates core functionality
2. **Peer review** — another team member tests without guidance
3. **Blind test** — someone unfamiliar with the Skill tries it from the description alone
4. **Retrospective** — discuss activation misses, instruction ambiguities, and gaps

### Testing Checklist

- [ ] Activates on direct keyword match
- [ ] Activates on synonym/related term match
- [ ] Does NOT activate on unrelated prompts
- [ ] Instructions followed in correct order
- [ ] Handles valid inputs correctly
- [ ] Handles invalid inputs gracefully (error messages, not crashes)
- [ ] Output matches expected format
- [ ] Scripts handle missing dependencies
- [ ] Peer can use the Skill without guidance

---

## Skill Distribution

Beyond committing to a shared git repository, Skills can be distributed in several ways:

### Methods

| Method | Best For | Trade-offs |
|---|---|---|
| **Git repository** | Team-shared project Skills | Requires clone/pull, version-controlled |
| **Dotfiles sync** | Personal Skills across machines | Individual only, no collaboration |
| **Zip/tarball** | One-off sharing, air-gapped environments | Manual updates, no version tracking |
| **Extension package** | Public or organization-wide distribution | Requires packaging infrastructure |
| **CI artifact** | Build-validated Skills | Needs CI pipeline setup |

### Packaging for Distribution

If sharing Skills outside version control:

1. Zip the Skill folder: `zip -r my-skill.zip my-skill/`
2. Include install instructions with the archive
3. Recipient extracts to their agent's discovery path
4. Restart the agent

---

## Agent Design Patterns

Understanding broader agent architecture helps design better Skills.

### Five Core Patterns

| Pattern | Description | Skill Relevance |
|---|---|---|
| **Tool Use** | Agent calls external tools (APIs, scripts, CLIs) | Skills often include scripts the agent executes |
| **Planning** | Agent breaks complex tasks into steps before acting | Skills provide the instructions the agent follows within its plan |
| **Reflection** | Agent reviews and corrects its own output | Skills can include validation steps |
| **Orchestration** | Central agent coordinates sub-tasks | Skills can orchestrate multi-step workflows |
| **Multi-Agent** | Multiple specialized agents collaborate | Each Skill acts like a specialized sub-agent |

### Skill as a Sub-Agent

Think of each Skill as a **specialized sub-agent**:

- It has its own instructions (behavior spec)
- It can use tools (scripts, references)
- It's invoked when its expertise is needed
- It returns to the main context when done

This mental model helps you design Skills that are focused, testable, and composable.

### CLI-First Skill Design

A powerful pattern for building Skills that work reliably for both humans and agents:

**Core Principle:** Design every Skill's scripts as standalone CLI tools first. This enables dual-use — humans can run them manually in a terminal, and agents can invoke them through the Bash tool.

**Key Practices:**

| Practice | Description |
|---|---|
| **One script, one Skill** | Each capability is a standalone executable with a clear purpose |
| **Subcommand architecture** | Use subcommands for operations (e.g., `skill.sh list`, `skill.sh get <id>`) |
| **Adaptive output** | Output JSON by default for programmatic parsing; auto-detect TTY to render human-readable text when interactive |
| **Standard I/O routing** | Send data/results to `stdout`, errors/logs to `stderr` |
| **Environment-based config** | Load credentials from environment variables, never hardcode them |
| **Non-interactive default** | Eliminate prompts; use `--yes` or `--force` flags for automated execution |
| **Help & shebang** | Include `#!/bin/bash` and `--help` fallback for usage instructions |

**When to avoid CLI-First design:**
- High-frequency calls (>100/sec) — use in-process functions
- Complex object graphs — use structured APIs
- Real-time streaming — use WebSockets/SSE

**Composition model:** Higher-order Skills can invoke other Skills' CLIs directly, enabling workflow orchestration:

```bash
# A report Skill that chains data extraction and spreadsheet Skills
python scripts/extract.py --input data.pdf | python scripts/generate.py --output report.xlsx
```

**Execution graph:** `Skill Logic → CLI Interface → Consumer` (Human Terminal, Agent Bash Tool, Automation Scripts, or Cron).

### Progressive Disclosure Architecture

Skills use a three-stage progressive disclosure pattern to remain context-efficient:

1. **Discovery** — Only `name` + `description` are indexed at startup (minimal tokens)
2. **Semantic Matching** — LLM matches user intent against descriptions (no file loading yet)
3. **On-Demand Loading** — Full `SKILL.md` + referenced files are loaded ONLY when the Skill is matched

This enables hundreds of installed Skills with minimal context overhead. The model reads auxiliary files (reference docs, scripts) only when the execution path requires them.

---

## Error Handling Best Practices

Skills should anticipate failure at multiple levels. Well-designed error handling keeps agents productive even when things go wrong.

### Script Error Handling

Scripts bundled with Skills should follow these conventions:

| Practice | Description |
|---|---|
| **Return meaningful exit codes** | Use standard POSIX codes: `0` (success), `1` (error), `2` (usage error), `127` (not found) |
| **Log to stderr** | Send errors and diagnostic messages to `stderr`, results to `stdout` |
| **Validate inputs early** | Check for required arguments, file existence, and dependency availability before proceeding |
| **Fail fast, fail loud** | Exit immediately on unrecoverable errors with a clear message |
| **Provide recovery guidance** | When possible, suggest what the user or agent should do to resolve the issue |

### Instruction-Level Error Handling

In your `SKILL.md`, include an **Error Handling** section that tells the agent what to do when things go wrong:

```markdown
## Error Handling
- If the script fails, return the complete error log to the user — do NOT attempt unguided auto-fixes
- If a dependency is missing, instruct the user to install it: `pip install <package>`
- If the input file is invalid, report the specific issue (wrong format, corrupted, encrypted)
- If an API is unreachable, suggest retrying with a backoff or checking network connectivity
```

### Agent Behavior on Failure

| Scenario | Expected Agent Behavior |
|---|---|
| Script returns non-zero exit code | Report the error, provide the log, suggest next steps |
| Dependency not found | Tell the user what to install, do NOT attempt to install it |
| Input validation failure | Explain what's wrong with the input, ask for correction |
| Network/API failure | Report the failure, suggest retry or alternative approach |

**Key principle:** The agent should be transparent about failures, provide actionable diagnostics, and avoid silent failures or hallucinated fixes.

---

## Resources

- [**Qwen Code Docs — Agent Skills**](https://qwenlm.github.io/qwen-code-docs/en/users/features/skills/) — Official Qwen Code Skills documentation
- [**Agentic AI: Five Design Patterns**](https://levelup.gitconnected.com/agentic-ai-the-five-design-patterns-that-turn-llms-into-ai-agents-7c95dec92d1b) — Tool use, planning, reflection, orchestration, and multi-agent patterns
- [**AI Agent Orchestration Patterns — Azure**](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns) — Sequential, concurrent, group chat, and handoff patterns
- [**Design Patterns for Agentic AI**](https://appstekcorp.com/blog/design-patterns-for-agentic-ai-and-multi-agent-systems/) — Reactive loops, hierarchical supervision, and graph-based memory
- [**Spring AI Agentic Patterns: Agent Skills**](https://spring.io/blog/2026/01/13/spring-ai-generic-agent-skills) — Progressive disclosure, tool-centric design, and context-efficient skill architecture
- [**CLI-First Skill Design — Agentic Patterns**](https://agentic-patterns.com/patterns/cli-first-skill-design/) — Designing Skills as dual-use CLI tools for humans and agents
- [**SemVer Specification**](https://semver.org/) — Semantic versioning conventions for Skill changelogs

---

*Last updated: 9 April 2026*
