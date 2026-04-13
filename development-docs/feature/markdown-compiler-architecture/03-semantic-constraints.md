# 03 — Semantic Constraints

## Semantic Constraint Framework Integration

**CRITICAL:** The Semantic Constraint Framework already defines exactly what a "properly constrained" AI document looks like. The compiler's output **MUST** conform to this standard.

---

## 10 Universal Required Sections

Every compiled output **MUST** include all 10 universal sections:

1. **Purpose** — why this artifact exists
2. **Scope** — what it covers and what it excludes
3. **Inputs** — explicit sources, formats, and preconditions
4. **Outputs** — artifacts produced or state changes made
5. **Constraints** — hard boundaries on behavior, data, and side effects
6. **Invariants** — conditions that must hold across all execution paths
7. **Failure Modes** — how missing info, errors, and edge cases are handled
8. **Validation Strategy** — how correctness is verified
9. **Relationships** — dependencies, ordering, and boundaries with other artifacts
10. **Guarantees** — postconditions the artifact commits to

Plus **type-specific sections** (Skills have Invocation Conditions/Forbidden Usage/Phase Separation; Plans have Data Model/Architecture/Key Operations/etc.)

---

## Declarative Language Rules

Compiled output **MUST** use declarative language, not suggestions:
- ✅ **Prefer:** `must`, `must not`, `required`, `forbidden`, `guaranteed`
- ❌ **Avoid:** `try to`, `ideally`, `if possible`, `approximately`

---

## Uncertainty Handling

If something is not decided in source:
- Do not guess
- Do not imply defaults
- Do not leave it implicit
- Instead write: "This is currently unspecified and must be decided before use."

---

## Negative Constraints

Compiled output **MUST** explicitly state what the agent must **not** do. Blocking unwanted behavior is more effective than only prescribing desired behavior.

---

## KERNEL Constraint Framework

All compiled artifacts must satisfy:

| Letter | Principle | Purpose |
|--------|-----------|---------|
| **K** | Keep it simple | Single, unambiguous primary goal — prevents scope creep |
| **E** | Easy to verify | Pre-defined success metrics and quality checkpoints |
| **R** | Reproducible results | Identical inputs must produce equivalent outputs |
| **N** | Narrow scope | Explicit domain and task limits — no general-purpose behavior |
| **E** | Explicit constraints | Hard boundaries on data sources, tools, and capabilities |
| **L** | Logical structure | Strict structural, token, or styling boundaries |

---

## Human vs AI Optimization Dial

The framework defines two modes — the compiler produces the AI-optimized end:

| Human-Optimized | AI-Optimized |
|-----------------|--------------|
| Explanatory prose | Minimal prose |
| Friendly narrative | Dense constraints |
| Justification and context | Explicit guarantees |
| Designed for onboarding | Zero ambiguity |

**Same meaning, different surface. The compiler controls the dial.**

---

*Last updated: 13 April 2026*
