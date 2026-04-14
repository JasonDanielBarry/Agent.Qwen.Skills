---
name: sas-semantic-compiler
description: Aggressively optimize markdown documents for AI agent consumption — converts human-readable markdown into machine-optimized SKILL.md via a 6-stage pipeline modeled on the C/C++ compiler.
---
<!-- compiled from: skills/sas-semantic-compiler/SKILL.human.md | 2026-04-14T00:00:00Z -->

<purpose>
The `sas-semantic-compiler` converts human-readable markdown into machine-optimized markdown for AI agent execution. Human readability is NOT a concern. Ambiguities or errors **HALT** compilation entirely. Follows the C/C++ compiler model: preprocessing phase (macro expansion, file inclusion, conflict detection) followed by compilation phase (machine-optimized output).
</purpose>

<scope>
Target: Skill files (SKILL.md), implementation plans, any markdown with instructions/guidelines/structured info for AI agents. Excluded: README files, human end-user documentation, any human-consumption documents.
</scope>

<inputs>
Source `.human.md` file path; referenced documents for cross-resolution (max depth 5).
</inputs>

<outputs>
Compiled `.md` file in same directory as source; intermediate files in `.DocName.compilation/` folder.
</outputs>

<rules>
[P0] Conflicts, contradictions, or ambiguities in source → document MUST NOT compile; user MUST be alerted to resolve.
[P0] Preprocessor must complete FULLY without errors before compiler can run.
[P0] This compilation pipeline MUST execute as 8 separate sub-agent invocations. A single agent processing all stages in sequence is forbidden. Each sub-agent processes one stage, writes output to disk, and terminates.
[P0] Forbidden: reusing a single agent across multiple stages. Skipping any stage. Running stages out of order. Reading from multiple stage outputs simultaneously.
[P0] Any error → pipeline halts immediately. No partial output written to final destination.
[P0] Do not guess, imply defaults, or leave unspecified behavior implicit when source content is unclear.
[P1] All compiled output MUST use declarative language: `must`, `must not`, `required`, `forbidden`, `guaranteed`. Avoid: `try to`, `ideally`, `if possible`, `approximately`.
[P1] Compiled output MUST explicitly state negative constraints — what the agent must not do.
[P1] All 10 universal sections MUST be present in compiled output.
[P1] KERNEL framework compliance required (K=Keep it simple, E=Easy to verify, R=Reproducible, N=Narrow scope, E=Explicit constraints, L=Logical structure).
[P2] Size/token limits not enforced — users responsible for fitting within their agent's context window.
</rules>

<phase_separation>
## Sub-Agent Execution Model

### 8 SUB-AGENT INVOCATIONS — 6 PIPELINE STAGES + 3 OPTIMIZATION PASSES

**P0 INVARIANT:** This compilation pipeline MUST execute as **8 separate sub-agent invocations**. A single agent processing all stages in sequence is **forbidden**. Each sub-agent processes one stage, writes output to disk, and terminates. Context isolation via process exit is the only guarantee against cross-stage contamination.

**Execution Sequence (parent agent orchestrator — follow these steps in order):**

1. **Spawn Agent 1 (Preprocessor):** Load this SKILL.md + source file (`.human.md`). Write `preprocessed.md` + `annotations.json` to `.DocName.compilation/stage-1/`. Terminate.
2. **Spawn Agent 2 (Structural Parse):** Load this SKILL.md + `preprocessed.md` + `annotations.json`. Write `dst.json` to `.DocName.compilation/stage-2/`. Terminate.
3. **Spawn Agent 3 (Semantic IR Extraction):** Load this SKILL.md + `dst.json`. Write `ir.json` to `.DocName.compilation/stage-3/`. Terminate.
4. **Spawn Agent 4 (Pass 1 — Strip & Compress):** Load this SKILL.md + `ir.json`. Write `ir-pass-1.json` to `.DocName.compilation/stage-4/`. Terminate.
5. **Spawn Agent 5 (Pass 2 — Tag & Structure):** Load this SKILL.md + `ir-pass-1.json`. Write `ir-pass-2.json` to `.DocName.compilation/stage-4/`. Terminate.
6. **Spawn Agent 6 (Pass 3 — Cross-Reference & Group):** Load this SKILL.md + `ir-pass-2.json`. Write `ir-pass-3.json` to `.DocName.compilation/stage-4/`. Terminate.
7. **Spawn Agent 7 (Semantic Constraint Injection):** Load this SKILL.md + `ir-pass-3.json`. Write `ir-augmented.json` to `.DocName.compilation/stage-5/`. Terminate.
8. **Spawn Agent 8 (Code Generation):** Load this SKILL.md + `ir-augmented.json`. Write `SKILL.md` (compiled output) to source directory. Terminate.

