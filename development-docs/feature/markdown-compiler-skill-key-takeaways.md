# Markdown Compiler Skill — Key Takeaways

## Overview

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

## Transformation Approach

**Goal:** Convert human-readable markdown to machine-optimized markdown (not human-readable), like C++ → assembly. Remove everything that doesn't directly contribute to instruction execution, guideline adherence, or structured information parsing.

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

### Filler vs. Context Classification

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

## Semantic Constraint Framework Integration

**CRITICAL:** The Semantic Constraint Framework already defines exactly what a "properly constrained" AI document looks like. The compiler's output **MUST** conform to this standard.

### 10 Universal Required Sections

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

### Declarative Language Rules

Compiled output **MUST** use declarative language, not suggestions:
- ✅ **Prefer:** `must`, `must not`, `required`, `forbidden`, `guaranteed`
- ❌ **Avoid:** `try to`, `ideally`, `if possible`, `approximately`

### Uncertainty Handling

If something is not decided in source:
- Do not guess
- Do not imply defaults
- Do not leave it implicit
- Instead write: "This is currently unspecified and must be decided before use."

### Negative Constraints

Compiled output **MUST** explicitly state what the agent must **not** do. Blocking unwanted behavior is more effective than only prescribing desired behavior.

### KERNEL Constraint Framework

All compiled artifacts must satisfy:

| Letter | Principle | Purpose |
|--------|-----------|---------|
| **K** | Keep it simple | Single, unambiguous primary goal — prevents scope creep |
| **E** | Easy to verify | Pre-defined success metrics and quality checkpoints |
| **R** | Reproducible results | Identical inputs must produce equivalent outputs |
| **N** | Narrow scope | Explicit domain and task limits — no general-purpose behavior |
| **E** | Explicit constraints | Hard boundaries on data sources, tools, and capabilities |
| **L** | Logical structure | Strict structural, token, or styling boundaries |

### Human vs AI Optimization Dial

The framework defines two modes — the compiler produces the AI-optimized end:

| Human-Optimized | AI-Optimized |
|-----------------|--------------|
| Explanatory prose | Minimal prose |
| Friendly narrative | Dense constraints |
| Justification and context | Explicit guarantees |
| Designed for onboarding | Zero ambiguity |

**Same meaning, different surface. The compiler controls the dial.**

---

## Output

### Format Decision

**Optimized Markdown with XML-like tags for strict section boundaries.**

Research across Cloudflare, Anthropic, and industry practitioners confirms:
- **Markdown** is the lingua franca for AI agents — explicit hierarchical structure with minimal token overhead (~80% fewer tokens than HTML)
- **XML-like tags** provide unambiguous section boundaries that prevent instruction bleeding — AI models parse them better than free-form prose
- **JSON** is reserved for machine-readable contracts, not instructional specs
- **YAML** is best for configuration files and conformance test suites

No conversion to pure JSON/YAML. Output stays in Markdown with XML-like tag injection for section-level strictness.

### Structured Elements in Compiled Output
- XML-like wrapper tags for every major section (e.g., `<purpose>`, `<scope>`, `<constraints>`, `<invariants>`, `<failure_modes>`, `<validation>`, `<relationships>`, `<guarantees>`)
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
- Existing `.compiled.md` files are overwritten (no versioning, no suffix incrementing)

### Traceability Header
- Format: `<!-- compiled from: {relative_source_path} | {ISO 8601 timestamp} -->`
- Placed as first line of compiled file
- HTML comment format ensures AI agents skip it naturally
- Timestamp: `YYYY-MM-DDTHH:mm:ssZ` (UTC)
- Example: `<!-- compiled from: skills/sas-example/SKILL.human.md | 2026-04-13T14:30:00Z -->`

### Size and Token Limits
- **Size irrelevant** — larger output acceptable if it improves agent comprehension
- **No token limit enforcement** — users responsible for fitting within their agent's context window

---

## Cross-Reference Resolution

Documents that reference other documents **MUST** be compiled together.

- **What constitutes a reference:** Any Markdown link (`[text](path/to/file.md)`) or explicit path mention pointing to another `.md` file within the same repository
- **Implicit references** ("see the SKILL.md for details") are NOT resolved — only explicit file paths/links
- **Resolution depth:** Transitive (A→B→C compiles all three). Maximum depth: 5 levels to prevent runaway compilation
- **Compilation order:** Referenced documents compiled first (leaves), then referencing document (root)
- **Inclusion method:** Content inlined during preprocessor stage with clear boundaries: `<!-- begin included: {path} -->` ... `<!-- end included: {path} -->`
- **Circular reference detection:** Cycles (A→B→A) halt compilation with `PRE_002` error
- **Missing references:** Halt with clear error message

