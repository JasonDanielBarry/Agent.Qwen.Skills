# 06 — Execution Workflow

## Sub-Agent Orchestration Model

**Invariant — Fresh sub-agent per stage/pass:** Each of the 6 pipeline stages and each of the 3 Stage 4 optimization passes MUST execute in a separate sub-agent. Reusing a single agent across multiple stages or passes is forbidden. The overhead of spawning new agents (latency, initialization cost) is accepted — it is outweighed by the guarantee of fresh context isolation. Sub-agent termination (process exit) is the only mechanism that provides structural context isolation. Instruction-based "context clearing" is not a valid substitute.

Each stage runs as: **spawn agent → load skill + previous stage's output files → process → write files → terminate agent.**

```
1. Spawn Agent 1 (Stage 1 — Preprocessor)
   Load: compilation skill (SKILL.md) + source document
   Run Stage 1 → write stage-1-preprocessor/ files
   Terminate Agent 1 (context destroyed by process exit)

2. Spawn Agent 2 (Stage 2 — Structural Parse)
   Load: compilation skill (SKILL.md) + stage-1-preprocessor/ output files
   Run Stage 2 → write stage-2-dst/ files
   Terminate Agent 2

3. Spawn Agent 3 (Stage 3 — Semantic IR Extraction)
   Load: compilation skill (SKILL.md) + stage-2-dst/ output files
   Run Stage 3 → write stage-3-ir/ files
   Terminate Agent 3

4. Spawn Agent 4 (Stage 4 Pass 1 — Strip & Compress)
   Load: compilation skill (SKILL.md) + stage-3-ir/ output files
   Run Pass 1 → write stage-4-optimized/ir-pass-1.json
   Terminate Agent 4

5. Spawn Agent 5 (Stage 4 Pass 2 — Tag & Structure)
   Load: compilation skill (SKILL.md) + stage-4-optimized/ir-pass-1.json
   Run Pass 2 → write stage-4-optimized/ir-pass-2.json
   Terminate Agent 5

6. Spawn Agent 6 (Stage 4 Pass 3 — Cross-Reference & Group)
   Load: compilation skill (SKILL.md) + stage-4-optimized/ir-pass-2.json
   Run Pass 3 → write stage-4-optimized/ir-pass-3.json
   Terminate Agent 6

7. Spawn Agent 7 (Stage 5 — Semantic Constraint Injection)
   Load: compilation skill (SKILL.md) + stage-4-optimized/ir-pass-3.json
   Run Stage 5 → write stage-5-constrained/ files
   Terminate Agent 7

8. Spawn Agent 8 (Stage 6 — Code Generation)
   Load: compilation skill (SKILL.md) + stage-5-constrained/ output files
   Run Stage 6 → write stage-6-generated/ files
   Terminate Agent 8

9. Run post-compile validation on stage-6-generated/output-draft.md
   If validation passes → copy to final output path
   If validation fails → report errors, leave compilation folder intact for diagnosis
```

### Zero initial context

Before the first sub-agent spawns, the agent has zero context about the document being compiled, its content, or any compilation stage. No preloading. No assumptions. No prior knowledge.

### Sole information boundary

The only information a sub-agent has about its stage is the output files from the previous stage loaded from disk. The sub-agent MUST NOT reference, recall, or infer content from any other stage's output.

### Why sub-agent per stage/pass

| Benefit | Explanation |
|---------|-------------|
| **Eliminates context residue** | Sub-agent termination (process exit) guarantees zero carryover. Conversation history is destroyed, not just "cleared" by instruction. |
| **Enforces pipeline discipline** | The sub-agent cannot shortcut by referencing data from earlier stages — it structurally has no access to them. Only its input files exist. |
| **Enables error recovery** | If Pass 2 fails, spawn a fresh agent against the same Pass 1 output. No need to unwind accumulated reasoning state. |
| **Supports auditability** | Each stage's output is on disk independently. Any stage can be inspected to diagnose issues. |
| **Allows parallel compilation** | Multiple documents can compile simultaneously — each sub-agent is independent with its own `.compilation/` folder. |
| **Guarantees determinism** | Structural isolation, not behavioral compliance. The thing that knew the previous stage's content no longer exists. |

### Clarification on context isolation

The term "hallucination" (model fabricating facts) is not precisely what sub-agent isolation prevents. The actual risks eliminated are:

1. **Context residue** — A single agent carrying representations from earlier stages into later ones. With sub-agents, this is structurally impossible: the agent that held Stage 1's content is destroyed before Stage 2 spawns.

2. **Cross-stage contamination** — An agent referencing Stage 1's raw text while running Stage 4's optimization, producing output that mixes intermediate forms. Sub-agents have access to exactly one stage's output — their designated input files on disk.

3. **Attention dilution** — Irrelevant when each sub-agent sees only its own input. The context window is focused by construction, not by instruction.

These are distinct from hallucination but equally damaging to compilation correctness. Sub-agent isolation eliminates all three by structural design.

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
