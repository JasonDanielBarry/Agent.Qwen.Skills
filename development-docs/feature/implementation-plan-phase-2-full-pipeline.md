# Implementation Plan: `sas-semantic-compiler` — Phase 2 (v1.0 — Full Pipeline)

## Goal

Complete the 6-stage pipeline by adding the deferred Stage 4 passes (Pass 2: Tag & Structure, Pass 3: Cross-Reference & Group), XML-like tag wrapping in Stage 6, and Tier 1 structural validation.

---

## What Changes from Phase 1

| Area | Phase 1 | Phase 2 |
|------|---------|---------|
| Stage 4 Pass 1 | Strip & compress filler | Unchanged |
| Stage 4 Pass 2 | Skipped | Tag every IRUnit with IDs, priorities, Conditions, negation markers |
| Stage 4 Pass 3 | Skipped | Cross-reference resolution, semantic grouping, deduplication |
| Stage 5 | Basic section detection + placeholder injection | Full semantic constraint injection (now receives Pass 3 IR with resolved references) |
| Stage 6 | Simple markdown output | Markdown + XML-like section tags (`<purpose>`, `<constraints>`, etc.) |
| Validation | None | Tier 1 structural check (10 sections, declarative language, KERNEL, negative constraints) |
| Sub-agents | 4 invocations (Stages 1-3, Pass 1, Stage 5 basic, Stage 6 basic) | 8 invocations (full pipeline: 6 stages + 3 passes = 8 agents total) |

---

## Steps

### Step 1: Update `SKILL.human.md`

Update the human-readable source to reflect full pipeline capabilities:

- **Stage 4 Pass 2 spec:** Add full Tag & Structure rules:
  - ID assignment: `sec-{section}-{index}` for every IRUnit
  - Priority assignment: P0 (constraints, invariants, negative constraints), P1 (instructions, failure modes), P2 (examples, relationships)
  - Convert conditional prose into explicit `Condition` objects (`{predicate, then, else}`)
  - Mark negative constraints (`negation: true`)
  - Wrap examples in generalized schema patterns

- **Stage 4 Pass 3 spec:** Add full Cross-Reference & Group rules:
  - Resolve `references` by matching anchors/IDs to IRUnit IDs
  - Group related IRUnits by semantic affinity (constraints with edge cases, instructions with failure modes)
  - Add cross-reference links between sections
  - Deduplicate IRUnits with identical content in same section

- **Stage 6 spec:** Update to describe XML-like tag emission:
  - Every section wrapped in `<section_tag>...</section_tag>`
  - Tag names map to section names: Purpose → `<purpose>`, Constraints → `<constraints>`, etc.
  - Priority markers (`[P0]`) emitted for P0 units
  - IF/THEN/ELSE blocks emitted when `conditions` present

- **Validation section:** Add Tier 1 structural check specification:
  - Verify all 10 universal sections present with XML-like tags
  - Verify type-specific sections present
  - Verify declarative language (scan for "try to", "ideally", "if possible", "approximately")
  - Verify negative constraints exist
  - Verify uncertainty explicitly declared
  - Verify KERNEL framework compliance (K, E, R, N, E, L checklist)
  - Any failure → compilation fails with specific missing-element error

- **Sub-agent execution model:** Update table from 4 to 8 invocations

### Step 2: Update `SKILL.md` (compiled output)

Rewrite the compiled skill to reflect Phase 2 capabilities:

- Update Stage 4 section to describe all 3 passes
- Update Stage 6 section to describe XML-like tag wrapping
- Add Validation section with Tier 1 structural check
- Update Phase 1 limitations table to mark Phase 2 features as implemented
- Add new deferred features table for Phases 3-4

### Step 3: Update `ir-pass-2.json` and `ir-pass-3.json` schemas

Document the full schemas in the skill for Phase 2:

- **Pass 2 output (`ir-pass-2.json`):** IRUnits with explicit IDs, priority fields, `Condition` objects, `negation` flags
- **Pass 3 output (`ir-pass-3.json`):** IRUnits with resolved `references` array, grouped by semantic affinity, cross-reference links, deduplicated

### Step 4: Test — Compile all existing Skills

Compile every skill in the repo and verify Tier 1 passes:

| Skill | Complexity | Notes |
|-------|-----------|-------|
| `sas-endsession` | Low | Simple, 3 sections, short — already conceptually compiled in Phase 1 |
| `sas-reattach` | Low | Moderate logic, file handling, session matching |
| `sas-git-commit-and-push` | Medium | Git operations, conventional commits |
| `sas-git-merge` | Medium | Branch operations, conflict resolution |
| `sas-self-healing-memory` | High | Complex state management, conflict resolution |

For each compiled skill, run Tier 1 validation:
1. All 10 universal sections present with XML tags
2. Type-specific sections present (Invocation Conditions, Forbidden Usage, Phase Separation for Skills)
3. No hedging language ("try to", "ideally", "if possible")
4. Negative constraints present
5. Uncertainty explicitly declared
6. KERNEL framework compliance

### Step 5: Fix and Iterate

If any skill fails Tier 1 validation:
- Inspect the `.DocName.compilation/` folder for the failing stage
- Identify which transformation rule produced incorrect output
- Update `SKILL.human.md` Stage 4 transformation rules
- Recompile the failing skill
- Repeat until all skills pass

---

## Deferred to Phase 3

| Feature | Reason |
|---------|--------|
| Self-compilation | Requires v1.0 compiler to be stable first |
| Tier 2 functional equivalence | Requires benchmark task suite definition |
| Separate verification skill | Expensive — defer to Phase 4 |

## Deferred to Phase 4

| Feature | Reason |
|---------|--------|
| Tier 2 functional equivalence validation | Requires benchmark suite + separate agent invocations |
| Refined filler classification | Requires real-world compilation results to analyze |
| Separate expensive verification skill | Lowest priority — quality audit tool, not pipeline-critical |

---

*Created: 13 April 2026*
