# Implementation Plan: `sas-semantic-compiler` — Phase 3 (v2.0 — Self-Compilation)

## Goal

Use the v1.0 compiler to compile its own `SKILL.human.md` into `SKILL.md`, validating that the output conforms to the Semantic Constraint Framework. This is the bootstrap test — if the compiler can produce a valid, usable version of itself, it proves the pipeline works end-to-end.

---

## What Changes from Phase 2

| Area | Phase 2 | Phase 3 |
|------|---------|---------|
| Source file | `SKILL.human.md` already exists (written in Phase 1) | Used as compilation input — no rewrite needed |
| Compilation target | Other skills in the repo | The compiler's own skill |
| Validation | Tier 1 structural check (same as Phase 2) | Tier 1 + Semantic Constraint Framework conformance audit |
| Transformation rules | As defined in Phase 2 | Refined based on self-compilation results |
| Output | `SKILL.md` (hand-crafted in Phase 1) | `SKILL.md` (compiler-generated, replacing hand-crafted version) |

---

## Key Insight

The `SKILL.human.md` already exists — it was written during Phase 1 and describes the full 6-stage pipeline, all transformation rules, error codes, file structure, bootstrap strategy, and operational concerns. Phase 3 does **not** rewrite the source. It uses the Phase 2 compiler to produce a new `SKILL.md` from that source, then validates the result.

This is the C++ compiler compiling itself — the ultimate stress test.

---

## Steps

### Step 1: Verify `SKILL.human.md` Is Compilation-Ready

Review the existing `SKILL.human.md` for Phase 1-era content that may need updating before compilation:

- Confirm it accurately describes the full Phase 2 pipeline (all 3 Stage 4 passes, XML tags, Tier 1 validation)
- If not, update `SKILL.human.md` to reflect the Phase 2 state (the source is human-edited — it should match reality before compilation)
- This is a source-level edit, not a compilation step

### Step 2: Back Up Current `SKILL.md`

- Copy the current hand-crafted `SKILL.md` to `SKILL.md.phase1-backup` for comparison
- This preserves the Phase 1 artifact for diff analysis

### Step 3: Compile `SKILL.human.md` → `SKILL.md`

Run the full 6-stage pipeline on the compiler's own source:

1. **Stage 1 — Preprocessor:** Process `SKILL.human.md`, detect references to `architecture/*.md` files, inline with boundaries if applicable, classify filler, detect conflicts
2. **Stage 2 — Structural Parse:** Build DST from preprocessed source
3. **Stage 3 — Semantic IR Extraction:** Flatten DST into semantic units
4. **Stage 4 Pass 1 — Strip & Compress:** Remove filler, compress rationale/metadata
5. **Stage 4 Pass 2 — Tag & Structure:** Assign IDs, priorities, Conditions, negation markers
6. **Stage 4 Pass 3 — Cross-Reference & Group:** Resolve references, group by semantic affinity, deduplicate
7. **Stage 5 — Semantic Constraint Injection:** Ensure all 10 universal sections, add type-specific sections (Skill detection → Invocation Conditions, Forbidden Usage, Phase Separation), convert to declarative language, KERNEL validation
8. **Stage 6 — Code Generation:** Emit markdown with XML-like tags, traceability header

### Step 4: Tier 1 Structural Validation

Run the Tier 1 structural check on the newly compiled `SKILL.md`:

- [ ] All 10 universal sections present with XML-like tags
- [ ] Type-specific sections present (Invocation Conditions, Forbidden Usage, Phase Separation — it's a Skill)
- [ ] No hedging language ("try to", "ideally", "if possible", "approximately")
- [ ] Negative constraints exist
- [ ] Uncertainty explicitly declared (not left implicit)
- [ ] KERNEL framework compliance:
  - [ ] **K** — Keep it simple: single, unambiguous primary goal
  - [ ] **E** — Easy to verify: pre-defined success metrics
  - [ ] **R** — Reproducible results: identical inputs → equivalent outputs
  - [ ] **N** — Narrow scope: explicit domain and task limits
  - [ ] **E** — Explicit constraints: hard boundaries on data, tools, capabilities
  - [ ] **L** — Logical structure: strict structural/styling boundaries

### Step 5: Semantic Constraint Framework Conformance Audit

Beyond Tier 1, validate against the full Semantic Constraint Framework:

- **Purpose:** Clear, single-sentence statement of why this artifact exists
- **Scope:** Explicitly states what it covers and excludes
- **Inputs:** All sources, formats, preconditions enumerated
- **Outputs:** All artifacts/state changes enumerated
- **Constraints:** Hard boundaries on behavior, data, side effects — all explicit
- **Invariants:** Conditions holding across all execution paths — all stated
- **Failure Modes:** Error handling for missing info, edge cases, errors — all covered
- **Validation Strategy:** How correctness is verified — described
- **Relationships:** Dependencies, ordering, boundaries — stated
- **Guarantees:** Postconditions committed to — stated

Additionally:
- Negative constraints explicitly block unwanted behavior
- KERNEL principles satisfied (see Step 4)
- No probabilistic weasel words — all directives are definitive

### Step 6: Compare with Phase 1 Backup

Diff the compiler-generated `SKILL.md` against `SKILL.md.phase1-backup`:

| Metric | Method |
|--------|--------|
| Content coverage | Does the compiled version cover all concepts from the hand-crafted version? |
| Constraint sufficiency | Are there constraints in the hand-crafted version that the compiler missed? |
| Structural fidelity | Does the compiled version have the same section order, hierarchy, and emphasis? |
| Token efficiency | Is the compiled version more or less concise than the hand-crafted version? |
| Usability | Would an agent using the compiled version behave equivalently to one using the hand-crafted version? |

Document findings. Gaps indicate where Stage 4 transformation rules need refinement.

### Step 7: Iterate — Refine Stage 4 Transformation Rules

Based on Steps 4-6 findings:

- If Tier 1 validation fails → fix the failing transformation rule in `SKILL.human.md` Stage 4 spec
- If Semantic Constraint Framework audit fails → identify which Stage 5 injection rule missed the requirement
- If comparison reveals gaps → refine filler classification or semantic role assignment heuristics
- Recompile after each fix
- Repeat until compiled output passes all checks

### Step 8: Replace `SKILL.md` with Compiler-Generated Version

Once all validations pass:
- Remove `SKILL.md.phase1-backup` (or keep as historical artifact)
- The compiler-generated `SKILL.md` becomes the official skill
- Commit both `SKILL.human.md` (source) and `SKILL.md` (compiled output) together

### Step 9: Test — Compile Other Skills with Updated Compiler

After self-compilation succeeds, recompile the other skills from Phase 2 to verify the refined transformation rules didn't break anything:

- `sas-endsession`
- `sas-reattach`
- `sas-git-commit-and-push`
- `sas-git-merge`
- `sas-self-healing-memory`

All should still pass Tier 1 validation.

---

## Success Criteria

- [ ] `SKILL.md` is fully compiler-generated (no hand-crafted content)
- [ ] Tier 1 structural validation passes
- [ ] Semantic Constraint Framework conformance audit passes
- [ ] All other skills still compile and pass Tier 1 validation
- [ ] Comparison with Phase 1 backup shows no regressions in content coverage

---

## Deferred to Phase 4

| Feature | Reason |
|---------|--------|
| Tier 2 functional equivalence validation | Requires benchmark task suite — test the compiler's compiled skill against its human-written skill on representative compilation tasks |
| Refined filler classification | Requires analysis of real-world compilation results across many documents |
| Separate expensive verification skill | Quality audit tool — defer to Phase 4 |

---

*Created: 13 April 2026*
