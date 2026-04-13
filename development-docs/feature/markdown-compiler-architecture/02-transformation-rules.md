# 02 — Transformation Rules

## Goal

Convert human-readable markdown to machine-optimized markdown (not human-readable), like C++ → assembly. Remove everything that doesn't directly contribute to instruction execution, guideline adherence, or structured information parsing.

---

## Syntactic Transformations (structural/format-level)

- Strip filler phrases, polite language, conversational transitions, rhetorical questions
- Remove redundant restatements
- Collapse verbose examples into minimal forms
- Replace narrative sentences with bullets, tables, or key-value pairs
- Standardize formatting: consistent headings, uniform lists, explicit delimiters
- Remove decorative markdown (emphasis for tone, ellipses, exclamation marks)
- Compress whitespace, remove unnecessary blank lines
- Convert prose process descriptions into numbered steps
- Replace ambiguous references ("this", "that", "the above") with explicit identifiers

---

## Semantic Transformations (meaning/structure-level)

- Reorganize narrative flow into logical instruction hierarchies
- Extract implicit constraints/rules, make them explicit
- Convert conditional prose into explicit IF/THEN/ELSE structures
- Tag semantic roles: inputs, outputs, constraints, invariants, failure modes, edge cases
- Flatten nested explanations into direct assertions
- Replace examples with generalized patterns/schemas where possible
- Add priority/weight markers for instruction importance
- Resolve ambiguity: replace "might", "could", "should consider" with definitive directives or explicit optionality
- Group related constraints (even if scattered in source)
- Add cross-references between sections using explicit anchors/IDs

---

## Filler vs. Context Classification

The preprocessor applies an 8-category classification to every block of content:

| Classification | Action | Rule |
|---|---|---|
| **Verbose filler** | REMOVE | Polite phrases, conversational transitions, rhetorical questions, exclamation marks, decorative emphasis, ellipses, self-referential agent language |
| **Redundant restatement** | REMOVE | Same information repeated with no new constraint or detail |
| **Justification/provenance** | COMPRESS to 1 line | "Why" explanations → `[rationale: X]` |
| **Hedging language** | RESOLVE | Replace with definitive directive OR `[optional: X]` |
| **Contextual reasoning** | COMPRESS but PRESERVE | Conditional logic, edge cases, cross-section dependencies, terminology definitions |
| **Examples** | GENERALIZE | Replace with minimal schema/pattern + reference |
| **Instructions/constraints/rules** | PRESERVE + RESTRUCTURE | Any statement telling the agent what to do or not do |
| **Metadata/provenance** | COMPRESS | Version history, author info → single-line header |

**Decision heuristic:** If content answers "what should the agent DO?" or "what must it NOT DO?" → preserve. If it answers "why did humans write it this way?" → compress. If it's social lubricant → remove.

---

*Last updated: 13 April 2026*