---

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

## Architecture

### Compilation Pipeline — 6-Stage Design

**Do we replicate the C++ pipeline 1:1?** No. The C++ pipeline exists because of specific problems: complex type systems, memory layout, cross-file symbol resolution, and CPU architecture targets. Markdown for AI agents has a completely different profile.

#### What to Drop
- **The Linker:** Our preprocessor already handles `#include`-style document resolution *before* compilation. There is no separate "object file" stage.
- **Full Traditional AST:** Markdown doesn't have scopes, type hierarchies, template instantiations, or memory lifetimes.

#### What to Keep (But Simplify)
- **Document Structure Tree (DST)** instead of AST: A lightweight tree for optimization passes to traverse
- **Intermediate Representation (IR):** Crucial — separates "what this means" from "how it's written", enables format swapping, IR validation, and composable optimization passes

#### Pipeline

```
Source (.human.md)
   ↓
[1] Preprocessor
   - Macro expansion, file inclusion, conflict detection, filler identification, contextual reasoning compression
   - Outputs: Cleaned source + preprocessing annotations
   ↓
[2] Structural Parse (lightweight DST)
   - Converts markdown into a traversable tree of blocks
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

**Why This Works Better:**

| C++ Stage | Markdown Equivalent | Keep? | Why |
|-----------|---------------------|-------|-----|
| Preprocessor | Preprocessor | ✅ Yes | Handles includes, macros, early conflict detection |
| AST | Document Structure Tree | ⚡ Simplified | Gives passes a tree to traverse, no type/scope complexity |
| IR | Semantic IR | ✅ Yes | Strips formatting, isolates pure meaning/instructions |
| Optimization | Multi-pass optimizer | ✅ Yes | Each pass does one thing well (strip, structure, tag) |
| — | Semantic Constraint Injection | ✅ NEW | Ensures 10 universal sections, declarative language, KERNEL validation |
| Machine Code | Target Format | ✅ Yes | Final AI-readable output |
| Linker | None | ❌ Drop | Preprocessor already resolves cross-doc references |

**Conclusion:** Don't replicate C++ 1:1. Use a **6-stage pipeline** tailored for semantic document compilation. Keep the IR (biggest architectural win), add Semantic Constraint Injection (ensures framework compliance), drop the linker, simplify the AST to a Document Structure Tree. Keep stages that give **determinism, debuggability, and composability**, cut the rest.

### Stage Specifications

#### Stage 1 — Preprocessor

Modeled after C/C++ preprocessor.

**Temporary preprocessing document:** Created during preprocessing with expanded macros, included files, and annotations for conflict detection/filler identification. Aids the compilation phase. **MUST be deleted after successful compilation.**

**Conflict detection:** Conflicts, contradictions, or ambiguities → document **MUST NOT compile**, user **MUST be alerted** to resolve.

**File inclusion:** Referenced document found → include. NOT found → **halt with clear error message**.

**Gatekeeper rule:** Preprocessor must complete **FULLY** without errors before compiler can run. Only clean, unambiguous sources proceed.

#### Stage 2 — Structural Parse (DST)

Converts preprocessed source into a Document Structure Tree. Each node:

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

**Node handling:** `heading` drives tree hierarchy. `table` and `code_block` preserved verbatim. `thematic_break` discarded in Stage 3. `link` preserved with URL extraction. `html` preserved verbatim (may contain XML-like tags).

**Traversal:** Depth-first, pre-order. Parent pointer available for section context. Section boundaries determined by heading levels.

#### Stage 3 — Semantic IR Extraction

Flattens the DST into a linear sequence of semantic units, all markdown formatting stripped. Each IR unit:

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

**Semantic role assignment** by keyword heuristics + structural context: "must"/"must not"/"required"/"forbidden" → `constraint`; "do"/"run"/"execute" → `instruction`; "is"/"are"/"defines" → `fact`; "for example"/"e.g." → `example`; "because"/"since" → `rationale`; "if"/"when"/"unless" → `edge_case`; "always"/"invariant"/"holds" → `invariant`; "fail"/"error"/"fallback" → `failure_mode`; "guarantee"/"ensures"/"commits" → `guarantee`; "input"/"source"/"precondition" → `input`; "output"/"produces"/"result" → `output`; "depends"/"relates" → `relationship`; "verify"/"validate"/"test"/"check" → `validation`; "version"/"author"/"date" → `metadata`; everything else → classified by R4 filler rules.

#### Stage 4 — Optimization Passes

**Pass 1 — Strip & Compress:**
- Remove all `type: "filler"` IRUnits (per classification rules)
- Compress `type: "rationale"` units to `[rationale: X]`
- Compress `type: "metadata"` units to single-line header
- Merge adjacent IRUnits of same type in same section
- Strip decorative formatting

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

#### Stage 5 — Semantic Constraint Injection

**Method:** Structural reorganization + template fill.

1. Group IRUnits by `section` field into `Map<string, IRUnit[]>`
2. For each of the 10 universal sections: if IRUnits exist → use and reorganize; if none → inject placeholder: `<section_name> — This is currently unspecified and must be decided before use.`
3. Add type-specific sections: Skill detection (`name:` + `description:` in frontmatter) → Invocation Conditions, Forbidden Usage, Phase Separation. Plan detection (timeline/milestone language) → Data Model, Architecture, Key Operations
4. Convert ALL content to declarative language (apply hedging resolution)
5. Ensure at least one negative constraint exists — if none detected, inject: "Do not guess or imply defaults for unspecified behavior."
6. Run KERNEL validation checklist against section map

#### Stage 6 — Code Generation

**Method:** Template-based rendering from augmented IR.

1. Emit traceability header: `<!-- compiled from: {source_path} | {timestamp} -->`
2. For each of the 10 universal sections (canonical order): emit `## {Section Name}`, emit `<{section_tag}>` wrapper, emit each IRUnit (priority marker for P0, bullet for instructions/constraints, prose for facts/rationale, `IF/THEN/ELSE` if conditions present, negative framing if `negation: true`), emit `</{section_tag}>`
3. Emit type-specific sections the same way
4. Write to `{output_path}`

