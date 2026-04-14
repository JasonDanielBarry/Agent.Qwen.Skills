<!-- compiled from: skills/sas-semantic-compiler/SKILL.human.md | 2026-04-13T10:06:06Z -->

---
name: sas-semantic-compiler
description: Compile markdown documents (.human.md) into AI-optimized output via a 6-stage pipeline with sub-agent isolation. Transforms human-readable markdown into machine-optimized form. Invokes compilation of skills, plans, and agent-directed documents.
---

## Purpose

<purpose>
[P0] Compile .human.md source documents into AI-optimized .md output via a 6-stage pipeline with sub-agent isolation. Output is designed exclusively for AI agent execution — human readability is not a concern.
[P0] Ambiguities or errors HALT compilation entirely.
[P0] 6-stage pipeline: Preprocessor → Structural Parse (DST) → Semantic IR Extraction → Optimization Passes → Semantic Constraint Injection → Code Generation.
[P0] Sub-agent lifecycle: Spawn → Load → Process → Write → Terminate.
[P0] Follows C/C++ compiler model: preprocessing phase (macro expansion, file inclusion, conflict detection) followed by compilation phase (machine-optimized output).
</purpose>

## Scope

<scope>
- Target: Skill files (SKILL.md and related), implementation plans, any markdown with instructions/guidelines/structured info for AI agents
- Excluded: README files, documentation for human end-users, any human-consumption documents
</scope>

## Inputs

<inputs>
- Source .human.md file path (required)
- Compilation skill instructions (SKILL.md) loaded by each sub-agent
- Sub-agent receives: (a) the compilation skill instructions (SKILL.md), and (b) the output files from the previous stage/pass on disk. Nothing else.
- DSTNode schema: type (heading/paragraph/list/ordered_list/table/code_block/blockquote/thematic_break/link/image/html), level (for headings 1-6), content (raw text/markdown), children (DSTNode[]), metadata (source_line, section_path, semantic_role?)
- IRUnit schema: id (string), type (15 semantic roles), section (string), content (cleaned text), priority (P0/P1/P2), conditions (Condition[]), references (string[]), negation (boolean)
- Condition schema: predicate (string), then (IRUnit[]), else (IRUnit[])
</inputs>

## Outputs

<outputs>
- Stage 1: preprocessed.md + annotations.json → stage-1-preprocessor/
- Stage 2: dst.json → stage-2-dst/
- Stage 3: ir.json → stage-3-ir/
- Stage 4 Pass 1: ir-pass-1.json → stage-4-optimized/
- Stage 4 Pass 2: ir-pass-2.json → stage-4-optimized/
- Stage 4 Pass 3: ir-pass-3.json → stage-4-optimized/
- Stage 5: ir-augmented.json → stage-5-constrained/
- Stage 6: output-draft.md → stage-6-generated/, then copied to final output path
- Output format: Optimized Markdown with XML-like tags for strict section boundaries. XML-like wrapper tags, IF/THEN/ELSE blocks, numbered lists, key-value pairs, priority markers ([P0], [P1], [P2]), negative constraints explicitly listed, cross-reference anchors with explicit IDs.
- File naming: Skills: SKILL.human.md → SKILL.md. Other documents: {name}.md → {name}.compiled.md. Always same directory as source. Existing .compiled.md files are overwritten.
- Traceability header format: <!-- compiled from: {relative_source_path} | {ISO 8601 timestamp} -->. Placed as first line of compiled file.
</outputs>

## Constraints

