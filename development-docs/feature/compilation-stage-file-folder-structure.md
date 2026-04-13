# Compilation Stage File-Folder Structure

## Overview

This document defines the persistent folder structure used during the 6-stage compilation pipeline. All intermediate files are **permanently persisted** on disk — not temporary — so the agent can reference them between stages, recover from errors, and audit outputs.

**Design principle:** Trust file persistence over AI context window memory. Each stage reads only what it needs, writes its output, and the context is cleared before the next stage.

---

## Folder Structure

For a source document `DocX.human.md` located in directory `X/`, the compilation produces:

```
X/
├── DocX.human.md               ← source document (human-edited)
├── DocX.compiled.md            ← compiled output (final artifact)
└── .DocX.compilation/
    ├── stage-1-preprocessor/
    │   ├── preprocessed.md        ← source with macros expanded, files included
    │   └── annotations.json       ← filler classifications, conflict detection results, preprocessing metadata
    ├── stage-2-dst/
    │   └── dst.json               ← Document Structure Tree (full tree representation)
    ├── stage-3-ir/
    │   └── ir.json                ← Semantic IR units (flat list, before optimization)
    ├── stage-4-optimized/
    │   ├── ir-pass-1.json         ← after strip & compress
    │   ├── ir-pass-2.json         ← after tag & structure
    │   └── ir-pass-3.json         ← after cross-reference & group (final optimized IR)
    ├── stage-5-constrained/
    │   └── ir-augmented.json      ← IR with all 10 universal sections filled, KERNEL validated
    └── stage-6-generated/
        └── output-draft.md        ← rendered markdown before post-compile validation
```

### Naming Convention

| Pattern | Meaning |
|---------|---------|
| `.DocName.compilation/` | Hidden directory named after the **source file stem** (without extension) |
| `stage-N-name/` | Subfolder per pipeline stage, numbered for ordering |
| Files within stage folders | Descriptive names indicating content and format |

**Source file stem derivation:**
- `skills/sas-endsession/SKILL.human.md` → `.SKILL.compilation/` (stem is `SKILL`)
- `plans/release-plan.human.md` → `.release-plan.compilation/` (stem is `release-plan`)
- `docs/architecture.human.md` → `.architecture.compilation/` (stem is `architecture`)

**Collision handling:** If two source files share the same stem in the same directory (e.g., `SKILL.human.md` and `SKILL.reference.human.md`), use the full stem: `.SKILL.compilation/` for the first, `.SKILL.reference.compilation/` for the second.

---

## File Specifications

### Stage 1 — Preprocessor

#### `preprocessed.md`
The source document after:
- Macro expansion
- File inclusion (referenced documents inlined with boundaries)
- Filler identification and annotation (content marked but not yet removed)
- Conflict/contradiction flagging

**Format:** Markdown with HTML comment annotations for preprocessing metadata.

**Example annotations:**
```markdown
<!-- annotation: filler | line 12 | classification: verbose_filler | action: remove -->
<!-- annotation: conflict | line 45 | type: contradictory_constraint | severity: error -->
<!-- annotation: included | line 78 | source: shared-terminology.md | start -->
...included content...
<!-- annotation: included | source: shared-terminology.md | end -->
```

#### `annotations.json`
Structured metadata from preprocessing.

**Format:**
```json
{
  "source_file": "skills/sas-endsession/SKILL.human.md",
  "preprocessed_at": "2026-04-13T14:30:00Z",
  "filler_classifications": [
    {
      "line": 12,
      "content_excerpt": "This is a helpful skill that...",
      "classification": "verbose_filler",
      "action": "remove"
    }
  ],
  "conflicts": [
    {
      "lines": [45, 89],
      "type": "contradictory_constraint",
      "description": "Section A says X must happen; Section B says X must not happen",
      "severity": "error"
    }
  ],
  "included_files": [
    {
      "path": "shared-terminology.md",
      "included_at_line": 78,
      "status": "resolved"
    }
  ],
  "gatekeeper_status": "passed" | "failed"
}
```

---

### Stage 2 — Structural Parse (DST)

#### `dst.json`
The Document Structure Tree — a traversable tree of all blocks in the preprocessed source.