**After all 8 stages:** Run Tier 1 structural validation on the compiled output. If validation fails, report errors and halt.

**Forbidden:** Reusing a single agent across multiple stages. Skipping any stage. Running stages out of order. Reading from multiple stage outputs simultaneously.

### Sub-Agent Lifecycle

Every sub-agent follows: **Spawn → Load → Process → Write → Terminate**

1. **Spawn** — parent agent creates a fresh sub-agent
2. **Load** — sub-agent receives: (a) this SKILL.md (compilation instructions), and (b) the output files from the previous stage/pass on disk. Nothing else.
3. **Process** — sub-agent performs its stage's transformation per the pipeline specification
4. **Write** — sub-agent writes its output files to the `.DocName.compilation/` folder
5. **Terminate** — sub-agent exits. Process destruction = guaranteed context destruction.

### Zero Initial Context

Before the first sub-agent spawns, the agent has zero context about the document being compiled, its content, or any compilation stage.

### Sole Information Boundary

The only information a sub-agent has about its stage is the output files from the previous stage loaded from disk. The sub-agent MUST NOT reference, recall, or infer content from any other stage's output.
</phase_separation>

<invariants>
[P0] Each stage receives the previous stage's output as its sole input. No stage reads from disk directly (except Stage 1). No stage writes to disk directly (except Stage 6).
[P0] Process destruction = guaranteed context destruction between sub-agents.
[P0] Source file stem derivation: `skills/sas-endsession/SKILL.human.md` → `.SKILL.compilation/`; `plans/release-plan.human.md` → `.release-plan.compilation/`. If two source files share the same stem, use the full stem.
[P0] All `.compilation/` folders are reproducible build artifacts and must be git-ignored. Compiled output (e.g., `SKILL.md`) and source (e.g., `SKILL.human.md`) are committed. The compilation folder is never committed.
[P0] Never edit compiled files — always regenerate from source. Humans edit source files only. No incremental compilation — full top-to-bottom pipeline run.
[P1] Output path resolution: always same directory as source file. Skills (`SKILL.human.md`): output is `SKILL.md` in same directory. All other documents: output is `{name}.compiled.md`. If resolved path exists, overwrite it.
</invariants>

<architecture_reference>

| Document | Content |
|----------|---------|
| [01-overview](./architecture/01-overview.md) | Compiler goal, scope, C/C++ model analogy |
| [02-transformation-rules](./architecture/02-transformation-rules.md) | Syntactic + semantic transformations, 8-category filler classification |
| [03-semantic-constraints](./architecture/03-semantic-constraints.md) | 10 universal sections, declarative language, KERNEL framework |
| [04-pipeline-architecture](./architecture/04-pipeline-architecture.md) | 6-stage pipeline, sub-agent model, stage specs, I/O contracts, error codes |
| [05-compilation-file-structure](./architecture/05-compilation-file-structure.md) | Persistent folder structures, file JSON schemas, naming conventions |
| [06-execution-workflow](./architecture/06-execution-workflow.md) | Sub-agent orchestration, lifecycle, error diagnosis workflow |
| [07-cross-reference-resolution](./architecture/07-cross-reference-resolution.md) | Reference detection, transitive resolution, compilation ordering |
| [08-output-format](./architecture/08-output-format.md) | Markdown + XML tags, traceability headers, naming conventions |
| [09-validation](./architecture/09-validation.md) | Two-tier validation, success metrics, error handling |
| [10-bootstrap-strategy](./architecture/10-bootstrap-strategy.md) | Phase 1-4 progression |
| [11-operational-concerns](./architecture/11-operational-concerns.md) | Source control, invocation, security, naming |

</architecture_reference>

<pipeline_stages>

## The 6-Stage Pipeline

