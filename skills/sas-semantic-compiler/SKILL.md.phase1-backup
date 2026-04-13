---
name: sas-semantic-compiler
description: Compile markdown documents (.human.md) into AI-optimized output. Transforms human-readable markdown into machine-optimized form via a 6-stage pipeline with sub-agent isolation. Invokes compilation of skills, plans, and agent-directed documents.
---

<!-- compiled from: skills/sas-semantic-compiler/SKILL.human.md | 2026-04-13T10:30:00Z -->

## Purpose

Compile `.human.md` source documents into AI-optimized `.md` output via a 6-stage pipeline with sub-agent isolation. Output is designed exclusively for AI agent execution — human readability is not a concern.

## Scope

- Target: Skill files, implementation plans, markdown with instructions/guidelines/structured info for AI agents
- Excluded: README files, human end-user documentation, human-consumption documents

## Inputs

- Source `.human.md` file path (required)
- Compilation skill instructions (`SKILL.md`) loaded by each sub-agent
- Architecture reference documents in `architecture/` folder

## Outputs

- Compiled output file (`.compiled.md` or `SKILL.md` for skills)
- Persistent `.DocName.compilation/` folder with all intermediate stage files

## Constraints

- Must not edit compiled files — always regenerate from source
- Must not commit `.compilation/` folders to git
- Must not reuse sub-agents across stages/passes — fresh agent per stage/pass is required
- Must not proceed to compilation if preprocessor finds conflicts, contradictions, or ambiguities
- Must not guess or imply defaults for unspecified behavior
- Must halt pipeline immediately on any error — no partial output
- Must not reference content from stages other than the designated input files

## Invariants

- Each stage/pass executes in a separate sub-agent with zero context from prior stages
- Sub-agent lifecycle: Spawn → Load (skill + previous stage output) → Process → Write → Terminate
- Preprocessor must complete fully without errors before compiler runs
- Each stage receives only the previous stage's output as input — nothing else
- `.compilation/` folders retained after successful compilation for auditability

## Failure Modes

| Stage | Code | Meaning |
|-------|------|---------|
| Preprocessor | `PRE_001` | Referenced file not found |
| | `PRE_002` | Conflicting/contradictory instructions or circular reference |
| | `PRE_003` | Ambiguous reference (multiple possible targets) |
| | `PRE_004` | Invalid directive syntax |
| Structural Parse | `DST_001` | Malformed markdown (unclosed block) |
| | `DST_002` | Empty document (no parseable content) |
| IR Extraction | `IR_001` | Unable to classify content into any semantic role |
| | `IR_002` | Circular reference detected |
| Optimization | `OPT_001` | All content classified as filler (nothing to preserve) |
| | `OPT_002` | Priority conflict (two P0 constraints contradict) |
| Constraint Injection | `SCI_001` | Too many unspecified sections (>3 universal sections empty) |
| | `SCI_002` | KERNEL validation failed |
| Code Generation | `GEN_001` | Output path not writable |
| | `GEN_002` | Template rendering failure |

**Error handling:** Any error → pipeline halts immediately. Error reported with stage name, code, description, and source line number. All intermediate files retained in `.DocName.compilation/` for diagnosis. No partial output written to final destination.

## Validation Strategy

### Tier 1 — Structural Check (automatic, fast, deterministic)

- Verify all 10 universal sections present with XML-like tags
- Verify all type-specific sections present (based on document type)
- Verify declarative language used (scan for "try to", "ideally", "if possible", "approximately")
- Verify negative constraints exist
- Verify uncertainty explicitly declared (not left implicit)
- Verify KERNEL framework compliance
- Fail = compilation fails with specific missing-element errors

### Tier 2 — Functional Equivalence Test (deferred to Phase 4)

- Agent-based comparison of source vs compiled output on representative tasks
- Threshold: 90%+ task equivalence across 5+ benchmark tasks

## Relationships

- Depends on: `architecture/` folder (12 reference documents)
- Produces: compiled output in same directory as source
- Cross-referenced documents compiled together (transitive, max depth 5)
- Circular references halt compilation with `PRE_002`

