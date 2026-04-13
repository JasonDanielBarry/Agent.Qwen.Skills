# 04 — Pipeline Architecture

## Compilation Pipeline — 6-Stage Design

**Do we replicate the C++ pipeline 1:1?** No. The C++ pipeline exists because of specific problems: complex type systems, memory layout, cross-file symbol resolution, and CPU architecture targets. Markdown for AI agents has a completely different profile.

### What to Drop
- **The Linker:** Our preprocessor already handles `#include`-style document resolution *before* compilation. There is no separate "object file" stage.
- **Full Traditional AST:** Markdown doesn't have scopes, type hierarchies, template instantiations, or memory lifetimes.

### What to Keep (But Simplify)
- **Document Structure Tree (DST)** instead of AST: A lightweight tree for optimization passes to traverse
- **Intermediate Representation (IR):** Crucial — separates "what this means" from "how it's written", enables format swapping, IR validation, and composable optimization passes

### Pipeline Diagram

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

### C++ Comparison Table

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

---

## Sub-Agent Execution Model

**Invariant — Fresh sub-agent per stage/pass:** Each of the 6 pipeline stages and each of the 3 Stage 4 optimization passes MUST execute in a separate sub-agent. Reusing a single agent across multiple stages or passes is forbidden. The overhead of spawning new agents (latency, initialization cost) is accepted — it is outweighed by the guarantee of fresh context isolation. Sub-agent termination (process exit) is the only mechanism that provides structural context isolation. Instruction-based "context clearing" is not a valid substitute.

### Execution model

The compilation pipeline runs as **9 discrete sub-agent invocations**:

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

### Sub-agent lifecycle

Every sub-agent follows the same pattern:

1. **Spawn** — parent agent creates a fresh sub-agent
2. **Load** — sub-agent receives exactly two things: (a) the compilation skill instructions (SKILL.md), and (b) the output files from the previous stage/pass on disk. Nothing else.
3. **Process** — sub-agent performs its stage's transformation per the pipeline specification
4. **Write** — sub-agent writes its output files to the `.DocName.compilation/` folder
5. **Terminate** — sub-agent exits. Process destruction = guaranteed context destruction. No residue, no memory, no carryover.

### Zero initial context

Before the first sub-agent spawns, the agent has zero context about the document being compiled, its content, or any compilation stage. No preloading. No assumptions. No prior knowledge.

### Sole information boundary

The only information a sub-agent has about its stage is the output files from the previous stage loaded from disk. The sub-agent MUST NOT reference, recall, or infer content from any other stage's output.

### Why sub-agents, not one agent

| Concern | Single agent across stages | Sub-agent per stage/pass |
|---------|---------------------------|--------------------------|
| Context residue | Inevitable — conversation history accumulates | Impossible — agent is destroyed after each stage |
| Cross-stage contamination | Possible — agent may shortcut by referencing earlier representations | Structurally prevented — only current stage's inputs are available |
| Error recovery | Must unwind accumulated reasoning state | Spawn fresh agent against same input files |
| Determinism enforcement | Instruction-dependent ("please forget") | Structural guarantee (agent no longer exists) |
| Determinism measurement | Cannot isolate per-stage output variance | Run two agents on same input, diff outputs |

---

## Stage Specifications

### Stage 1 — Preprocessor

Modeled after C/C++ preprocessor.

**Preprocessing output:** Created during preprocessing with expanded macros, included files, and annotations for conflict detection/filler identification. Aids the compilation phase. **Persisted permanently** in the `.DocName.compilation/stage-1-preprocessor/` folder for auditability and error diagnosis. Not deleted after compilation.

**Conflict detection:** Conflicts, contradictions, or ambiguities → document **MUST NOT compile**, user **MUST be alerted** to resolve.

**File inclusion:** Referenced document found → include. NOT found → **halt with clear error message**.

**Gatekeeper rule:** Preprocessor must complete **FULLY** without errors before compiler can run. Only clean, unambiguous sources proceed.

### Stage 2 — Structural Parse (DST)

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

### Stage 3 — Semantic IR Extraction

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

### Stage 4 — Optimization Passes

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

### Stage 5 — Semantic Constraint Injection

**Method:** Structural reorganization + template fill.

1. Group IRUnits by `section` field into `Map<string, IRUnit[]>`
2. For each of the 10 universal sections: if IRUnits exist → use and reorganize; if none → inject placeholder: `<section_name> — This is currently unspecified and must be decided before use.`
3. Add type-specific sections: Skill detection (`name:` + `description:` in frontmatter) → Invocation Conditions, Forbidden Usage, Phase Separation. Plan detection (timeline/milestone language) → Data Model, Architecture, Key Operations
4. Convert ALL content to declarative language (apply hedging resolution)
5. Ensure at least one negative constraint exists — if none detected, inject: "Do not guess or imply defaults for unspecified behavior."
6. Run KERNEL validation checklist against section map

### Stage 6 — Code Generation

**Method:** Template-based rendering from augmented IR.

1. Emit traceability header: `<!-- compiled from: {source_path} | {timestamp} -->`
2. For each of the 10 universal sections (canonical order): emit `## {Section Name}`, emit `<{section_tag}>` wrapper, emit each IRUnit (priority marker for P0, bullet for instructions/constraints, prose for facts/rationale, `IF/THEN/ELSE` if conditions present, negative framing if `negation: true`), emit `</{section_tag}>`
3. Emit type-specific sections the same way
4. Write to `{output_path}`

---

## Per-Stage I/O Contracts

| Stage | Input | Output | Format |
|-------|-------|--------|--------|
| [1] Preprocessor | Source `.human.md` file path | Preprocessed source + annotation map | `(string, Map<string, Annotation[]>)` |
| [2] Structural Parse | Preprocessed source | DST (root node with children) | `DSTNode` tree |
| [3] Semantic IR Extraction | DST | Flat list of IRUnits | `IRUnit[]` |
| [4] Optimization Passes | IRUnits | Transformed IRUnits (filtered, tagged, linked) | `IRUnit[]` |
| [5] Semantic Constraint Injection | IRUnits | Augmented IRUnits with all 10 sections filled | `IRUnit[]` |
| [6] Code Generation | Augmented IRUnits | Final `.compiled.md` file | `string` → written to disk |

Each stage receives the previous stage's output as its sole input. No stage reads from disk directly (except Stage 1). No stage writes to disk directly (except Stage 6). Errors propagate up — any failure aborts the pipeline.

---

## Per-Stage Error Handling

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

**Error propagation:** Any error → pipeline halts immediately. Error displayed with stage name, code, human-readable description, and source location (line number from DST metadata). All intermediate files up to the point of failure are retained in the `.DocName.compilation/` folder for diagnosis. No partial output written to final destination. User must fix source and retry.

---

## Preprocessor Phase

(See Stage 1 specification above for full detail.)

**Key invariants:**
- **Conflict detection:** If preprocessor finds conflicts, contradictions, or ambiguities → document **MUST NOT compile**, user **MUST be alerted** to resolve contradictions.
- **File inclusion:** If referenced document found → include in compilation. If NOT found → **halt with clear error message**.
- **Gatekeeper rule:** Preprocessor must complete **FULLY** without errors before compiler can run. Only clean, unambiguous sources proceed to compilation.

---

## Compiler Phase (Stages 2–6)

Runs only if preprocessor completes successfully. Behaves like a real compiler:
- Deterministic output (converts probabilistic AI behavior to predictable results)
- Aggressive from the start (no gradual iteration)
- **HALTS entirely** on errors/ambiguities (no partial output)
- Clear error messages

---

*Last updated: 13 April 2026*