```
Source (.human.md)
   ↓
[1] Preprocessor
   - Macro expansion, file inclusion, conflict detection, filler identification, contextual reasoning compression
   - Outputs: Cleaned source + preprocessing annotations
   ↓
[2] Structural Parse (DST)
   - Converts markdown into a traversable Document Structure Tree
   ↓
[3] Semantic IR Extraction
   - Flattens tree into semantic units: instructions, constraints, facts, edge cases
   - Strips all markdown formatting syntax
   ↓
[4] Optimization Passes
   - Pass 1: Remove filler, compress context, resolve ambiguity
   - Pass 2: Add explicit tags, priority markers, IF/THEN/ELSE structures
   - Pass 3: Cross-reference linking, constraint grouping
   ↓
[5] Semantic Constraint Injection
   - Ensures all 10 universal sections present
   - Adds type-specific sections based on document type
   - Converts all language to declarative form
   - Adds negative constraints
   - Declares uncertainty explicitly
   - Validates against KERNEL framework
   ↓
[6] Code Generation
   - Emits final output in target format (Markdown + XML tags)
   - Adds traceability header + timestamp
```

### C++ Comparison

| C++ Stage | Markdown Equivalent | Keep? | Why |
|-----------|---------------------|-------|-----|
| Preprocessor | Preprocessor | Yes | Handles includes, macros, early conflict detection |
| AST | Document Structure Tree | Simplified | Gives passes a tree to traverse, no type/scope complexity |
| IR | Semantic IR | Yes | Strips formatting, isolates pure meaning/instructions |
| Optimization | Multi-pass optimizer | Yes | Each pass does one thing well (strip, structure, tag) |
| — | Semantic Constraint Injection | NEW | Ensures 10 universal sections, declarative language, KERNEL validation |
| Machine Code | Target Format | Yes | Final AI-readable output |
| Linker | None | Drop | Preprocessor already resolves cross-doc references |

### Stage 1 — Preprocessor

Modeled after C/C++ preprocessor. Outputs: `preprocessed.md` + `annotations.json`.

[P0] Conflict detection: conflicts/contradictions/ambiguities → document MUST NOT compile, user MUST be alerted.
[P0] File inclusion: referenced document found → include with boundaries (`<!-- begin included: {path} -->` ... `<!-- end included: {path} -->`). NOT found → halt with `PRE_001` error.
[P0] Gatekeeper rule: preprocessor must complete FULLY without errors before compiler can run.
[P0] Cross-reference resolution: detects references (Markdown links or explicit paths to other `.md` files); transitive resolution (A→B→C compiles all three), max depth 5; referenced documents compiled first (leaves before roots); circular references (A→B→A) halt with `PRE_002` error.

**Error codes:**

| Code | Meaning |
|------|---------|
| `PRE_001` | Referenced file not found |
| `PRE_002` | Conflicting/contradictory instructions or circular reference |
| `PRE_003` | Ambiguous reference (multiple possible targets) |
| `PRE_004` | Invalid directive syntax |

### Stage 2 — Structural Parse (DST)

Converts preprocessed source into a Document Structure Tree.

**DSTNode schema:**
```
DSTNode {
  type: "heading" | "paragraph" | "list" | "ordered_list" | "table" | "code_block" | "blockquote" | "thematic_break" | "link" | "image" | "html"
  level: int?              // For headings only (1-6)
  content: string          // Raw text/markdown of the block
  children: DSTNode[]      // For lists: items; for headings: following blocks until next same/higher level heading
  metadata: {
    source_line: int       // Original line number for error reporting
    section_path: string   // Full heading path (e.g., "Architecture > Pipeline")
    semantic_role: string? // Added during Stage 3
  }
}
```

[P0] `heading` drives tree hierarchy. `table` and `code_block` preserved verbatim. `thematic_break` discarded in Stage 3. `link` preserved with URL extraction. `html` preserved verbatim.
[P0] Traversal: depth-first, pre-order. Parent pointer available for section context.

**Error codes:**

| Code | Meaning |
|------|---------|
| `DST_001` | Malformed markdown (unclosed block) |
| `DST_002` | Empty document (no parseable content) |

### Stage 3 — Semantic IR Extraction

Flattens DST into linear sequence of semantic units, all markdown formatting stripped.

**IRUnit schema:**
```
IRUnit {
  id: string                // e.g., "sec-purpose-001"
  type: "instruction" | "constraint" | "fact" | "example" | "rationale" | "edge_case" | "invariant" | "failure_mode" | "guarantee" | "input" | "output" | "relationship" | "validation" | "metadata" | "filler"
  section: string           // Target section (e.g., "Purpose", "Constraints")
  content: string           // Cleaned text, no markdown syntax
  priority: "P0" | "P1" | "P2"  // P0 = must obey, P1 = important, P2 = nice-to-have
  conditions: Condition[]   // IF/THEN/ELSE conditions gating this unit
  references: string[]      // IDs of other IRUnits referenced
  negation: boolean         // True if negative constraint
}

Condition {
  predicate: string
  then: IRUnit[]
  else: IRUnit[]
}
```