**Format:**
```json
{
  "type": "root",
  "children": [
    {
      "type": "heading",
      "level": 1,
      "content": "End Session",
      "metadata": {
        "source_line": 1,
        "section_path": "End Session"
      },
      "children": [
        {
          "type": "paragraph",
          "content": "Save a session handoff note...",
          "metadata": {
            "source_line": 3,
            "section_path": "End Session > Purpose"
          }
        }
      ]
    }
  ]
}
```

**Full node schema (from key takeaways document):**
```
DSTNode {
  type: "heading" | "paragraph" | "list" | "ordered_list" | "table" | "code_block" | "blockquote" | "thematic_break" | "link" | "image" | "html"
  level: int?              // For headings only (1-6)
  content: string          // Raw text/markdown of the block
  children: DSTNode[]      // For lists: items; for headings: following blocks until next same/higher level heading heading
  metadata: {
    source_line: int       // Original line number for error reporting
    section_path: string   // Full heading path (e.g., "Architecture > Pipeline")
    semantic_role: string? // Added during Stage 3
  }
}
```

---

### Stage 3 — Semantic IR Extraction

#### `ir.json`
Flat list of semantic units extracted from the DST, all markdown formatting stripped.

**Format:**
```json
{
  "extracted_at": "2026-04-13T14:30:01Z",
  "source_dst": "stage-2-dst/dst.json",
  "units": [
    {
      "id": "sec-purpose-001",
      "type": "instruction",
      "section": "Purpose",
      "content": "Save a lightweight session handoff note when ending work",
      "priority": "P0",
      "conditions": [],
      "references": [],
      "negation": false
    },
    {
      "id": "sec-constraints-001",
      "type": "constraint",
      "section": "Constraints",
      "content": "Do not write session notes in user-visible directories",
      "priority": "P0",
      "conditions": [],
      "references": [],
      "negation": true
    }
  ]
}
```

**IRUnit schema (from key takeaways document):**
```
IRUnit {
  id: string                // e.g., "sec-purpose-001"
  type: "instruction" | "constraint" | "fact" | "example" | "rationale" | "edge_case" | "invariant" | "failure_mode" | "guarantee" | "input" | "output" | "relationship" | "validation" | "metadata" | "filler"
  section: string           // Target section (e.g., "Purpose", "Constraints")
  content: string           // Cleaned text, no markdown syntax
  priority: "P0" | "P1" | "P2"
  conditions: Condition[]
  references: string[]      // IDs of other IRUnits referenced
  negation: boolean
}

Condition {
  predicate: string
  then: IRUnit[]
  else: IRUnit[]
}
```

---

### Stage 4 — Optimization Passes

Three sub-passes, each writing its output. The final pass output (`ir-pass-3.json`) is the input to Stage 5.

#### `ir-pass-1.json` — Strip & Compress
After:
- Removing all `type: "filler"` units
- Compressing `rationale` units to `[rationale: X]`
- Compressing `metadata` units to single-line
- Merging adjacent units of same type in same section
- Stripping decorative formatting

#### `ir-pass-2.json` — Tag & Structure
After:
- Assigning explicit IDs to every unit
- Adding priority markers (P0/P1/P2)
- Converting conditional prose into explicit `Condition` objects
- Marking negative constraints
- Wrapping examples in generalized schema patterns

#### `ir-pass-3.json` — Cross-Reference & Group
After:
- Resolving references by matching anchors/IDs
- Grouping related units by semantic affinity
- Adding cross-reference links between sections
- Deduplicating units with identical content

**Note:** For production runs where per-pass debugging is not needed, only `ir-pass-3.json` (the final state) is required. A `--debug-passes` flag can be added later to emit all three. During bootstrap phases (v0.1–v1.0), keeping all three is recommended for development.

---

### Stage 5 — Semantic Constraint Injection

#### `ir-augmented.json`
After:
- Grouping IR units by section into a section map
- Ensuring all 10 universal sections are present (injecting placeholders for missing ones)
- Adding type-specific sections (Skill or Plan detection)
- Converting all content to declarative language
- Ensuring at least one negative constraint exists
- Validating against KERNEL framework