<constraints>
[P0] Must not edit compiled files — always regenerate from source
[P0] Must not commit .compilation/ folders to git
[P0] Must not reuse sub-agents across stages/passes — fresh agent per stage/pass is required
[P0] Must not proceed to compilation if preprocessor finds conflicts, contradictions, or ambiguities
[P0] Must not guess or imply defaults for unspecified behavior
[P0] Must halt pipeline immediately on any error — no partial output
[P0] Must not reference content from stages other than the designated input files
[P0] Every compiled output MUST include all 10 universal sections: Purpose, Scope, Inputs, Outputs, Constraints, Invariants, Failure Modes, Validation Strategy, Relationships, Guarantees
[P0] Compiled output MUST use declarative language, not suggestions
[P0] If something is not decided in source: Do not guess. Do not imply defaults. Do not leave it implicit. Write: "This is currently unspecified and must be decided before use."
[P0] Must explicitly state what the agent must not do. Blocking unwanted behavior is more effective than only prescribing desired behavior.
[P0] All compiled artifacts must satisfy KERNEL framework: K (Keep it simple — single, unambiguous primary goal), E (Easy to verify — pre-defined success metrics), R (Reproducibility results — identical inputs produce equivalent outputs), N (Narrow scope — explicit domain and task limits), E (Explicit constraints — hard boundaries on data sources, tools, capabilities), L (Logical structure — strict structural, token, or styling boundaries)
[P0] Source control: On-demand generation only (not automatic). Never edit compiled files — always regenerate from source. Humans edit source files only. No decompiler needed. No incremental compilation — full top-to-bottom pipeline run for consistency/determinism.
[P0] Invocation: Manual only (intentional user action required). CLI command invokable. Callable function within other skills/agents. Processes single files or entire directories.
[P0] Type alias mapping: Section names MUST NOT be used as semantic role types. The semantic role describes what kind of instruction the content is, not which section it belongs to. If content matches multiple keywords, use structural context (section heading) as tiebreaker. If content matches no keyword, classify by the nearest valid type based on its functional role in agent execution.
[P0] Max Density Rule: Do NOT merge numbered step sequences, failure modes, edge cases, or constraints with distinct conditions. Each must remain as a separate IRUnit. When in doubt, do not merge.
[P0] Example preservation: For procedural skills, retain at least one concrete example. Do not generalize all examples away.
[P0] For procedural skills (skills that tell an agent how to execute a task), retain at least one concrete worked example. Pure reference/data skills may generalize all examples.
[P0] All .compilation/ folders are reproducible build artifacts and must be git-ignored (*.compilation/). The compiled output and source are committed. The compilation folder is never committed.
[P0] Collision handling: If two source files share the same stem, use the full stem (e.g., .SKILL.reference.compilation/).
</constraints>

## Invariants

<invariants>
[P0] Each of the 6 pipeline stages and each of the 3 Stage 4 optimization passes MUST execute in a separate sub-agent
[P0] Reusing a single agent across multiple stages or passes is forbidden
[P0] Sub-agent termination (process exit) is the only mechanism that provides structural context isolation
[P0] Before the first sub-agent spawns, the agent has zero context about the document being compiled, its content, or any compilation stage
[P0] Preprocessor must complete FULLY without errors before compiler can run
[P0] Each stage receives the previous stage's output as its sole input. No stage reads from disk directly (except Stage 1). No stage writes to disk directly (except Stage 6).
[P0] Each phase produces a working, usable compiler. The pipeline architecture never changes — only the transformation rules within Stage 4 and the validation rigor increase.
[P0] Trust file persistence over AI context window memory — each stage reads only what it needs, writes its output, context cleared before next stage
[P0] Aggressive from the start — full 6-stage pipeline, all validation, all constraint injection
[P0] HALT on errors — no partial output, no guessing, clear error messages with source locations
</invariants>

## Failure Modes

<failure_modes>
| Stage | Code | Meaning |
|-------|------|---------|
| Preprocessor | PRE_001 | Referenced file not found |
| | PRE_002 | Conflicting/contradictory instructions or circular reference |
| | PRE_003 | Ambiguous reference (multiple possible targets) |
| | PRE_004 | Invalid directive syntax |
| Structural Parse | DST_001 | Malformed markdown (unclosed block) |
| | DST_002 | Empty document (no parseable content) |
| IR Extraction | IR_001 | Unable to classify content into any semantic role |
| | IR_002 | Circular reference detected |
| Optimization | OPT_001 | All content classified as filler (nothing to preserve) |
| | OPT_002 | Priority conflict (two P0 constraints contradict) |
| Constraint Injection | SCI_001 | Too many unspecified sections (>3 universal sections empty) |
| | SCI_002 | KERNEL validation failed |
| Code Generation | GEN_001 | Output path not writable |
| | GEN_002 | Template rendering failure |

Any error → pipeline halts immediately. Error reported with stage name, code, description, and source line number. All intermediate files retained in .DocName.compilation/ for diagnosis. No partial output written to final destination.

**Error propagation:** Every stage returns Success(output) or Error(stage_name, code, message, context). Any error → pipeline halts immediately. Error displayed with stage name, code, description, source location. All intermediate files up to the point of failure retained. No partial output written to final destination.

**Diagnosis workflow:**
1. Read the error message to identify the failing stage
2. Open the corresponding stage folder in .DocName.compilation/
3. Inspect the output files to see what the stage produced
4. If needed, inspect the previous stage's output to verify its inputs were correct
5. Fix the source document and recompile
</failure_modes>