## Guarantees

- Deterministic output — identical input produces equivalent output
- Same meaning, different surface — compiler controls human-to-AI optimization dial
- All intermediate files permanently persisted for auditability and error diagnosis
- Each phase produces a working, usable compiler

---

## Sub-Agent Execution Model

**Invariant — Fresh sub-agent per stage/pass:** Each of the 6 pipeline stages and each of the 3 Stage 4 optimization passes MUST execute in a separate sub-agent. Reusing a single agent across multiple stages or passes is forbidden. Sub-agent termination (process exit) is the only mechanism that provides structural context isolation.

### Execution Sequence (8 sub-agent invocations)

| Execution Unit | Agent | Input | Output |
|----------------|-------|-------|--------|
| Stage 1 — Preprocessor | Agent 1 | Source `.human.md` file | `preprocessed.md` + `annotations.json` |
| Stage 2 — Structural Parse | Agent 2 | Stage 1 output files | `dst.json` |
| Stage 3 — Semantic IR Extraction | Agent 3 | Stage 2 output file | `ir.json` |
| Stage 4 Pass 1 — Strip & Compress | Agent 4 | Stage 3 output file | `ir-pass-1.json` |
| Stage 4 Pass 2 — Tag & Structure | Agent 5 | Pass 1 output file | `ir-pass-2.json` |
| Stage 4 Pass 3 — Cross-Reference & Group | Agent 6 | Pass 2 output file | `ir-pass-3.json` |
| Stage 5 — Semantic Constraint Injection | Agent 7 | Pass 3 output file | `ir-augmented.json` |
| Stage 6 — Code Generation | Agent 8 | Stage 5 output file | `output-draft.md` |

### Sub-Agent Lifecycle

Every sub-agent follows: **Spawn → Load → Process → Write → Terminate**

1. **Spawn** — parent agent creates a fresh sub-agent
2. **Load** — sub-agent receives: (a) the compilation skill instructions (SKILL.md), and (b) the output files from the previous stage/pass on disk. Nothing else.
3. **Process** — sub-agent performs its stage's transformation per the pipeline specification
4. **Write** — sub-agent writes its output files to the `.DocName.compilation/` folder
5. **Terminate** — sub-agent exits. Process destruction = guaranteed context destruction.

### Zero Initial Context

Before the first sub-agent spawns, the agent has zero context about the document being compiled, its content, or any compilation stage.

### Sole Information Boundary

The only information a sub-agent has about its stage is the output files from the previous stage loaded from disk. The sub-agent MUST NOT reference, recall, or infer content from any other stage's output.

---

## Compilation Pipeline — 6 Stages

### Stage 1 — Preprocessor

- Macro expansion, file inclusion, conflict detection, filler identification, contextual reasoning compression
- Outputs: `preprocessed.md` + `annotations.json` → `stage-1-preprocessor/`
- File inclusion: referenced `.md` files inlined with boundaries (`<!-- begin included: {path} -->` ... `<!-- end included: {path} -->`)
- Missing referenced files → halt with `PRE_001`
- Conflicts/contradictions → halt with `PRE_002`, alert user to resolve

### Stage 2 — Structural Parse (DST)

- Converts preprocessed source into Document Structure Tree
- DSTNode: `{type, level?, content, children[], metadata: {source_line, section_path, semantic_role?}}`
- Types: heading, paragraph, list, ordered_list, table, code_block, blockquote, thematic_break, link, image, html
- Traversal: depth-first, pre-order
- Output: `dst.json` → `stage-2-dst/`

### Stage 3 — Semantic IR Extraction

- Flattens DST into linear sequence of semantic units, all markdown formatting stripped
- IRUnit: `{id, type, section, content, priority, conditions[], references[], negation}`
- Types: instruction, constraint, fact, example, rationale, edge_case, invariant, failure_mode, guarantee, input, output, relationship, validation, metadata, filler
- Priority: P0 (must obey), P1 (important), P2 (nice-to-have)
- Semantic role assignment by keyword heuristics + structural context
- Output: `ir.json` → `stage-3-ir/`