**Semantic role assignment** by keyword heuristics + structural context:
- "must"/"must not"/"required"/"forbidden" → `constraint`
- "do"/"run"/"execute" → `instruction`
- "is"/"are"/"defines" → `fact`
- "for example"/"e.g." → `example`
- "because"/"since" → `rationale`
- "if"/"when"/"unless" → `edge_case`
- "always"/"invariant"/"holds" → `invariant`
- "fail"/"error"/"fallback" → `failure_mode`
- "guarantee"/"ensures"/"commits" → `guarantee`
- "input"/"source"/"precondition" → `input`
- "output"/"produces"/"result" → `output`
- "depends"/"relates" → `relationship`
- "verify"/"validate"/"test"/"check" → `validation`
- "version"/"author"/"date" → `metadata`
- "rule"/"policy" → `constraint` (alias mapping)
- "file_structure"/"directory_layout"/"folder" → `instruction` (alias mapping)
- Content under "Purpose" heading → `fact`; under "Validation Strategy" → `instruction`; under "Scope" → `fact` or `constraint`; under "Relationships" → `relationship`; under "Guarantees" → `guarantee`
- Everything else → classified by filler rules
- Type alias mapping: section names MUST NOT be used as semantic role types. If content matches multiple keywords, use structural context (section heading) as tiebreaker. If content matches no keyword, classify by nearest valid type based on functional role.

**Error codes:**

| Code | Meaning |
|------|---------|
| `IR_001` | Unable to classify content into any semantic role |
| `IR_002` | Circular reference detected |

### Stage 4 — Optimization Passes

**Pass 1 — Strip & Compress:**
- Remove all `type: "filler"` IRUnits
- Compress `type: "rationale"` units to `[rationale: X]`
- Compress `type: "metadata"` units to single-line header
- Merge adjacent IRUnits of same type in same section — **EXCEPT** (see Max Density Rule below)
- Strip decorative formatting
- **Max Density Rule:** Do NOT merge numbered step sequences, failure modes, edge cases, or constraints with distinct conditions. Each must remain as a separate IRUnit. When in doubt, do not merge.
- **Example preservation:** For procedural skills, retain at least one concrete example. Do not generalize all examples away.

**Pass 2 — Tag & Structure:**
- Assign explicit `id` to every IRUnit (`sec-{section}-{index}`)
- Add `priority`: P0 for constraints/invariants/negative constraints, P1 for instructions/failure modes, P2 for examples/relationships
- Convert conditional prose into explicit `Condition` objects
- Mark negative constraints (`negation: true`)
- Wrap examples in generalized schema patterns

**Pass 3 — Cross-Reference & Group:**
- Resolve `references` by matching anchors/IDs to IRUnit IDs
- Group related IRUnits by semantic affinity (constraints with edge cases, instructions with failure modes)
- Add cross-reference links between sections
- Deduplicate IRUnits with identical content in same section

**Error codes:**

| Code | Meaning |
|------|---------|
| `OPT_001` | All content classified as filler (nothing to preserve) |
| `OPT_002` | Priority conflict (two P0 constraints contradict) |

### Stage 5 — Semantic Constraint Injection

**Method:** Structural reorganization + template fill.

1. Group IRUnits by `section` field into `Map<string, IRUnit[]>`
2. IF IRUnits exist for a universal section → use and reorganize; IF none → inject placeholder: `<section_name> — This is currently unspecified and must be decided before use.`
3. Add type-specific sections:
   - Skill detection (`name:` + `description:` in frontmatter) → Invocation Conditions, Forbidden Usage, Phase Separation
   - Plan detection (timeline/milestone language) → Data Model, Architecture, Key Operations
4. Convert ALL content to declarative language (apply hedging resolution)
5. Ensure at least one negative constraint exists — IF none detected, inject: "Do not guess or imply defaults for unspecified behavior."
6. Run KERNEL validation checklist against section map

**Error codes:**

| Code | Meaning |
|------|---------|
| `SCI_001` | Too many unspecified sections (>3 universal sections empty) |
| `SCI_002` | KERNEL validation failed (specify which principle) |

### Stage 6 — Code Generation

**Output path resolution:** Always same directory as source file. Skills (`SKILL.human.md`): output is `SKILL.md` in same directory. All other documents (`{name}.md`): output is `{name}.compiled.md` in same directory. IF resolved path exists, overwrite it.

