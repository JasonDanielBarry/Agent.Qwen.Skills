# 06 — Execution Workflow

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

*Last updated: 13 April 2026*
