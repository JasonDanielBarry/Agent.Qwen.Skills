# 01 — Overview

## Compiler Goal

The `sas-semantic-compiler` aggressively optimizes markdown documents for AI agent consumption — improving instruction execution, guideline adherence, and structured information parsing. Human readability is NOT a concern.

**Compiler model:** Follows C/C++ paradigm — preprocessing phase (macro expansion, file inclusion, conflict detection) followed by compilation phase (machine-optimized output). Ambiguities or errors **HALT** compilation entirely, forcing users to resolve contradictions before producing compiled output. **Constraining probabilistic systems tends toward deterministic outputs.**

---

## Scope

### Target Documents
- Skill files (SKILL.md and related)
- Implementation plans
- Any markdown with instructions, guidelines, or structured info for AI agents

### Excluded Documents
- README files
- Documentation for human end-users
- Any human-consumption documents

---

*Last updated: 13 April 2026*