**Method:** Template-based rendering from augmented IR.

1. Emit traceability header: `<!-- compiled from: {source_path} | {timestamp} -->`
2. For each of the 10 universal sections (canonical order): emit `## {Section Name}`, emit `<{section_tag}>` wrapper, emit each IRUnit (priority marker for P0, bullet for instructions/constraints, prose for facts/rationale, `IF/THEN/ELSE` if conditions present, negative framing if `negation: true`), emit `</{section_tag}>`
3. Emit type-specific sections the same way
4. Write to resolved `{output_path}` in same directory as source.

**Error codes:**

| Code | Meaning |
|------|---------|
| `GEN_001` | Output path not writable |
| `GEN_002` | Template rendering failure |

</pipeline_stages>

<io_contracts>

### Per-Stage I/O Contracts

| Stage | Input | Output | Format |
|-------|-------|--------|--------|
| [1] Preprocessor | Source `.human.md` file path | Preprocessed source + annotation map | `(string, Map<string, Annotation[]>)` |
| [2] Structural Parse | Preprocessed source | DST (root node with children) | `DSTNode` tree |
| [3] Semantic IR Extraction | DST | Flat list of IRUnits | `IRUnit[]` |
| [4] Optimization Passes | IRUnits | Transformed IRUnits (filtered, tagged, linked) | `IRUnit[]` |
| [5] Semantic Constraint Injection | IRUnits | Augmented IRUnits with all 10 sections filled | `IRUnit[]` |
| [6] Code Generation | Augmented IRUnits | Final `.compiled.md` file | `string` → written to disk |

Each stage receives the previous stage's output as its sole input. No stage reads from disk directly (except Stage 1). No stage writes to disk directly (except Stage 6). Errors propagate up — any failure aborts the pipeline.

</io_contracts>

<error_propagation>

### Error Propagation Model

Every stage returns `Success(output)` or `Error(stage_name, code, message, context)`.

[P0] Any error → pipeline halts immediately. Error displayed with stage name, code, human-readable description, and source location (line number from DST metadata). All intermediate files up to the point of failure are retained in the `.DocName.compilation/` folder for diagnosis. No partial output written to final destination. User must fix source and retry.

**Diagnosis workflow:**
1. Read the error message to identify the failing stage
2. Open the corresponding stage folder in `.DocName.compilation/`
3. Inspect the output files to see what the stage produced
4. IF needed, inspect the previous stage's output to verify its inputs were correct
5. Fix the source document and recompile

</error_propagation>

<transformation_rules>

### Syntactic Transformations (structural/format-level)

- Strip filler phrases, polite language, conversational transitions, rhetorical questions
- Remove redundant restatements
- Collapse verbose examples into minimal forms
- Replace narrative sentences with bullets, tables, or key-value pairs
- Standardize formatting: consistent headings, uniform lists, explicit delimiters
- Remove decorative markdown (emphasis for tone, ellipses, exclamation marks)
- Compress whitespace, remove unnecessary blank lines
- Convert prose process descriptions into numbered steps
- Replace ambiguous references ("this", "that", "the above") with explicit identifiers

### Semantic Transformations (meaning/structure-level)

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

</transformation_rules>

<filler_categories>

### Filler Classification (8 Categories)

| Classification | Action | Rule |
|---|---|---|
| **Verbose filler** | REMOVE | Polite phrases, conversational transitions, rhetorical questions, exclamation marks, decorative emphasis, ellipses, self-referential agent language |
| **Redundant restatement** | REMOVE | Same information repeated with no new constraint or detail |
| **Justification/provenance** | COMPRESS to 1 line | "Why" explanations → `[rationale: X]` |
| **Hedging language** | RESOLVE | Replace with definitive directive OR `[optional: X]` |
| **Contextual reasoning** | COMPRESS but PRESERVE | Conditional logic, edge cases, cross-section dependencies, terminology definitions |
| **Examples** | GENERALIZE (keep 1+) | Replace with minimal schema/pattern + reference. **For procedural skills** (skills that tell an agent how to execute a task), retain at least one concrete worked example. Pure reference/data skills may generalize all examples. |
| **Instructions/constraints/rules** | PRESERVE + RESTRUCTURE | Any statement telling the agent what to do or not do |
| **Metadata/provenance** | COMPRESS | Version history, author info → single-line header. Well-known external conventions → single reference line, not individual entries. |

