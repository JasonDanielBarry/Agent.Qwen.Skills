# Implementation Plan: `sas-semantic-compiler` — Bootstrap Phase 1 (v0.1)

## What goes where

**Architecture documents** → copied into the skill folder so the skill is self-contained:

```
skills/sas-semantic-compiler/
├── SKILL.md                          ← the compiled skill (output artifact)
├── SKILL.human.md                    ← the human-editable source
├── architecture/                     ← copy of the markdown-compiler-architecture folder
│   ├── README.md
│   ├── 01-overview.md
│   ├── 02-transformation-rules.md
│   ├── 03-semantic-constraints.md
│   ├── 04-pipeline-architecture.md
│   ├── 05-compilation-file-structure.md
│   ├── 06-execution-workflow.md
│   ├── 07-cross-reference-resolution.md
│   ├── 08-output-format.md
│   ├── 09-validation.md
│   ├── 10-bootstrap-strategy.md
│   └── 11-operational-concerns.md
├── scripts/                          ← helper scripts (if needed)
└── templates/                        ← output templates (if needed)
```

## Phase 1 scope (v0.1 — MVP)

Per `10-bootstrap-strategy.md`:

1. **`SKILL.human.md`** — human-readable source describing the full 6-stage pipeline, all stage specifications, I/O contracts, error codes, sub-agent execution model, file structure, transformation rules, semantic constraints, cross-reference resolution, output format, validation, and bootstrap strategy. Written as a complete, instructional skill document.

2. **`SKILL.md`** — Phase 1 compiled output (hand-crafted for now, since the compiler doesn't exist yet to compile itself). This will be a simplified but functional version implementing:
   - **Stages 1-3**: Full Preprocessor, Structural Parse (DST), Semantic IR Extraction
   - **Stage 4 Pass 1 only**: Strip filler (per 8-category classification), compress rationale/metadata
   - **Stage 4 Pass 2 & 3**: Skipped (no tagging, no cross-referencing)
   - **Stage 5**: Basic section detection + placeholder injection for missing universal sections
   - **Stage 6**: Simple markdown output (no XML tags yet)

3. **Architecture folder** — all 12 files from `development-docs/feature/markdown-compiler-architecture/` copied into `skills/sas-semantic-compiler/architecture/` so the architecture travels with the skill.

## Steps

### Step 1: Copy architecture files
Copy all 12 files from `development-docs/feature/markdown-compiler-architecture/` → `skills/sas-semantic-compiler/architecture/`

### Step 2: Write `SKILL.human.md`
The full human-readable compiler skill, following the architecture spec. This describes:

- The 6-stage pipeline with all specifications
- Sub-agent per stage/pass invariant
- File structure and persistence rules
- Transformation rules (syntactic + semantic)
- Filler classification (8 categories)
- 10 universal required sections
- Declarative language rules
- KERNEL framework validation
- Error codes and handling per stage
- Cross-reference resolution
- Output format (markdown + XML tags for future phases)
- Bootstrap strategy
- Operational concerns (git, invocation, naming)

### Step 3: Write `SKILL.md` (Phase 1 compiled output)
The AI-optimized version of the skill, implementing only Phase 1 capabilities:

- Stages 1-3 fully implemented
- Stage 4: Pass 1 only (strip filler)
- Stage 5: Basic section detection + placeholder injection
- Stage 6: Simple markdown output (no XML tags)
- All error codes for stages 1-6
- File structure specification
- Sub-agent execution model
- Phase 1 limitations clearly documented

### Step 4: Test
Use the skill to conceptually compile `sas-endsession` and verify the output would be usable.

## What's deferred to Phase 2+

| Feature | Phase |
|---------|-------|
| XML-like tag wrapping in output | Phase 2 |
| Stage 4 Pass 2 (tagging, priority markers, IF/THEN/ELSE) | Phase 2 |
| Stage 4 Pass 3 (cross-reference resolution) | Phase 2 |
| Tier 1 structural validation | Phase 2 |
| Self-compilation (use v1.0 to compile itself) | Phase 3 |
| Tier 2 functional equivalence validation | Phase 4 |
| Separate expensive verification skill | Phase 4 |

---

*Created: 13 April 2026*
