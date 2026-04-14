# sas-semantic-compiler-verify — Phase 4 Step 7

**Date:** 14 April 2026
**Status:** Implemented

---

## Overview

Phase 4 Step 7 creates the `sas-semantic-compiler-verify` skill — an expensive, on-demand quality audit for compiled skills. This skill goes beyond the automated Tier 1 (structural) and Tier 2 (functional equivalence) checks to perform a deep semantic analysis of compilation quality.

---

## What Was Delivered

### Skill: `sas-semantic-compiler-verify`

**Location:** `skills/sas-semantic-compiler-verify/`
**Files:** `SKILL.human.md` (source), `SKILL.md` (compiled)

### 6 Audit Passes

| Pass | Name | What it checks | FAIL condition |
|------|------|----------------|----------------|
| 1 | Content Coverage | Every semantic unit from source present in compiled | P0 constraint/instruction/failure mode/invariant/edge case missing |
| 2 | Constraint Sufficiency | Constraint Sufficiency Test from framework (path/failure/input coverage) | Execution path with no constraint coverage, failure modes without recovery |
| 3 | Conflict Detection | Internal contradictions (P0 vs P0, instruction vs forbidden usage) | P0 vs P0 contradiction |
| 4 | Edge Case Coverage | Edge cases individually addressable, clear trigger/response | Edge cases merged into unreadable dense text |
| 5 | Instruction Fidelity | Procedural intent preserved (step order, examples) | Step order changed/reordered, examples removed from procedural skills |
| 6 | Semantic Drift | Subtle meaning changes (constraint scope expansion/contraction, weakened guarantees) | P0 constraint scope changed, P0 forbidden usage relaxed |

### Verdict System

- **PASS** — all 6 audit passes pass
- **FAIL** — any audit pass fails
- **WARNING** — all passes pass but with warnings (e.g., content present but harder to parse)

### Integration with Tier 2

If Tier 2 results are available for the skill being audited, Tier 2 failures are incorporated into the overall verdict (Tier 2 failure → overall FAIL).

### Report Format

Verification report written to `.verification/verify-<skill-name>-YYYYMMDD-HHmmss.md`:
- YAML frontmatter (skill_name, source_path, compiled_path, verify_date)
- Per-audit-pass results with PASS/FAIL/WARNING and detailed findings
- Overall verdict
- Specific remediation recommendations for any failures

---

## Files Created/Modified

| File | Change |
|------|--------|
| `skills/sas-semantic-compiler-verify/SKILL.human.md` | **Created** — source document for the verify skill |
| `skills/sas-semantic-compiler-verify/SKILL.md` | **Created** — compiled output |
| `skills/sas-semantic-compiler/SKILL.human.md` | **Updated** — verification skill marked DONE, Phase 4 table updated |
| `skills/sas-semantic-compiler/SKILL.md` | **Updated** — verification skill marked DONE, phase_separation table updated |
| `skills/sas-semantic-compiler/architecture/09-validation.md` | **Updated** — verification skill section updated |
| `skills/sas-semantic-compiler/architecture/10-bootstrap-strategy.md` | **Updated** — Phase 4 Step 7 marked DONE |

---

## Design Decisions

### Why 6 audit passes?
Each pass tests a different dimension of compilation quality:
1. **Content Coverage** — did we lose anything? (the most basic check)
2. **Constraint Sufficiency** — are the constraints adequate? (framework-aligned)
3. **Conflict Detection** — did we introduce contradictions? (compilation can create new conflicts)
4. **Edge Case Coverage** — are edge cases still readable? (the Max Density Rule protects these, but verify checks it)
5. **Instruction Fidelity** — is the procedural intent preserved? (most important for procedural skills)
6. **Semantic Drift** — did subtle meaning change? (the hardest to catch, requires deep comparison)

### Why not automated?
This skill is expensive — it requires comparing every semantic unit between source and compiled, running 6 independent audit passes, and producing a detailed report. Tier 1 and Tier 2 handle automated validation. This skill is the "deep dive" for when automated checks aren't enough.

### Why PASS/FAIL/WARNING (not just pass/fail)?
Some audit dimensions produce results that are technically passing but concerning (e.g., content is present but merged into dense prose). WARNING captures this nuance without blocking compilation.

### Why read-only?
This skill audits — it never modifies. If it found issues, the fix is in the source document, then recompile. The verifier is an observer, not an editor.

---

## Relationship to Tier 1 and Tier 2

| Validation | Cost | When | What it checks |
|------------|------|------|----------------|
| Tier 1 | Cheap, automatic, deterministic | After every compilation | Structure (sections present, declarative language, negative constraints, KERNEL) |
| Tier 2 | Expensive, automatic, agent-based | After Tier 1 passes | Functional equivalence (same behavior from source vs compiled) |
| Verify skill | Expensive, manual, thorough | On-demand | Semantic integrity (content coverage, constraint quality, conflicts, drift) |

All three are complementary. Tier 1 catches structural breaks. Tier 2 catches behavioral changes. Verify catches subtle semantic degradation that neither automated tier can reach.

---

*Phase 4 Step 7 complete. The `sas-semantic-compiler-verify` skill is created, compiled, and integrated into the compiler's validation ecosystem.*