#### Per-Stage I/O Contracts

| Stage | Input | Output | Format |
|-------|-------|--------|--------|
| [1] Preprocessor | Source `.human.md` file path | Preprocessed source + annotation map | `(string, Map<string, Annotation[]>)` |
| [2] Structural Parse | Preprocessed source | DST (root node with children) | `DSTNode` tree |
| [3] Semantic IR Extraction | DST | Flat list of IRUnits | `IRUnit[]` |
| [4] Optimization Passes | IRUnits | Transformed IRUnits (filtered, tagged, linked) | `IRUnit[]` |
| [5] Semantic Constraint Injection | IRUnits | Augmented IRUnits with all 10 sections filled | `IRUnit[]` |
| [6] Code Generation | Augmented IRUnits | Final `.compiled.md` file | `string` → written to disk |

Each stage receives the previous stage's output as its sole input. No stage reads from disk directly (except Stage 1). No stage writes to disk directly (except Stage 6). Errors propagate up — any failure aborts the pipeline.

#### Per-Stage Error Handling

**Error model:** Every stage returns `Success(output)` or `Error(stage_name, code, message, context)`.

| Stage | Error Code | Meaning |
|-------|-----------|---------|
| [1] Preprocessor | `PRE_001` | Referenced file not found |
| | `PRE_002` | Conflicting/contradictory instructions or circular reference |
| | `PRE_003` | Ambiguous reference (multiple possible targets) |
| | `PRE_004` | Invalid directive syntax |
| [2] Structural Parse | `DST_001` | Malformed markdown (unclosed block) |
| | `DST_002` | Empty document (no parseable content) |
| [3] Semantic IR Extraction | `IR_001` | Unable to classify content into any semantic role |
| | `IR_002` | Circular reference detected |
| [4] Optimization | `OPT_001` | All content classified as filler (nothing to preserve) |
| | `OPT_002` | Priority conflict (two P0 constraints contradict) |
| [5] Constraint Injection | `SCI_001` | Too many unspecified sections (>3 universal sections empty) |
| | `SCI_002` | KERNEL validation failed (specify which principle) |
| [6] Code Generation | `GEN_001` | Output path not writable |
| | `GEN_002` | Template rendering failure |

**Error propagation:** Any error → pipeline halts immediately. Error displayed with stage name, code, human-readable description, and source location (line number from DST metadata). Temporary preprocessing document cleaned up on error. No partial output written. User must fix source and retry.

### Preprocessor Phase

(See Stage 1 specification above for full detail.)

**Key invariants:**
- **Conflict detection:** If preprocessor finds conflicts, contradictions, or ambiguities → document **MUST NOT compile**, user **MUST be alerted** to resolve contradictions.
- **File inclusion:** If referenced document found → include in compilation. If NOT found → **halt with clear error message**.
- **Gatekeeper rule:** Preprocessor must complete **FULLY** without errors before compiler can run. Only clean, unambiguous sources proceed to compilation.

### Compiler Phase (Stages 2–6)

Runs only if preprocessor completes successfully. Behaves like a real compiler:
- Deterministic output (converts probabilistic AI behavior to predictable results)
- Aggressive from the start (no gradual iteration)
- **HALTS entirely** on errors/ambiguities (no partial output)
- Clear error messages