**Format:** Same structure as `ir.json` / `ir-pass-3.json` but with all sections populated and framework-compliant units.

```json
{
  "injected_at": "2026-04-13T14:30:04Z",
  "source_ir": "stage-4-optimized/ir-pass-3.json",
  "section_map": {
    "Purpose": ["sec-purpose-001"],
    "Scope": ["sec-scope-001", "sec-scope-002"],
    "Inputs": ["sec-inputs-001"],
    "Outputs": ["sec-outputs-001"],
    "Constraints": ["sec-constraints-001", "sec-constraints-002"],
    "Invariants": ["sec-invariants-001"],
    "Failure Modes": ["sec-failure-001"],
    "Validation Strategy": ["sec-validation-001"],
    "Relationships": ["sec-relationships-001"],
    "Guarantees": ["sec-guarantees-001"]
  },
  "kernel_validation": {
    "K": "passed",
    "E": "passed",
    "R": "passed",
    "N": "passed",
    "E": "passed",
    "L": "passed"
  },
  "units": [...]
}
```

---

### Stage 6 — Code Generation

#### `output-draft.md`
The rendered markdown output before post-compile validation.

**Format:** Markdown with XML-like tags for section boundaries, traceability header, all 10 universal sections in canonical order, type-specific sections, declarative language, priority markers, IF/THEN/ELSE blocks.

**After validation passes**, this file is copied to the final output location (`X/DocX.md` or `X/SKILL.md` for Skills).

---

## Context Window Workflow

The agent follows a **load → process → write → clear** cycle for each stage:

```
1. Load compilation skill (SKILL.md) into context
   Load source document path
   Run Stage 1 → write stage-1-preprocessor/ files
   Clear context

2. Load compilation skill (SKILL.md) into context
   Load stage-1-preprocessor/ output files
   Run Stage 2 → write stage-2-dst/ files
   Clear context

3. Load compilation skill (SKILL.md) into context
   Load stage-2-dst/ output files
   Run Stage 3 → write stage-3-ir/ files
   Clear context

4. Load compilation skill (SKILL.md) into context
   Load stage-3-ir/ output files
   Run Stage 4 (all 3 passes) → write stage-4-optimized/ files
   Clear context

5. Load compilation skill (SKILL.md) into context
   Load stage-4-optimized/ output files
   Run Stage 5 → write stage-5-constrained/ files
   Clear context

6. Load compilation skill (SKILL.md) into context
   Load stage-5-constrained/ output files
   Run Stage 6 → write stage-6-generated/ files
   Clear context

7. Run post-compile validation on stage-6-generated/output-draft.md
   If validation passes → copy to final output path
   If validation fails → report errors, leave compilation folder intact for diagnosis
```

### Why This Workflow

| Benefit | Explanation |
|---------|-------------|
| **Minimizes context contamination** | Each stage sees only its own inputs and the skill instructions. No mixing of representations from different stages. |
| **Enforces pipeline discipline** | The agent cannot shortcut by referencing data from earlier stages — it must use the proper input files. |
| **Enables error recovery** | If Stage 3 fails, re-run only Stage 3. Its inputs are already on disk. |
| **Supports auditability** | Any stage's output can be inspected to diagnose issues or verify correctness. |
| **Allows parallel compilation** | Multiple documents can compile simultaneously since each has its own isolated `.compilation/` folder. |
| **Reduces attention dilution** | The agent's context window contains only relevant data for the current stage, not accumulated residue from earlier stages. |

### Clarification on "Hallucinations"

The term "hallucination" (model fabricating facts) is not precisely what this prevents. The actual benefits are:

1. **Context contamination** — The model mixing representations from different stages, losing track of which data is current, or producing output that references stale intermediate forms.

2. **Attention dilution** — As context fills, models attend less precisely to content. Empirical research shows attention degrades at context edges and exhibits "lost in the middle" phenomena. Fresh loads keep relevant content prominent.

3. **Stage boundary enforcement** — File persistence makes pipeline discipline involuntary. The agent cannot "cheat" by looking at Stage 1 output while running Stage 4, because it's not in context.

