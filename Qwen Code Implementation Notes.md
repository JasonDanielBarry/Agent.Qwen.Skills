# Qwen Code — Agent Skills Implementation Notes

Qwen Code-specific details for creating, managing, and debugging Agent Skills. Read [Agent Skills Research.md](./Agent%20Skills%20Research.md) first for agent-agnostic concepts, design principles, and best practices.

---

## Table of Contents

1. [Discovery Paths](#discovery-paths)
2. [SKILL.md Format](#skillmd-format)
3. [Complete Example](#complete-example)
4. [Invocation Commands](#invocation-commands)
5. [Skill Precedence](#skill-precedence)
6. [Invocation Model](#invocation-model)
7. [Token Budget by Model](#token-budget-by-model)
8. [Extension Skills](#extension-skills)
9. [Git & Team Workflow](#git--team-workflow)
10. [Debugging](#debugging)
11. [Known Issues & Edge Cases](#known-issues--edge-cases)
12. [Resources](#resources)

---

## Discovery Paths

Qwen Code scans three locations at startup:

| Source | Path | Scope |
|---|---|---|
| **Personal** | `~/.qwen/skills/` | Individual, cross-project |
| **Project** | `.qwen/skills/` (relative to project root) | Team-shared, git-committed |
| **Extension** | Installed extension directories | Extension-provided capabilities |

Changes to `SKILL.md` files require a Qwen Code restart to take effect. Qwen Code does not hot-reload Skill files.

---

## SKILL.md Format

Qwen Code requires a `SKILL.md` file with **validated YAML frontmatter** followed by Markdown instructions.

### Frontmatter

```yaml
---
name: my-skill-name
description: Brief description of what this Skill does and when to use it
---
```

**Qwen Code validation rules (strictly enforced):**
- `name` and `description` are **required** and must be non-empty strings
- Frontmatter **must** start with `---` on line 1, close with `---` before Markdown body
- Valid YAML syntax — use **spaces only, no tabs**, proper indentation
- If the file doesn't start with `---` on line 1, Qwen Code will fail to parse it with: `Failed to parse skill file: Invalid format: missing YAML frontmatter`

**Recommended (not enforced by validation):**
- Use **lowercase letters, numbers, and hyphens** for `name`
- The `description` should include specific trigger keywords and use cases the user would actually type

**Optional frontmatter fields:**
- `version` — Track Skill versions (e.g., `1.0.0`). Not validated by Qwen Code but useful for changelogs.
- `author` — Credit the Skill author.
- `allowed-tools` — Specify which tools the Skill is permitted to use (emerging convention).

### Body

```markdown
# Skill Name

## Instructions
Clear, step-by-step guidance for Qwen Code.

## Examples
Concrete usage examples.
```

### Optional: Version Field

Qwen Code accepts a `version` field in the frontmatter (not validated, but useful for tracking):

```yaml
---
name: pdf-extractor
description: Extract text and tables from PDF files. Use when working with PDFs, forms, or document parsing.
version: 1.0.0
---
```

For deeper guidance on writing effective descriptions and instructions, see the [Best Practices](./Agent%20Skills%20Research.md#best-practices) section in the research guide.

---

## Complete Example

A production-quality `SKILL.md` for a real-world Skill:

```yaml
---
name: api-tester
description: Write and run API tests using HTTP requests. Use when testing REST endpoints, writing curl commands, validating JSON responses, or creating Postman collections.
version: 1.0.0
---
```

```markdown
# API Tester

## Instructions
1. Identify the API endpoint (URL) and HTTP method (GET, POST, PUT, DELETE)
2. Determine required headers (Authorization, Content-Type) and request body
3. Construct the HTTP request using curl or the requests library
4. Execute the request and capture the response
5. Validate the response:
   - Status code matches expected (200, 201, 400, 404, 500)
   - Response body contains expected fields
   - Response schema is valid
6. Report results in a structured format:
   - Method, URL, status code, response time
   - Key response fields (not the full body unless requested)
   - Any validation failures

## Error Handling
- If the endpoint is unreachable, report the error and suggest checking the URL
- If authentication fails, remind the user to provide valid credentials
- If the response is not valid JSON, note the content type received

## Examples
- "Test the GET /api/users endpoint"
- "Write a curl command to create a user with POST /api/users"
- "Validate the response schema of GET /api/products"
```

---

## Invocation Commands

| Action | Command |
|---|---|
| List all Skills | `/skills` (also opens the Skills Panel UI) |
| Invoke a Skill | `/skills <skill-name>` (tab autocomplete available) |
| Query available Skills | Ask naturally: "What Skills are available?" |
| Edit a Skill | Modify `SKILL.md`, then restart Qwen Code |
| Remove a Skill | `rm -rf ~/.qwen/skills/<skill-name>` or `rm -rf .qwen/skills/<skill-name>` |

### Skills Panel

Running `/skills` without arguments opens Qwen Code's **Skills Panel** — a visual management interface that provides:

- **Browse** installed and available Skills with descriptions and categories
- **One-click install/uninstall** for official and community Skills
- **Search and filter** by category or keyword
- **Real-time status** showing which Skills are installed and active
- **Automatic updates** highlighting newly released or updated Skills

The Skills Panel offers a user-friendly alternative to CLI-only workflows, especially useful for discovering and managing a personal toolkit.

---

## Skill Precedence

When Skills with the same `name` exist in multiple discovery sources, Qwen Code loads them in this order (highest priority first):

1. **Project** (`.qwen/skills/`) — overrides Personal and Extension
2. **Personal** (`~/.qwen/skills/`) — overrides Extension only
3. **Extension** — lowest priority, serves as fallback

---

## Invocation Model

Qwen Code Skills use a **model-invoked** architecture, which differs fundamentally from slash commands:

| Aspect | Skills | Slash Commands |
|---|---|---|
| **Trigger** | AI autonomously decides based on semantic matching | User explicitly types the command |
| **Context loading** | Full SKILL.md loaded only when matched | Always loaded (part of config) |
| **Flexibility** | LLM understands intent, handles synonyms | Exact command string required |
| **Extensibility** | Add new Skills without config changes | Requires config/command registration |

### How Semantic Matching Works

1. At startup, Qwen Code parses all `SKILL.md` files and extracts only `name` + `description` into a lightweight registry
2. This registry is embedded in the tool definition visible to the LLM — it does NOT consume conversation tokens
3. When you send a prompt, the LLM semantically matches your intent against all indexed descriptions
4. If a match is found, the full `SKILL.md` is loaded into context and the model follows its instructions
5. The model may load multiple Skills simultaneously if several are relevant to your prompt

### Progressive Disclosure in Qwen Code

Qwen Code implements progressive disclosure to keep context windows lean:

- **Discovery phase:** Only metadata indexed (minimal tokens)
- **Matching phase:** LLM evaluates relevance without loading files
- **Execution phase:** Full instructions + referenced files loaded on demand

This means you can have dozens of Skills installed without impacting the context window — only the matched Skills consume tokens.

---

## Token Budget by Model

Every loaded Skill consumes tokens from the model's context window. Qwen Code uses various Qwen model variants. Approximate context limits:

| Model Variant | Context Window | Approx. Capacity |
|---|---|---|
| Qwen 2.5 32B | 32K tokens | ~6,000–8,000 words total (conversation + Skills) |
| Qwen 2.5 72B | 128K tokens | ~25,000–30,000 words total |
| Qwen Max | 32K tokens | ~6,000–8,000 words total |

> **Note:** These are approximate figures. The actual context window depends on the specific model version and configuration. Check the [Qwen model documentation](https://qwenlm.github.io/qwen-code-docs/) for current specs.

### Practical Guidelines

- On a **32K model**, keep total loaded Skills under **1,000 words** combined
- On a **128K model**, you have more headroom but the principle remains: every Skill token is a task token spent
- If your `SKILL.md` exceeds **2,000 words**, split it or move details to `reference.md`

---

## Extension Skills

Extensions can bundle and distribute Skills as part of their package.

### How It Works

When you install a Qwen Code extension, it may include a `skills/` directory. Qwen Code discovers and indexes these Skills automatically at startup, alongside Personal and Project Skills.

Extension Skills are declared via a `skills` field in the extension's `qwen-extension.json` manifest:

```json
{
  "name": "my-extension",
  "version": "1.0.0",
  "skills": "skills/"
}
```

The `skills/` folder follows the identical SKILL.md structure and validation rules as Personal and Project Skills.

### Creating an Extension with Skills

1. Create your extension directory structure:
   ```
   my-extension/
   ├── qwen-extension.json   # Extension manifest (required)
   ├── skills/
   │   └── myext-pdf-extractor/
   │       ├── SKILL.md
   │       └── scripts/
   └── README.md
   ```

2. Place Skills inside the extension's `skills/` folder
3. Install/link the extension in Qwen Code
4. Skills are automatically discovered at next startup

### Best Practices for Extension Skills

- **Prefix Skill names** with the extension name to avoid conflicts (e.g., `myext-pdf-extractor`)
- Document which Skills an extension provides in the extension's README
- Keep extension Skills self-contained — don't depend on other extensions' Skills
- Follow the same SKILL.md validation rules (frontmatter, naming, description quality)

---

## Git & Team Workflow

When using project-level Skills (`.qwen/skills/` or this `Agents.Skills/` directory) with a team:

### What to Commit

- [x] `SKILL.md` files
- [x] `reference.md`, `examples.md`
- [x] Scripts (`.py`, `.sh`, `.js`)
- [x] Templates
- [x] This directory structure

### What to Ignore (`.gitignore`)

```gitignore
# Environment-specific files
skills/**/.env
skills/**/__pycache__/
skills/**/*.pyc

# OS artifacts
skills/**/.DS_Store
skills/**/Thumbs.db

# Local testing artifacts
skills/**/.test-output/
```

### Workflow

1. Create Skill in a feature branch
2. Test locally (see [Testing Methodology](./Agent%20Skills%20Research.md#testing-methodology) in the research guide)
3. Open a pull request
4. Team reviews `SKILL.md` for clarity, trigger quality, and security
5. Merge — teammates inherit the Skill after pulling and restarting Qwen Code

---

## Debugging

Run Qwen Code in debug mode to see Skill loading errors:

```bash
qwen --debug
```

### Common Issues

| Issue | Cause | Fix |
|---|---|---|
| Skill not found | Folder not in any discovery path | Verify folder exists in `~/.qwen/skills/`, `.qwen/skills/`, or an extension directory |
| Skill not loading | YAML syntax error | Check for tabs instead of spaces, missing `---` delimiters, or unclosed frontmatter |
| Missing field error | `name` or `description` is empty | Ensure both fields have non-empty string values |
| Invalid name | Uses uppercase, spaces, or special characters | Use only lowercase letters, numbers, and hyphens |
| Skill doesn't match | Vague `description` | Add specific trigger keywords and use cases the user would actually type |
| Script fails at runtime | Missing dependency or wrong path | Pre-install dependencies, use relative paths |
| Skill loads but instructions ignored | Instructions unclear or conflicting | Rewrite as numbered steps, avoid ambiguous language |

---

## Known Issues & Edge Cases

### Restart Required

Editing `SKILL.md` does not take effect until Qwen Code is restarted. There is no hot-reload or file watch mechanism.

### Case Sensitivity on Windows

Windows file systems are case-insensitive by default. A Skill folder named `PDF-Extractor` and `pdf-extractor` are the same folder on Windows but different on macOS/Linux. **Always use lowercase** for Skill folder names to ensure cross-platform consistency.

### Unicode in Descriptions

The `description` field is used for matching. Avoid emoji or Unicode symbols in the `description`, as the model may not match user prompts containing standard ASCII equivalents. Unicode is fine in the body Markdown.

### Empty Folders Ignored

If a Skill folder exists but contains no `SKILL.md`, Qwen Code silently ignores it. No error is raised. Always verify `SKILL.md` exists.

### YAML Frontmatter Parsing Errors

A known issue: if the YAML frontmatter is malformed (e.g., missing `---` delimiters, using tabs instead of spaces, or having invalid YAML syntax), Qwen Code will fail with: `Failed to parse skill file: Invalid format: missing YAML frontmatter`. Even if frontmatter appears to be present, subtle issues like missing closing `---` or invisible characters can cause this error.

**Fix:** Ensure the file starts with `---` on line 1, ends frontmatter with `---` on its own line, and uses valid YAML syntax with spaces only.

### Large Descriptions Cause Matching Issues

While there's no hard limit on `description` length, overly long descriptions can dilute matching signal. Keep descriptions to 1–3 sentences with specific trigger keywords.

### Multiple Matches

Qwen Code may load multiple Skills if the prompt matches several descriptions. Write distinct, non-overlapping descriptions to avoid ambiguity. See [Multiple Skills in One Prompt](./Agent%20Skills%20Research.md#multiple-skills-in-one-prompt) in the research guide.

### Autocomplete

The `/skills` command supports tab completion. Use it to browse available Skills and verify your new Skill was discovered.

### Skills Panel Availability

The Skills Panel (opened via `/skills`) may not be available in all Qwen Code deployment modes. In CLI-only or headless environments, use `/skills <skill-name>` for explicit invocation or rely on autonomous matching.

---

## Resources

- [**Qwen Code Docs — Agent Skills**](https://qwenlm.github.io/qwen-code-docs/en/users/features/skills/) — Official Qwen Code Skills documentation
- [**Qwen Code Docs — Getting Started with Extensions**](https://qwenlm.github.io/qwen-code-docs/en/developers/extensions/getting-started-extensions/) — How to build extensions that bundle Skills
- [Agent Skills Research.md](./Agent%20Skills%20Research.md) — Agent-agnostic concepts, best practices, testing methodology, CLI-First design, and error handling patterns

---

*Last updated: 9 April 2026*