## Validation Strategy

<validation_strategy>
### Tier 1 — Structural Check (automatic, fast, deterministic)

- Verify all 10 universal sections present with XML-like tags
- Verify all type-specific sections present (based on document type)
- Verify declarative language used (scan for "try to", "ideally", "if possible", "approximately")
- Verify negative constraints exist
- Verify uncertainty explicitly declared (not left implicit)
- Verify KERNEL framework compliance
- Fail = compilation fails with specific missing-element errors

### Tier 2 — Functional Equivalence Test (automatic, agent-based, pass/fail)

Runs after Tier 1 passes. Validates that compiled SKILL.md is functionally equivalent to source SKILL.human.md by executing both through identical benchmark tasks and comparing agent behavior.

**Execution flow:**
1. Grader agent loads both documents (SKILL.human.md + SKILL.md)
2. For each benchmark task in `benchmarks/tier-2-benchmarks.md`:
   a. Spawn Source Agent → load SKILL.human.md → execute task → capture actions/output
   b. Spawn Compiled Agent → load SKILL.md → execute identical task → capture output
   c. Grade: compare both against rubric → PASS / FAIL per criterion
   d. Task passes if ALL criteria pass
3. Aggregate: compute pass rate across all tasks
4. Threshold check: ≥95% → Tier 2 PASS; <95% → Tier 2 FAIL

**Benchmark suite:** 25 tasks total (5 per skill × 5 skills). See `benchmarks/tier-2-benchmarks.md` for full definitions.

**Capability dimensions tested per skill:**
- **Happy Path** — normal invocation, correct execution under standard conditions
- **Edge Case** — unusual input state, proper boundary condition handling
- **Constraint Obedience** — P0 constraint enforcement, invariant preservation
- **Failure Mode** — error scenario, correct response when things go wrong
- **Multi-Step** — full procedural sequence, complete step-by-step execution in order

**Semantic equivalence** means: same actions taken, same constraints obeyed, same invariants preserved, same output structure — NOT identical text.

**Stochastic handling:** If a task fails on first run, re-run once to check for stochastic false negatives. Second-run pass → marked FLAKY (pass but flagged). Both runs fail → hard FAIL.

**Threshold:** 95%+ task equivalence across the benchmark suite (max 1 failure in 25-task suite). If threshold not met during early runs, may be dialed back to 90%.

**Fail =** compilation fails, user shown divergence report with: which tasks failed, which criteria failed per task, source vs compiled agent behavior side-by-side, root cause hypothesis.

**Result format:** JSON output written to `benchmarks/results/tier2-result-YYYYMMDD-HHmmss.json` with per-task status, per-criterion results, pass rate, and overall Tier 2 result. See benchmark document for full JSON schema.

### Separate Verification Skill (expensive, on-demand)

- ~~Dedicated skill for deep analysis~~ **DONE — Phase 4 Step 7 complete**
- Skill created: `sas-semantic-compiler-verify`
- 6 audit passes: content coverage, constraint sufficiency, conflict detection, edge case coverage, instruction fidelity, semantic drift
- Not part of normal compilation pipeline — invoked manually for quality audits
- Output: verification report at `.verification/verify-<skill-name>-YYYYMMDD-HHmmss.md` with per-pass PASS/FAIL/WARNING and overall verdict
</validation_strategy>

## Relationships

<relationships>
- Depends on: architecture/ folder (11 reference documents: 01-overview, 02-transformation-rules, 03-semantic-constraints, 04-pipeline-architecture, 05-compilation-file-structure, 06-execution-workflow, 07-cross-reference-resolution, 08-output-format, 09-validation, 10-bootstrap-strategy, 11-operational-concerns)
- Produces: compiled output in same directory as source
- Compilation folder structure: .DocName.compilation/ with stage-1-preprocessor/, stage-2-dst/, stage-3-ir/, stage-4-optimized/, stage-5-constrained/, stage-6-generated/
- Source stem derivation: SKILL.human.md → .SKILL.compilation/, release-plan.human.md → .release-plan.compilation/
- Cross-referenced documents compiled together (transitive, max depth 5)
- Circular references halt compilation with PRE_002
- Skill is standalone: Fully independent, no dependencies on other skills, no external tools/libraries required. Agent and skill itself are the entire compilation engine.
- Documentation: Before/after examples in README.md (not SKILL.md). Skill's own SKILL.md will be compiled following same pattern it produces.
- Security: No additional concerns beyond normal agent access. If agent can read a document, it's eligible for compilation. User responsibility for sensitive information.
</relationships>