These are distinct from hallucination but equally damaging to compilation correctness.

---

## Cleanup and Lifecycle

### What Gets Cleaned Up

| Scenario | Action |
|----------|--------|
| **Successful compilation + validation** | `.DocName.compilation/` folder **is retained** for auditability |
| **Failed compilation** | `.DocName.compilation/` folder **is retained** up to the failed stage for diagnosis |
| **Source document recompiled** | Existing `.DocName.compilation/` folder **is overwritten** (new files replace old) |
| **Source document deleted** | `.DocName.compilation/` folder **should be deleted** (orphaned build artifact) |
| **Manual cleanup requested** | Delete `.DocName.compilation/` folder |

### Git Configuration

All `.compilation/` folders are **reproducible build artifacts** and should be git-ignored:

```gitignore
# Compilation intermediate files (reproducible build artifacts)
*.compilation/
```

The compiled output (e.g., `SKILL.md`) **is committed** — it's the deliverable artifact. The source (e.g., `SKILL.human.md`) **is committed** — it's the human-editable source. The compilation folder is **never committed** — it can always be regenerated.

### Disk Space Considerations

Compilation folders are typically 2–5× the size of the source document (JSON representations are verbose). For a 500-line source document, expect ~50–100KB of intermediate files. These are cheap to store and valuable to retain.

If disk space becomes a concern, provide a cleanup command:
```
sas-semantic-compiler cleanup <directory>  -- removes all .compilation/ folders
```

---

## Cross-Document Reference Resolution

When compiling documents that reference each other (e.g., A.human.md links to B.human.md):

1. **Detect references** during Stage 1 preprocessing
2. **Compile referenced documents first** (dependency order — leaves before roots)
3. **Read the referenced document's Stage 3 or Stage 5 output** from its `.compilation/` folder instead of re-parsing the raw source
4. **Inline or link** the referenced content per the key takeaways specification

This means compilation order matters for cross-referenced documents:

```
A.human.md → references → B.human.md → references → C.human.md

Compilation order:
1. C.human.md (leaf — no references out)
2. B.human.md (references C, which is now compiled)
3. A.human.md (references B, which is now compiled)
```

**Maximum reference depth:** 5 levels (from key takeaways document). Circular references halt compilation with `PRE_002` error.

---

## Error Diagnosis Using Compilation Folders

When compilation fails, the error message includes:
- Stage name (e.g., "Stage 3 — Semantic IR Extraction")
- Error code (e.g., `IR_001`)
- Human-readable description
- Source location (line number from DST metadata)

**Diagnosis workflow:**

1. Read the error message to identify the failing stage
2. Open the corresponding stage folder in `.DocName.compilation/`
3. Inspect the output files to see what the stage produced
4. If needed, inspect the **previous** stage's output to verify its inputs were correct
5. Fix the source document and recompile

**Example:**
```
Error: Stage 3 — Semantic IR Extraction (IR_001)
  Unable to classify content into any semantic role
  Source location: line 47 in preprocessed source
  
Diagnosis:
  → Open .DocName.compilation/stage-3-ir/ir.json
    Check which content block failed classification
  → Open .DocName.compilation/stage-2-dst/dst.json
    Navigate to line 47's node to see the raw DST structure
  → Open .DocName.compilation/stage-1-preprocessor/preprocessed.md
    Read line 47 to see the original text that couldn't be classified
  → Fix the source document to make the intent clearer
  → Recompile
```

---

## Relationship to Key Takeaways Document

This document **supplements** the [markdown-compiler-skill-key-takeaways.md](./markdown-compiler-skill-key-takeaways.md) file. It does not replace it.

**What the key takeaways covers:**
- Transformation approach (syntactic + semantic)
- Filler classification rules
- 10 universal required sections
- KERNEL framework
- Naming conventions for source/output files
- Pipeline architecture (6 stages)
- Bootstrap strategy
- Validation requirements

**What this document covers:**
- Persistent folder structure for each stage
- File formats and schemas
- Context window workflow
- Cleanup and lifecycle management
- Cross-document reference resolution using folders
- Error diagnosis using compilation folders

---

*Last updated: 13 April 2026*
