# 11 — Operational Concerns

## Source Control

- On-demand generation only (not automatic)
- Never edit compiled files — always regenerate from source
- Humans edit source files only
- No decompiler needed
- No incremental compilation — full top-to-bottom pipeline run for consistency/determinism (6 stages, not partial re-runs)

---

## Invocation

- Manual only (intentional user action required)
- CLI command invokable
- Callable function within other skills/agents
- Processes single files or entire directories

---

## Skill Characteristics

### Standalone
- Fully independent — no dependencies on other skills
- No external tools/libraries required
- **Agent and skill itself are the entire compilation engine**
- Can be used alongside other skills but doesn't integrate directly

### Documentation
- Before/after examples in **README.md** (not SKILL.md)
- Skill's own SKILL.md will be **compiled** following same pattern it produces

### Security
- No additional concerns beyond normal agent access
- If agent can read a document, it's eligible for compilation
- **User responsibility** — if someone leaks sensitive information, it's their problem

---

## Naming

- **Skill name:** `sas-semantic-compiler`
- Follows `sas-` prefix convention

---

*Last updated: 13 April 2026*