## Guarantees

<guarantees>
[P0] Deterministic output — constraining probabilistic systems tends toward deterministic results
[P0] Same meaning, different surface — the compiler controls the human-to-AI optimization dial
[P0] All intermediate files permanently persisted for auditability and error diagnosis
[P0] Each phase produces a working, usable compiler
</guarantees>

---

## Invocation Conditions

<invocation_conditions>
**Invariant — Fresh sub-agent per stage/pass:** Each of the 6 pipeline stages and each of the 3 Stage 4 optimization passes MUST execute in a separate sub-agent. Reusing a single agent across multiple stages or passes is forbidden. Sub-agent termination (process exit) is the only mechanism that provides structural context isolation.

### Execution Sequence (8 sub-agent invocations)

| Execution Unit | Agent | Input | Output |
|----------------|-------|-------|--------|
| Stage 1 — Preprocessor | Agent 1 | Source .human.md file | preprocessed.md + annotations.json |
| Stage 2 — Structural Parse | Agent 2 | Stage 1 output files | dst.json |
| Stage 3 — Semantic IR Extraction | Agent 3 | Stage 2 output file | ir.json |
| Stage 4 Pass 1 — Strip & Compress | Agent 4 | Stage 3 output file | ir-pass-1.json |
| Stage 4 Pass 2 — Tag & Structure | Agent 5 | Pass 1 output file | ir-pass-2.json |
| Stage 4 Pass 3 — Cross-Reference & Group | Agent 6 | Pass 2 output file | ir-pass-3.json |
| Stage 5 — Semantic Constraint Injection | Agent 7 | Pass 3 output file | ir-augmented.json |
| Stage 6 — Code Generation | Agent 8 | Stage 5 output file | output-draft.md |

### Sub-Agent Lifecycle

Every sub-agent follows: **Spawn → Load → Process → Write → Terminate**

1. **Spawn** — parent agent creates a fresh sub-agent
2. **Load** — sub-agent receives: (a) the compilation skill instructions (SKILL.md), and (b) the output files from the previous stage/pass on disk. Nothing else.
3. **Process** — sub-agent performs its stage's transformation per the pipeline specification
4. **Write** — sub-agent writes its output files to the .DocName.compilation/ folder
5. **Terminate** — sub-agent exits. Process destruction = guaranteed context destruction.
</invocation_conditions>

---

## Forbidden Usage

<forbidden_usage>
- Must not edit compiled files — regenerate from source
- Must not commit .compilation/ folders to git
- Must not reuse sub-agents across stages/passes
- Must not proceed to compilation if preprocessor finds conflicts
- Must not guess or imply defaults for unspecified behavior
- Must not perform incremental compilation — full top-to-bottom pipeline run required
- Must not allow implicit references — only explicit file paths/links resolved
</forbidden_usage>

---

## Phase Separation

<phase_separation>
| Feature | Status |
|---------|--------|
| Stage 1-3 full implementation | Implemented (Phase 1) |
| Stage 4 Pass 1 (strip filler) | Implemented (Phase 1) |
| Stage 4 Pass 2 (tagging, IF/THEN/ELSE) | Implemented (Phase 2) |
| Stage 4 Pass 3 (cross-reference resolution) | Implemented (Phase 2) |
| XML-like tag wrapping | Implemented (Phase 2) |
| Tier 1 structural validation | Implemented (Phase 2) |
| Tier 2 functional equivalence | Implemented (Phase 4 Step 6) |
| Self-compilation | In Progress (Phase 3) |
| Separate verification skill | Implemented (Phase 4 Step 7) |
</phase_separation>

---

## Stage Specifications

<stage_specifications>
### Stage 1 — Preprocessor

Modeled after C/C++ preprocessor. Outputs: preprocessed.md + annotations.json.

[P0] Conflict detection: Conflicts, contradictions, or ambiguities → document MUST NOT compile, user MUST be alerted to resolve.
[P0] File inclusion: Referenced document found → include with boundaries. NOT found → halt with clear error message.
[P0] Gatekeeper rule: Preprocessor must complete FULLY without errors before compiler can run.