### Stage 4 — Optimization Passes

- Pass 1 — Strip & Compress:
  - Remove all `type: "filler"` IRUnits
  - Compress `type: "rationale"` units to `[rationale: X]`
  - Compress `type: "metadata"` units to single-line header
  - Merge adjacent IRUnits of same type in same section
  - Strip decorative formatting
  - Output: `ir-pass-1.json` → `stage-4-optimized/`

- Pass 2 — Tag & Structure:
  - Assign explicit `id` to every IRUnit (`sec-{section}-{index}`)
  - Add `priority`: P0 for constraints/invariants/negative constraints, P1 for instructions/failure modes, P2 for examples/relationships
  - Convert conditional prose into explicit `Condition` objects (`{predicate, then, else}`)
  - Mark negative constraints (`negation: true`)
  - Wrap examples in generalized schema patterns
  - Output: `ir-pass-2.json` → `stage-4-optimized/`

- Pass 3 — Cross-Reference & Group:
  - Resolve `references` by matching anchors/IDs to IRUnit IDs
  - Group related IRUnits by semantic affinity (constraints with edge cases, instructions with failure modes)
  - Add cross-reference links between sections
  - Deduplicate IRUnits with identical content in same section
  - Output: `ir-pass-3.json` → `stage-4-optimized/`

### Stage 5 — Semantic Constraint Injection

- Group IRUnits by `section` field into section map
- For each of the 10 universal sections: if IRUnits exist → use and reorganize; if none → inject placeholder: `<section_name> — This is currently unspecified and must be decided before use.`
- Add type-specific sections (Skill detection via `name:` + `description:` in frontmatter → Invocation Conditions, Forbidden Usage, Phase Separation)
- Convert ALL content to declarative language (apply hedging resolution)
- Ensure at least one negative constraint exists — if none detected, inject: "Do not guess or imply defaults for unspecified behavior."
- Run KERNEL validation checklist against section map
- Output: `ir-augmented.json` → `stage-5-constrained/`

### Stage 6 — Code Generation

- Emit traceability header: `<!-- compiled from: {source_path} | {timestamp} -->`
- For each of the 10 universal sections (canonical order):
  - Emit `## {Section Name}`
  - Emit `<{section_tag}>` wrapper (e.g., `<purpose>`, `<constraints>`, `<invariants>`)
  - Emit each IRUnit:
    - Priority marker (`[P0]`) for P0 units
    - Bullet for instructions/constraints
    - Prose for facts/rationale
    - `IF/THEN/ELSE` block if `conditions` present
    - Negative framing if `negation: true`
  - Emit `</{section_tag}>`
- Emit type-specific sections the same way
- Write to `{output_path}`
- Output: `output-draft.md` → `stage-6-generated/`, then copied to final output path

---

## Filler Classification (8 Categories)

| Classification | Action |
|---|---|
| Verbose filler | REMOVE |
| Redundant restatement | REMOVE |
| Justification/provenance | COMPRESS to 1 line → `[rationale: X]` |
| Hedging language | RESOLVE → definitive directive OR `[optional: X]` |
| Contextual reasoning | COMPRESS but PRESERVE |
| Examples | GENERALIZE → minimal schema/pattern |
| Instructions/constraints/rules | PRESERVE + RESTRUCTURE |
| Metadata/provenance | COMPRESS → single-line header |

**Decision heuristic:** "What should the agent DO?" or "what must it NOT DO?" → preserve. "Why did humans write it this way?" → compress. Social lubricant → remove.

---

## 10 Universal Required Sections

1. Purpose — why this artifact exists
2. Scope — what it covers and excludes
3. Inputs — explicit sources, formats, preconditions
4. Outputs — artifacts produced or state changes made
5. Constraints — hard boundaries on behavior, data, side effects
6. Invariants — conditions holding across all execution paths
7. Failure Modes — handling of missing info, errors, edge cases
8. Validation Strategy — how correctness is verified
9. Relationships — dependencies, ordering, boundaries
10. Guarantees — postconditions committed to

