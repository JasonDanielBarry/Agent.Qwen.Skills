# 05 — Compilation File Structure

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

**Full node schema:**
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

**IRUnit schema:**
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

**Design decision:** All three pass files are permanently retained. Each pass represents a distinct transformation with a clear input/output contract, and preserving all three provides a complete audit trail — you can diff pass-1 vs pass-2 to see exactly what tagging and prioritization added, or pass-2 vs pass-3 to see what cross-reference resolution changed. This aligns with the broader principle of trusting file persistence over context memory: if you need to understand why the optimizer produced a certain result, the intermediate files are always available for inspection.

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

**After validation passes**, this file is copied to the final output location (`X/DocX.compiled.md` or `X/SKILL.md` for Skills).

---

*Last updated: 13 April 2026*