Decision heuristic: IF content answers "what should the agent DO?" or "what must it NOT DO?" → preserve. IF it answers "why did humans write it this way?" → compress. IF it's social lubricant → remove.

### Max Density Rule (Pass 1 — Strip & Compress)

When merging adjacent IRUnits of the same type in the same section, the following structural sequences MUST NOT be merged into run-on prose:

| Sequence Type | Must Remain Separate | Reason |
|---|---|---|
| Numbered step sequences | Each step = separate IRUnit | Agents execute one step at a time; dense paragraphs are not executable |
| Failure modes | Each failure mode = separate IRUnit | Agents scan for specific failure scenarios; buried text is missed |
| Edge cases | Each edge case = separate IRUnit | Conditional triggers need individual scanability |
| Constraints with distinct conditions | Each constraint = separate IRUnit | Different conditions apply to different situations |

Allowed merges: adjacent units that are truly redundant restatements, or units that express the same constraint from the same angle with no distinct condition. When in doubt, do not merge.

### Aggressive Redundancy Elimination (Pass 1 — Strip & Compress)

| Rule | Action | Rationale |
|---|---|---|
| **Merge Constraints + Invariants + Forbidden Usage** | Consolidate into single `<Rules>` section. Each distinct rule stated ONCE with: direction (MUST/MUST NOT), priority [P0/P1/P2], and condition. Merge positive/negative formulations of same rule into one. | Source skills state same rule 3-6× across Constraints/Invariants/Forbidden Usage. One formulation is sufficient. |
| **Remove `<Instructions>` section** | Do NOT output a separate `<Instructions>` section. The `<Steps>` or `<Phase Separation>` section already contains the procedural flow. | `<Instructions>` is always a summary or IF/THEN re-render of content already in Steps. Adds zero new information. |
| **Remove `<Invocation Conditions>` section** | Do NOT output `<Invocation Conditions>`. The skill description and `<Purpose>` section already capture when to invoke. | Restates what the description field already says. Not actionable during execution. |
| **Remove `<Relationships>` section** | Do NOT output `<Relationships>`. Dependencies are implicit in the skill's behavior. | Meta-documentation, not agent-executable instructions. |
| **Remove `<Guarantees>` section** | Do NOT output `<Guarantees>`. Guarantees are restatements of invariants. | "Pre-merge state restorable" (Guarantee) = same as invariant. One formulation sufficient. |
| **Remove `<Validation Strategy>` from compiled output** | Do NOT output `<Validation Strategy>`. This is compiler metadata about how the compiled output was verified. | Agent does not need to know how compilation was validated. |
| **Collapse `<Scope>`, `<Inputs>`, `<Outputs>`** | Each to single-line summary. Target + exclusion in one line. | Useful for classification but verbose in compiled output. |
| **Merge Failure Modes into Steps** | Inline error handling within the procedural step that encounters it. Do NOT maintain a separate `<Failure Modes>` section. | Source already structures error handling inline with steps. "Step 1: Check .git. If missing → error + exit." |
| **De-duplicate tables** | If same table appears in source and is re-extracted, keep only one instance. | Conventional Commit Types table appearing twice wastes ~400 bytes. |

Expected result: compiled output should be **smaller than source** for most skills. Every constraint, invariant, failure mode, and procedural step remains present — stated once rather than 3-6 times.

</filler_categories>

<universal_sections>

### 10 Universal Required Sections

Every compiled output MUST include all 10 universal sections during IR processing:

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

**Stage 4 elimination (skills only):** For compiled SKILL.md output, the following sections are removed by Aggressive Redundancy Elimination rules: `<Instructions>`, `<Invocation Conditions>`, `<Relationships>`, `<Guarantees>`, `<Validation Strategy>`. These are processed during IR extraction (for analysis) but not emitted in final output. `<Constraints>`, `<Invariants>`, and `<Forbidden Usage>` are merged into single `<Rules>` section. `<Failure Modes>` are inlined into procedural steps. `<Scope>`, `<Inputs>`, `<Outputs>` compressed to single lines.

Plus **type-specific sections** (Skills have Phase Separation; Plans have Data Model/Architecture/Key Operations/etc.)

</universal_sections>

<validation>

### Tier 1 — Cheap Structural Check (runs automatically, fast, deterministic)

- Verify all 10 universal sections present with XML-like tags
- Verify all type-specific sections present (based on document type)
- Verify declarative language used (no "try to", "ideally", "if possible")
- Verify negative constraints exist
- Verify uncertainty explicitly declared (not left implicit)
- Verify KERNEL framework compliance
- Fail = compilation fails with specific missing-element errors