Plus type-specific sections: Skills (Invocation Conditions, Forbidden Usage, Phase Separation), Plans (Data Model, Architecture, Key Operations).

---

## Syntactic Transformations

- Strip filler phrases, polite language, conversational transitions, rhetorical questions
- Remove redundant restatements
- Collapse verbose examples
- Replace narrative with bullets/tables/key-value pairs
- Standardize formatting, remove decorative markdown
- Compress whitespace, remove unnecessary blank lines
- Convert prose to numbered steps
- Replace ambiguous references with explicit identifiers

## Semantic Transformations

- Reorganize narrative into logical instruction hierarchies
- Extract implicit constraints, make explicit
- Convert conditionals to IF/THEN/ELSE
- Tag semantic roles
- Flatten nested explanations into direct assertions
- Resolve ambiguity: "might"/"could"/"should" → definitive directives
- Group related constraints (even if scattered in source)
- Add cross-references between sections using explicit anchors/IDs

---

## Declarative Language Rules

- Use: `must`, `must not`, `required`, `forbidden`, `guaranteed`
- Avoid: `try to`, `ideally`, `if possible`, `approximately`

## Uncertainty Handling

If unspecified: write "This is currently unspecified and must be decided before use." Do not guess. Do not imply defaults.

## Negative Constraints

Must explicitly state what the agent must not do.

## KERNEL Framework

| Letter | Principle |
|--------|-----------|
| K | Keep it simple — single, unambiguous primary goal |
| E | Easy to verify — pre-defined success metrics |
| R | Reproducible results — identical inputs → equivalent outputs |
| N | Narrow scope — explicit domain and task limits |
| E | Explicit constraints — hard boundaries on data, tools, capabilities |
| L | Logical structure — strict structural/styling boundaries |

---

## File Structure

```
X/
├── DocX.human.md               ← source
├── DocX.compiled.md            ← compiled output
└── .DocName.compilation/
    ├── stage-1-preprocessor/
    ├── stage-2-dst/
    ├── stage-3-ir/
    ├── stage-4-optimized/
    ├── stage-5-constrained/
    └── stage-6-generated/
```

**Source stem derivation:** `SKILL.human.md` → `.SKILL.compilation/`, `release-plan.human.md` → `.release-plan.compilation/`

**Git ignore:** `*.compilation/`

---

## Error Diagnosis

1. Read error message → identify failing stage + code
2. Open corresponding stage folder in `.DocName.compilation/`
3. Inspect output files
4. If needed, inspect previous stage's output to verify inputs
5. Fix source document and recompile

---

## Operational Rules

- Manual invocation only (intentional user action required)
- Full pipeline run — no incremental compilation
- Never edit compiled files — regenerate from source
- Humans edit source files only
- Standalone skill — no dependencies on other skills, no external tools required
- Processes single files or entire directories

---

## Implementation Status

| Feature | Status |
|---------|--------|
| Stage 1-3 full implementation | Implemented (Phase 1) |
| Stage 4 Pass 1 (strip filler) | Implemented (Phase 1) |
| Stage 4 Pass 2 (tagging, IF/THEN/ELSE) | Implemented (Phase 2) |
| Stage 4 Pass 3 (cross-reference resolution) | Implemented (Phase 2) |
| XML-like tag wrapping | Implemented (Phase 2) |
| Tier 1 structural validation | Implemented (Phase 2) |
| Tier 2 functional equivalence | Deferred Phase 4 |
| Self-compilation | Deferred Phase 3 |
| Separate verification skill | Deferred Phase 4 |

---

## Design Principles

- Trust file persistence over AI context window memory
- Aggressive from the start — full 6-stage pipeline
- HALT on errors — no partial output, no guessing
- Deterministic output — constraining probabilistic systems → deterministic results
- Same meaning, different surface
