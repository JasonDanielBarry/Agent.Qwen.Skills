# 10 — Bootstrap Strategy

## Reconciled Approach

"Aggressive from the start" refers to the architecture and ambition — the full 6-stage pipeline, all validation, all constraint injection. "Bootstrap" refers to the transformation aggressiveness within Stage 4, which ramps up through self-compilation. The pipeline is fully built (aggressive), but the transformation rules mature through iteration (bootstrap).

---

## Phase 1 — Minimum Viable Compiler (v0.1)

- Implement Stages 1-3 (Preprocessor, DST, IR Extraction) with conservative transformation rules
- Stage 4: Only Pass 1 (strip filler per classification rules) — no tagging, no cross-referencing
- Stage 5: Basic section detection + placeholder injection for missing sections
- Stage 6: Simple markdown output (no XML tags yet)
- Test: Compile a simple Skill (e.g., `sas-endsession`) and verify output is usable

---

## Phase 2 — Full Pipeline (v1.0)

- Add Stage 4 Pass 2 (tagging, priority markers, IF/THEN/ELSE)
- Add Stage 4 Pass 3 (cross-reference resolution, grouping)
- Add XML-like tag wrapping in Stage 6
- Add Tier 1 structural validation
- Test: Compile all existing Skills, verify Tier 1 passes

---

## Phase 3 — Self-Compilation (v2.0)

- Write `SKILL.human.md` for `sas-semantic-compiler` itself
- Use v1.0 compiler to produce `SKILL.md`
- Validate output against Semantic Constraint Framework
- Iterate: refine Stage 4 transformation rules based on self-compilation results

---

## Phase 4 — Aggressive Optimization (v3.0+)

- Add Tier 2 functional equivalence validation
- Refine filler classification rules based on real-world results
- Add the separate expensive verification skill
- Push transformation aggressiveness to the limit

---

**Key principle:** Each phase produces a working, usable compiler. The pipeline architecture never changes — only the transformation rules within Stage 4 and the validation rigor increase.

---

*Last updated: 13 April 2026*
