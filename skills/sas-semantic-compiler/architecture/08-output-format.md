# 08 — Output Format

## Format Decision

**Optimized Markdown with XML-like tags for strict section boundaries.**

Research across Cloudflare, Anthropic, and industry practitioners confirms:
- **Markdown** is the lingua franca for AI agents — explicit hierarchical structure with minimal token overhead (~80% fewer tokens than HTML)
- **XML-like tags** provide unambiguous section boundaries that prevent instruction bleeding — AI models parse them better than free-form prose
- **JSON** is reserved for machine-readable contracts, not instructional specs
- **YAML** is best for configuration files and conformance test suites

No conversion to pure JSON/YAML. Output stays in Markdown with XML-like tag injection for section-level strictness.

---

## Structured Elements in Compiled Output

- XML-like wrapper tags for every major section (e.g., `<purpose>`, `<scope>`, `<constraints>`, `<invariants>`, `<failure_modes>`, `<validation>`, `<relationships>`, `<guarantees>`)
- Explicit `IF/THEN/ELSE` blocks for conditional logic
- Numbered lists for sequential instructions
- Key-value pairs for inputs/outputs
- Priority markers (`[P0]`, `[P1]`, `[P2]`) for instruction importance
- Negative constraints explicitly listed
- Cross-reference anchors with explicit IDs linking between sections

---

## File Naming

- **Skills:** `SKILL.human.md` → source file, `SKILL.md` → compiled output
- **Other documents:** `{name}.md` → source, `{name}.compiled.md` → compiled output
- Always same directory as source for traceability
- Existing `.compiled.md` files are overwritten (no versioning, no suffix incrementing)

---

## Traceability Header

- Format: `<!-- compiled from: {relative_source_path} | {ISO 8601 timestamp} -->`
- Placed as first line of compiled file
- HTML comment format ensures AI agents skip it naturally
- Timestamp: `YYYY-MM-DDTHH:mm:ssZ` (UTC)
- Example: `<!-- compiled from: skills/sas-example/SKILL.human.md | 2026-04-13T14:30:00Z -->`

---

## Size and Token Limits

- **Size irrelevant** — larger output acceptable if it improves agent comprehension
- **No token limit enforcement** — users responsible for fitting within their agent's context window

---

*Last updated: 13 April 2026*