### Post-Compile Validation

Agent-based verification ensures compiled output preserves all essential information from source. Runs after Stage 6 completes.

**Two-tier validation:**

**Tier 1 — Cheap Structural Check (runs automatically, fast, deterministic):**
- Verify all 10 universal sections present with XML-like tags
- Verify all type-specific sections present (based on document type)
- Verify declarative language used (no "try to", "ideally", "if possible")
- Verify negative constraints exist
- Verify uncertainty explicitly declared (not left implicit)
- Verify KERNEL framework compliance
- Fail = compilation fails with specific missing-element errors

**Tier 2 — Functional Equivalence Test (runs automatically, agent-based, pass/fail):**
- Give an AI agent the **source document** and ask it to perform a representative task from the document's domain
- Give a **separate** AI agent the **compiled document** and ask it the **identical** task
- Compare outputs: if both agents produce semantically equivalent results (same instructions followed, same constraints respected, same output structure), the test passes
- "Semantically equivalent" means: same actions taken, same constraints obeyed, same output format — not exact string match
- Threshold: 90%+ task equivalence across a benchmark suite of 5+ representative tasks
- Fail = compilation fails, user shown which tasks diverged and why

**Separate Verification Skill (expensive, on-demand):**
- Dedicated skill for deep analysis: full content coverage audit, constraint sufficiency check, conflict detection, edge case coverage
- Not part of the normal compilation pipeline — invoked manually for quality audits

---

## Bootstrap Strategy

**Reconciled approach:** "Aggressive from the start" refers to the architecture and ambition — the full 6-stage pipeline, all validation, all constraint injection. "Bootstrap" refers to the transformation aggressiveness within Stage 4, which ramps up through self-compilation. The pipeline is fully built (aggressive), but the transformation rules mature through iteration (bootstrap).

**Phase 1 — Minimum Viable Compiler (v0.1):**
- Implement Stages 1-3 (Preprocessor, DST, IR Extraction) with conservative transformation rules
- Stage 4: Only Pass 1 (strip filler per classification rules) — no tagging, no cross-referencing
- Stage 5: Basic section detection + placeholder injection for missing sections
- Stage 6: Simple markdown output (no XML tags yet)
- Test: Compile a simple Skill (e.g., `sas-endsession`) and verify output is usable

**Phase 2 — Full Pipeline (v1.0):**
- Add Stage 4 Pass 2 (tagging, priority markers, IF/THEN/ELSE)
- Add Stage 4 Pass 3 (cross-reference resolution, grouping)
- Add XML-like tag wrapping in Stage 6
- Add Tier 1 structural validation
- Test: Compile all existing Skills, verify Tier 1 passes

**Phase 3 — Self-Compilation (v2.0):**
- Write `SKILL.human.md` for `sas-semantic-compiler` itself
- Use v1.0 compiler to produce `SKILL.md`
- Validate output against Semantic Constraint Framework
- Iterate: refine Stage 4 transformation rules based on self-compilation results

**Phase 4 — Aggressive Optimization (v3.0+):**
- Add Tier 2 functional equivalence validation
- Refine filler classification rules based on real-world results
- Add the separate expensive verification skill
- Push transformation aggressiveness to the limit

**Key principle:** Each phase produces a working, usable compiler. The pipeline architecture never changes — only the transformation rules within Stage 4 and the validation rigor increase.

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

## Validation & Quality

### Post-Compile Verification
- **MUST run after every compilation**
- Agent-based verification
- **Test criterion:** Original and compiled produce same AI agent output
- Verification fails → compile fails

### Success Metrics
- **Primary method:** Post-compile verification (pass/fail)
  - Verification fails → compile fails
  - Verification passes → compile passes
- User sees clear, understandable results
- If verification fails, user adjusts source and retries
- Requires testing against real agent tasks

### Format Consistency
- All compiled documents conform to standard optimal format
- Already-optimized documents recompiled for consistency
- Predictability prioritized over preserving existing optimization

**Analogy:** Optimized C++ doesn't run on CPU — assembly does. C++ is human-friendly way to write assembly. Compiled markdown is **"assembly code"** for AI agents, human-readable markdown is **"C++ code"** for humans.

### Error Handling
- No dry run/preview mode
- No diff reports
- Humans won't inspect compiled files (for AI agents only)
- **CRUCIAL:** Error reporting must be clear so users can identify and fix source issues
- Recompile at will

---

## Naming
- **Skill name:** `sas-semantic-compiler`
- Follows `sas-` prefix convention

---

*Last updated: 13 April 2026*