### Tier 2 — Functional Equivalence Test (runs automatically, agent-based, pass/fail)

Runs after Tier 1 passes. Validates that the compiled SKILL.md is functionally equivalent to the source SKILL.human.md by executing both through identical benchmark tasks and comparing agent behavior.

**Execution flow:**
1. Grader agent loads both documents (SKILL.human.md + SKILL.md)
2. For each benchmark task in `benchmarks/tier-2-benchmarks.md`:
   a. Spawn Source Agent → load SKILL.human.md → execute task → capture actions/output
   b. Spawn Compiled Agent → load SKILL.md → execute identical task → capture output
   c. Grade: compare both against rubric → PASS / FAIL per criterion
   d. Task passes if ALL criteria pass
3. Aggregate: compute pass rate across all tasks
4. IF pass rate ≥95% → Tier 2 PASS; IF <95% → Tier 2 FAIL

**Benchmark suite:** 25 tasks total (5 per skill × 5 skills). See `benchmarks/tier-2-benchmarks.md` for full definitions.

**Capability dimensions tested per skill:**
- **Happy Path** — normal invocation, correct execution under standard conditions
- **Edge Case** — unusual input state, proper boundary condition handling
- **Constraint Obedience** — P0 constraint enforcement, invariant preservation
- **Failure Mode** — error scenario, correct response when things go wrong
- **Multi-Step** — full procedural sequence, complete step-by-step execution in order

**Semantic equivalence** means: same actions taken, same constraints obeyed, same invariants preserved, same output structure — NOT identical text.

**Stochastic handling:** IF a task fails on first run, re-run once to check for stochastic false negatives. Second-run pass → marked FLAKY (pass but flagged). Both runs fail → hard FAIL.

**Threshold:** 95%+ task equivalence across the benchmark suite (max 1 failure in 25-task suite). If threshold not met during early runs, may be dialed back to 90%.

**Fail =** compilation fails, user shown divergence report with: which tasks failed, which criteria failed per task, source vs compiled agent behavior side-by-side, root cause hypothesis.

**Result format:** JSON output written to `benchmarks/results/tier2-result-YYYYMMDD-HHmmss.json` with per-task status, per-cernel results, pass rate, and overall Tier 2 result.

### Separate Verification Skill (expensive, on-demand)

- Skill created: `sas-semantic-compiler-verify`
- 6 audit passes: content coverage, constraint sufficiency, conflict detection, edge case coverage, instruction fidelity, semantic drift
- Not part of the normal compilation pipeline — invoked manually for quality audits
- Output: verification report at `.verification/verify-<skill-name>-YYYYMMDD-HHmmss.md` with per-pass PASS/FAIL/WARNING and overall verdict

</validation>

<bootstrap_strategy>

### Phase 1 — Minimum Viable Compiler (v0.1)

- Implement Stages 1-3 (Preprocessor, DST, IR Extraction) with conservative transformation rules
- Stage 4: Only Pass 1 (strip filler per classification rules) — no tagging, no cross-referencing
- Stage 5: Basic section detection + placeholder injection for missing sections
- Stage 6: Simple markdown output (no XML tags yet)
- Test: Compile a simple Skill (e.g., `sas-endsession`) and verify output is usable

### Phase 2 — Full Pipeline (v1.0)

- Add Stage 4 Pass 2 (tagging, priority markers, IF/THEN/ELSE)
- Add Stage 4 Pass 3 (cross-reference resolution, grouping)
- Add XML-like tag wrapping in Stage 6
- Add Tier 1 structural validation
- Test: Compile all existing Skills, verify Tier 1 passes

### Phase 3 — Self-Compilation (v2.0)

- Write `SKILL.human.md` for `sas-semantic-compiler` itself
- Use v1.0 compiler to produce `SKILL.md`
- Validate output against Semantic Constraint Framework
- Iterate: refine Stage 4 transformation rules based on self-compilation results

### Phase 4 — Aggressive Optimization (v3.0+)

- Tier 2 functional equivalence validation — DONE (Step 6 complete)
- Separate expensive verification skill — DONE (Step 7 complete, `sas-semantic-compiler-verify`)
- Refine filler classification rules based on real-world results
- Push transformation aggressiveness to the limit

**Key principle:** Each phase produces a working, usable compiler. The pipeline architecture never changes — only the transformation rules within Stage 4 and the validation rigor increase.

</bootstrap_strategy>

