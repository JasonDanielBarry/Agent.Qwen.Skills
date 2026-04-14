# Tier 2 Functional Equivalence Validation — Phase 4 Step 6

**Date:** 14 April 2026
**Status:** Implemented

---

## Overview

Phase 4 Step 6 implements Tier 2 functional equivalence validation for the semantic compiler pipeline. This validates that compiled SKILL.md files are functionally equivalent to their source SKILL.human.md files.

---

## What Was Delivered

### 1. Benchmark Task Suite (`benchmarks/tier-2-benchmarks.md`)

25 benchmark tasks defined across 5 skills (5 tasks per skill):

| Skill | T1 Happy Path | T2 Edge Case | T3 Constraint Obedience | T4 Failure Mode | T5 Multi-Step |
|-------|--------------|--------------|------------------------|-----------------|---------------|
| sas-endsession | Normal session end | Nothing completed | No confirmation prompt | .sessions/ missing | Full end-to-end |
| sas-git-commit-and-push | Standard commit/push | No changes | Never ask permission | Push rejected (no upstream) | Mixed doc+code changes |
| sas-git-merge | Clean fast-forward merge | Detached HEAD | No auto-resolve conflicts | Dirty working tree | Full merge + post-merge |
| sas-reattach | Normal reattach | Different workspace session | Not from subdirectory | No .sessions/ directory | Merge with existing todo list |
| sas-self-healing-memory | Write new memory entry | Derivable fact | Verify before using | Memory conflicts with code | Full CRUD+ lifecycle |

### 2. Equivalence Test Procedure

**Execution flow:**
1. Grader agent loads both SKILL.human.md and SKILL.md
2. For each benchmark task: spawn Source Agent and Compiled Agent separately
3. Both agents execute the identical task; grader compares outputs against rubric
4. Each task has specific graded criteria (PASS/FAIL per criterion)
5. Task passes only if ALL criteria pass

### 3. Pass Threshold

- **95% equivalence** — max 1 failure in 25-task suite
- May be dialed back to 90% if initial runs show too many false negatives from stochastic agent behavior
- FLAKY handling: failed task re-run once; second-run pass = FLAKY (pass but flagged)

### 4. Failure Reporting

When Tier 2 fails:
- Which tasks failed
- Which specific criteria failed per task
- Source vs compiled agent behavior (side-by-side)
- Root cause hypothesis (which compilation stage likely caused divergence)

### 5. Result Format

JSON output to `benchmarks/results/tier2-result-YYYYMMDD-HHmmss.json`:
- Per-task status (PASS/FAIL/FLAKY)
- Per-criterion results
- Aggregate pass rate
- Overall Tier 2 result

---

## Files Modified/Created

| File | Change |
|------|--------|
| `skills/sas-semantic-compiler/benchmarks/tier-2-benchmarks.md` | **Created** — full benchmark suite (25 tasks) |
| `skills/sas-semantic-compiler/architecture/09-validation.md` | **Updated** — Tier 2 spec expanded from 6 bullet points to full procedure |
| `skills/sas-semantic-compiler/SKILL.human.md` | **Updated** — Tier 2 section rewritten with full spec |
| `skills/sas-semantic-compiler/SKILL.md` | **Updated** — Tier 2 section recompiled, phase_separation table updated |
| `skills/sas-semantic-compiler/architecture/10-bootstrap-strategy.md` | **Updated** — Phase 4 Step 6 marked DONE |

---

## Design Decisions

### Why 5 dimensions per skill?
The 5 dimensions (Happy Path, Edge Case, Constraint Obedience, Failure Mode, Multi-Step) cover the full capability range of any skill:
- Happy Path tests basic functionality
- Edge Case tests boundary condition handling
- Constraint Obedience tests P0 invariant enforcement (the most critical for semantic correctness)
- Failure Mode tests error response behavior
- Multi-Step tests complete procedural execution

### Why 95% not 100%?
Agent behavior has inherent non-determinism. 100% would produce false negatives from stochastic differences rather than actual compilation bugs. 95% catches real regressions while tolerating noise.

### Why 5 skills × 5 tasks = 25?
All 5 existing skills are compiled outputs of the pipeline. Testing all of them ensures no skill type is unvalidated. 5 tasks per skill provides coverage across all capability dimensions without excessive cost.

### Grading approach: criteria-based, not text-based
Each task defines specific graded criteria (e.g., "report written to correct path", "does NOT ask for permission"). The grader checks whether both agents satisfied each criterion — not whether their output text matches. This is semantic equivalence, not string equality.

---

## Next Steps

- **Phase 4 Step 7:** Create `sas-semantic-compiler-verify` skill — expensive on-demand quality audit
- **First Tier 2 run:** Execute the benchmark suite against current compiled outputs to establish baseline
- **Threshold tuning:** Adjust from 95% → 90% if initial runs show excessive FLAKY results

---

*Phase 4 Step 6 complete. Tier 2 functional equivalence validation is specified, documented, and integrated into the compilation pipeline.*