Cross-reference resolution: Detects references (Markdown links or explicit paths to other .md files). Transitive resolution (A→B→C compiles all three), max depth 5. Referenced documents compiled first (leaves before roots). Circular references (A→B→A) halt with PRE_002 error.

### Stage 2 — Structural Parse (DST)

Converts preprocessed source into a Document Structure Tree.

DSTNode schema: type (heading/paragraph/list/ordered_list/table/code_block/blockquote/thematic_break/link/image/html), level (int, for headings 1-6), content (string), children (DSTNode[]), metadata (source_line, section_path, semantic_role?).

Node handling: heading drives tree hierarchy. table and code_block preserved verbatim. thematic_break discarded in Stage 3. link preserved with URL extraction. html preserved verbatim.

Traversal: Depth-first, pre-order. Parent pointer available for section context.

### Stage 3 — Semantic IR Extraction

Flattens the DST into a linear sequence of semantic units, all markdown formatting stripped.

IRUnit schema: id (string), type (15 semantic roles: instruction/constraint/fact/example/rationale/edge_case/invariant/failure_mode/guarantee/input/output/relationship/validation/metadata/filler), section (string), content (string), priority (P0/P1/P2), conditions (Condition[]), references (string[]), negation (boolean).

Condition schema: predicate (string), then (IRUnit[]), else (IRUnit[]).

Semantic role assignment by keyword heuristics + structural context:
- must/must not/required/forbidden → constraint
- do/run/execute → instruction
- is/are/defines → fact
- for example/e.g. → example
- because/since → rationale
- if/when/unless → edge_case
- always/invariant/holds → invariant
- fail/error/fallback → failure_mode
- guarantee/ensures/commits → guarantee
- input/source/precondition → input
- output/produces/result → output
- depends/relates → relationship
- verify/validate/test/check → validation
- version/author/date → metadata
- rule/policy → constraint (alias mapping)
- file_structure/directory_layout/folder → instruction (alias mapping)

Content section-to-role mapping:
- Purpose heading → fact
- Validation Strategy heading → instruction
- Scope heading → fact or constraint
- Relationships heading → relationship
- Guarantees heading → guarantee

### Stage 4 — Optimization Passes

Pass 1 — Strip & Compress: Remove all type: filler IRUnits. Compress type: rationale to [rationale: X]. Compress type: metadata to single-line header. Merge adjacent IRUnits of same type in same section — EXCEPT Max Density Rule. Strip decorative formatting.

Pass 2 — Tag & Structure: Assign explicit id (sec-{section}-{index}). Add priority: P0 for constraints/invariants/negative constraints, P1 for instructions/failure modes, P2 for examples/relationships. Convert conditional prose into explicit Condition objects. Mark negative constraints (negation: true). Wrap examples in generalized schema patterns.

Pass 3 — Cross-Reference & Group: Resolve references by matching anchors/IDs to IRUnit IDs. Group related IRUnits by semantic affinity. Add cross-reference links between sections. Deduplicate IRUnits with identical content in same section.

### Stage 5 — Semantic Constraint Injection

Method: Structural reorganization + template fill.
1. Group IRUnits by section field into Map<string, IRUnit[]>
2. For each of 10 universal sections: if IRUnits exist → use and reorganize; if none → inject placeholder
3. Add type-specific sections (skill detection → Invocation Conditions/Forbidden Usage/Phase Separation; plan detection → Data Model/Architecture/Key Operations)
4. Convert ALL content to declarative language
5. Ensure at least one negative constraint exists
6. Run KERNEL validation checklist

### Stage 6 — Code Generation

**Output path resolution:**
- Always same directory as source file. Never relocate to a different directory (e.g., never force output into `skills/`).
- Skills (`SKILL.human.md`): output is `SKILL.md` in same directory.
- All other documents (`{name}.md`): output is `{name}.compiled.md` in same directory.
- If resolved path exists, overwrite it.

Method: Template-based rendering from augmented IR.
1. Emit traceability header: `<!-- compiled from: {source_path} | {timestamp} -->`
2. For each of 10 universal sections (canonical order): emit section heading, emit XML-like wrapper, emit each IRUnit (priority marker for P0, bullet for instructions/constraints, prose for facts/rationale, `IF/THEN/ELSE` if conditions present, negative framing if `negation: true`), emit closing tag
3. Emit type-specific sections the same way
4. Write to resolved `{output_path}` in same directory as source.
</stage_specifications>

---

## File Structure

<file_structure>
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