<operational_concerns>

### Source Control

- On-demand generation only (not automatic)
- Never edit compiled files — always regenerate from source
- Humans edit source files only
- No decompiler needed
- No incremental compilation — full top-to-bottom pipeline run

### Invocation

- Manual only (intentional user action required)
- CLI command invokable
- Callable function within other skills/agents
- Processes single files or entire directories

### Skill Characteristics

- **Standalone:** Fully independent — no dependencies on other skills. No external tools/libraries required.
- **Documentation:** Before/after examples in README.md (not SKILL.md). Skill's own SKILL.md compiled following same pattern it produces.
- **Security:** No additional concerns beyond normal agent access. If agent can read a document, it's eligible for compilation.

### Naming

- Skill name: `sas-semantic-compiler`
- Follows `sas-` prefix convention

### Cleanup and Lifecycle

| Scenario | Action |
|----------|--------|
| Successful compilation + validation | `.DocName.compilation/` folder retained for auditability |
| Failed compilation | `.DocName.compilation/` folder retained up to failed stage for diagnosis |
| Source document recompiled | Existing `.DocName.compilation/` folder overwritten (new files replace old) |
| Source document deleted | `.DocName.compilation/` folder should be deleted (orphaned build artifact) |
| Manual cleanup requested | Delete `.DocName.compilation/` folder |

Disk space: compilation folders are typically 2-5× the size of the source document. For a 500-line source document, expect ~50-100KB of intermediate files.

</operational_concerns>

<file_structure>

### File Structure

For a source document `DocX.human.md` in directory `X/`:

```
X/
├── DocX.human.md               ← source document (human-edited)
├── DocX.compiled.md            ← compiled output (final artifact)
└── .DocName.compilation/
    ├── stage-1-preprocessor/
    │   ├── preprocessed.md
    │   └── annotations.json
    ├── stage-2-dst/
    │   └── dst.json
    ├── stage-3-ir/
    │   └── ir.json
    ├── stage-4-optimized/
    │   ├── ir-pass-1.json
    │   ├── ir-pass-2.json
    │   └── ir-pass-3.json
    ├── stage-5-constrained/
    │   └── ir-augmented.json
    └── stage-6-generated/
        └── output-draft.md
```

### Git Configuration

All `.compilation/` folders are reproducible build artifacts and should be git-ignored:
```gitignore
# Compilation intermediate files (reproducible build artifacts)
*.compilation/
```

</file_structure>

<output_format>

### Output Format

**Optimized Markdown with XML-like tags for strict section boundaries.**

- XML-like wrapper tags for every major section (e.g., `<purpose>`, `<scope>`, `<constraints>`)
- Explicit `IF/THEN/ELSE` blocks for conditional logic
- Numbered lists for sequential instructions
- Key-value pairs for inputs/outputs
- Priority markers (`[P0]`, `[P1]`, `[P2]`) for instruction importance
- Negative constraints explicitly listed
- Cross-reference anchors with explicit IDs linking between sections

### File Naming

- **Skills:** `SKILL.human.md` → source file, `SKILL.md` → compiled output
- **Other documents:** `{name}.md` → source, `{name}.compiled.md` → compiled output
- Always same directory as source for traceability
- Existing `.compiled.md` files are overwritten

### Traceability Header

- Format: `<!-- compiled from: {relative_source_path} | {ISO 8601 timestamp} -->`
- Placement:
  - **Skills (SKILL.md):** MUST be placed immediately AFTER the closing `---` of the YAML frontmatter. The YAML frontmatter MUST start on line 1.
  - **Other documents:** Placed as the first line of the compiled file.

### Human vs AI Optimization Dial

| Human-Optimized | AI-Optimized |
|-----------------|--------------|
| Explanatory prose | Minimal prose |
| Friendly narrative | Dense constraints |
| Justification and context | Explicit guarantees |
| Designed for onboarding | Zero ambiguity |

Same meaning, different surface. The compiler controls the dial.

</output_format>

<design_principles>

- **Trust file persistence over AI context window memory** — each stage reads only what it needs, writes its output, and the context is cleared before the next stage
- **Aggressive from the start** — full 6-stage pipeline, all validation, all constraint injection
- **HALT on errors** — no partial output, no guessing, clear error messages with source locations
- **Deterministic output** — constraining probabilistic systems tends toward deterministic results
- **Same meaning, different surface** — the compiler controls the human-to-AI optimization dial

</design_principles>

*Last updated: 14 April 2026*