**Source stem derivation:** SKILL.human.md → .SKILL.compilation/, release-plan.human.md → .release-plan.compilation/

**Git ignore:** *.compilation/

**Collision handling:** If two source files share the same stem, use the full stem (e.g., .SKILL.reference.compilation/).
</file_structure>

---

## Transformation Rules

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
- Replace ambiguous references with explicit identifiers

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

---

## Filler Classification

<filler_classification>
| Classification | Action | Rule |
|---|---|---|
| Verbose filler | REMOVE | Polite phrases, conversational transitions, rhetorical questions, exclamation marks, decorative emphasis, ellipses, self-referential agent language |
| Redundant restatement | REMOVE | Same information repeated with no new constraint or detail |
| Justification/provenance | COMPRESS to 1 line | "Why" explanations → [rationale: X] |
| Hedging language | RESOLVE | Replace with definitive directive OR [optional: X] |
| Contextual reasoning | COMPRESS but PRESERVE | Conditional logic, edge cases, cross-section dependencies, terminology definitions |
| Examples | GENERALIZE (keep 1+) | Replace with minimal schema/pattern + reference. For procedural skills, retain at least one concrete worked example. Pure reference/data skills may generalize all examples. |
| Instructions/constraints/rules | PRESERVE + RESTRUCTURE | Any statement telling the agent what to do or not do |
| Metadata/provenance | COMPRESS | Version history, author info → single-line header. Well-known external conventions → single reference line. |

**Decision heuristic:** If content answers "what should the agent DO?" or "what must it NOT DO?" → preserve. If it answers "why did humans write it this way?" → compress. If it's social lubricant → remove.

### Max Density Rule (Pass 1 — Strip & Compress)

When merging adjacent IRUnits of the same type in the same section, the following structural sequences MUST NOT be merged into run-on prose:

| Sequence Type | Must Remain Separate | Reason |
|---|---|---|
| Numbered step sequences | Each step = separate IRUnit | Agents execute one step at a time; dense paragraphs are not executable |
| Failure modes | Each failure mode = separate IRUnit | Agents scan for specific failure scenarios; buried text is missed |
| Edge cases | Each edge case = separate IRUnit | Conditional triggers need individual scanability |
| Constraints with distinct conditions | Each constraint = separate IRUnit | Different conditions apply to different situations |

**Allowed merges:** Adjacent units that are truly redundant restatements, or units that express the same constraint from the same angle with no distinct condition. When in doubt, do not merge.
</filler_classification>

---

## KERNEL Framework

<kernel_framework>
| Letter | Principle | Purpose |
|--------|-----------|---------|
| K | Keep it simple | Single, unambiguous primary goal — prevents scope creep |
| E | Easy to verify | Pre-defined success metrics and quality checkpoints |
| R | Reproducible results | Identical inputs must produce equivalent outputs |
| N | Narrow scope | Explicit domain and task limits — no general-purpose behavior |
| E | Explicit constraints | Hard boundaries on data sources, tools, and capabilities |
| L | Logical structure | Strict structural, token, or styling boundaries |
</kernel_framework>

---

## Optimization Dial

<optimization_dial>
| Human-Optimized | AI-Optimized |
|-----------------|--------------|
| Explanatory prose | Minimal prose |
| Friendly narrative | Dense constraints |
| Justification and context | Explicit guarantees |
| Designed for onboarding | Zero ambiguity |

Same meaning, different surface. The compiler controls the dial.
</optimization_dial>

---

## Operational Concerns

<operational_concerns>
- Skill characteristics: Standalone (no dependencies on other skills, no external tools/libraries). Documentation: Before/after examples in README.md. Security: No additional concerns beyond normal agent access.
- Naming: Skill name: sas-semantic-compiler. Follows sas- prefix convention.
</operational_concerns>

---

## Cleanup and Lifecycle

<cleanup_lifecycle>
| Scenario | Action |
|----------|--------|
| Successful compilation + validation | .DocName.compilation/ folder is retained for auditability |
| Failed compilation | .DocName.compilation/ folder is retained up to the failed stage for diagnosis |
| Source document recompiled | Existing .DocName.compilation/ folder is overwritten (new files replace old) |
| Source document deleted | .DocName.compilation/ folder should be deleted (orphaned build artifact) |
| Manual cleanup requested | Delete .DocName.compilation/ folder |

Disk space: Compilation folders typically 2-5x source size. For 500-line source, expect ~50-100KB intermediates.
</cleanup_lifecycle>
