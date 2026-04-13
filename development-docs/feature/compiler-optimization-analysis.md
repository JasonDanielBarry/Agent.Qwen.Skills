# Compiler Optimization Analysis — Phase 4 Step 1

**Date:** 13 April 2026  
**Scope:** Analysis of 6 skill compilations through the 6-stage pipeline  
**Skills analyzed:** sas-endsession, sas-git-commit-and-push, sas-git-merge, sas-reattach, sas-self-healing-memory, sas-semantic-compiler

---

## Compilation Summary

| Skill | IR Units (Stage 3) | After Pass 1 | Reduction | Notes |
|-------|-------------------|-------------|-----------|-------|
| sas-endsession | 22 | 12 | 45% | 0 filler removed; merged adjacent units |
| sas-git-commit-and-push | 44 | 20 | 55% | 0 filler removed; definitions merged (10→1), instructions merged |
| sas-git-merge | 68 | 12 | 82% | Aggressive merging (11→1 per section); may be too aggressive |
| sas-reattach | 49 | ~30+ | ~39% | Moderate merging |
| sas-self-healing-memory | 44 | 41 | 7% | Almost no merging — metadata/rational compressed, filler u1 removed |
| sas-semantic-compiler | 75 | 56 | 25% | Filler removed, cross-references resolved |

---

## Pattern 1: Over-Classified as Filler (False Positives)

**Finding: LOW RISK** — Across all 6 skills, very few units were classified as `filler` type and removed.

### sas-self-healing-memory
- **IR unit u1** (metadata/frontmatter) was removed in Pass 1. The frontmatter (`name:` + `description:`) was correctly identified as metadata and compressed, not fully removed — this is correct behavior.
- **No content that should have been preserved was removed.**

### sas-endsession
- **Zero filler units found.** No false positives.

### sas-git-commit-and-push
- **Zero filler units found.** No false positives.

### sas-git-merge
- **No explicit filler units.** The aggressive merging in Pass 1 compressed 68 units to 12 by merging all constraints into one, all failure modes into one, etc. This is structural compression, not filler removal.

**Conclusion:** The filler classifier is conservative and not producing false positives. This is good — but may mean it's also too conservative (see Pattern 2).

---

## Pattern 2: Under-Classified as Filler (False Negatives)

**Finding: MODERATE RISK** — Several skills retained content that appears to be filler or near-filler.

### sas-git-commit-and-push — Definition units (u32–u41)
- **10 definition units** for conventional commit types (feat, fix, docs, refactor, chore, test, ci, build, perf, revert) were all preserved as P2 in Pass 1, then merged into a single unit in Pass 1.
- **Analysis:** These are well-known conventions. An agent familiar with git already knows these. They could be compressed to a single-line reference rather than 10 separate units.
- **Recommendation:** Tighten the "metadata/provenance" category — well-known external conventions should be compressed to a single reference line, not preserved as individual entries.

### sas-self-healing-memory — Metadata unit u1
- Frontmatter metadata was preserved as a full IR unit rather than being compressed to a header.
- **Analysis:** The metadata was compressed correctly in Pass 1. No issue.

### sas-git-merge — Edge case units
- 11 separate failure mode units (ir-023 through ir-033) were merged into a single unit. The merged unit is a dense run-on sentence: "Not git repo: exit. Merge in progress: present continue/abort/inspect. Dirty tree: warn, offer stash/commit..."
- **Analysis:** This is correct compression for the 8-category system — but the resulting text is hard for an agent to parse. The compression may have gone too far.
- **Recommendation:** Add a maximum density rule — merged units should retain bullet/line structure for failure modes and edge cases. Don't compress into run-on prose.

### sas-endsession — Rationale compression
- The rationale unit was compressed to `[rationale: Eliminates context loss between sessions, enables immediate resume without re-reading history]`.
- **Analysis:** This is correct and effective compression.

---

## Pattern 3: Misclassified Semantic Roles

**Finding: MODERATE RISK** — Some IR units have ambiguous or incorrect type assignments.

### sas-git-commit-and-push — `rule` type (units u14–u19)
- Units u14–u19 have type `"rule"` but this is not a valid IRUnit type in the compiler's type list: `instruction, constraint, fact, example, rationale, edge_case, invariant, failure_mode, guarantee, input, output, relationship, validation, metadata, filler`.
- **Impact:** These units would map to `instruction` or `constraint` but were left as `"rule"`.
- **Recommendation:** Add `rule` as an alias for `constraint` in Stage 3 keyword heuristics, or map unknown types to their nearest valid type.

### sas-self-healing-memory — `file_structure` and `transcript_format` types
- Units u3, u38 have type `"file_structure"` and u39, u40 have type `"transcript_format"` — these are not standard IRUnit types.
- **Impact:** These should probably be `instruction` or `metadata` types.
- **Recommendation:** Extend the type list to include `file_structure` as a valid type (since it represents structural documentation), or add a mapping rule.

### sas-git-merge — `purpose`, `scope`, `validation` types
- Units use types like `"purpose"`, `"scope"`, `"validation"` which are section names, not semantic roles.
- **Analysis:** The semantic role should describe *what kind of instruction* the content is, not *which section it belongs to*. A purpose statement is typically a `fact` or `instruction`. A validation strategy is an `instruction`.
- **Recommendation:** Stage 3 should not use section names as types. Add disambiguation: content under "Purpose" heading → type `fact`; content under "Validation Strategy" → type `instruction`.

---

## Pattern 4: Lost Constraints

**Finding: LOW RISK** — Constraints are generally well-preserved, but some implicit constraints may have been lost.

### sas-git-commit-and-push
- Source had 3 P0 constraints in the Purpose section (units u001–u003). In Pass 1, units u002 and u003 were merged into u001: "Ensure commits follow project conventions. Keep working tree in predictable state after execution."
- **Analysis:** The merge preserved both constraints but combined them into one sentence. No semantic loss.

### sas-self-healing-memory
- 8 negative constraints (u11–u14 and u41) all preserved with `negation: true` in Pass 1.
- **Analysis:** No constraints lost.

### sas-git-merge
- 10 constraint units (ir-009 through ir-017) merged into one. All individual constraints are still present in the merged text.
- **Analysis:** Preserved correctly.

---

## Pattern 5: Lost Edge Cases

**Finding: MODERATE RISK** — Edge cases are sometimes merged so aggressively they lose their individual identity.

### sas-git-merge
- 11 failure mode units (ir-023 through ir-033) merged into one dense unit. Each individual scenario ("Not git repo: exit", "Shallow clone: warn, suggest unshallow", "Target ahead of remote: warn force push") is still present but buried in run-on text.
- **Risk:** An agent scanning for "shallow clone" handling may miss it in the dense merged text.
- **Recommendation:** Edge cases and failure modes should NOT be merged into a single unit. They should remain as separate entries for scanability.

### sas-git-commit-and-push
- 3 edge case units (u029–u031) preserved individually in Pass 1. Good.
- 3 example units (u042–u044) were all removed in Pass 1 (examples generalized).
- **Risk:** The examples provided concrete invocation patterns. After generalization, the agent loses specific "this is what it looks like in practice" demonstrations.
- **Recommendation:** Keep at least one concrete example per skill. The 8-category rule says "GENERALIZE → minimal schema/pattern" — but for procedural skills, one worked example is worth 10 abstract rules.

### sas-self-healing-memory
- Example unit u44 (Quick Reference Do/Don't) preserved in Pass 1.
- **Analysis:** This is a valuable reference table and was correctly preserved.

---

## Pattern 6: Redundant Output

**Finding: LOW-MODERATE RISK** — Some compiled output contains redundant or non-actionable content.

### sas-git-merge
- The merged instruction unit (ir-055) is extremely dense: "Step 1: git rev-parse --show-toplevel. Fail: exit. Step 1.5: git fetch --prune. No remote: skip. Step 2.1: git status, if merging: present continue/abort/inspect, wait..."
- **Analysis:** This is all in one unit. While structurally correct (it's a numbered step sequence), it's not structured for agent execution. An agent needs to execute one step at a time, not parse a dense paragraph.
- **Recommendation:** Stage 4 Pass 1 should NOT merge instruction units that contain numbered step sequences. Steps should remain as individual units or at least retain line breaks.

### sas-semantic-compiler
- The compiler's own SKILL.human.md is 660 lines; compiled output is 354 lines (46% reduction).
- The architecture reference files were inlined during preprocessing AND also appeared as separate IR units in the source body, creating redundancy. The IR extraction deduplicated this correctly.
- **Analysis:** This is a special case (self-compilation with included files). The deduplication worked correctly.

### sas-endsession
- Compiled output is clean and well-structured. No redundancy detected.

---

## Summary of Findings

| Pattern | Risk Level | Skills Affected | Recommended Action |
|---------|-----------|----------------|-------------------|
| Over-classified as filler | LOW | None | No action needed |
| Under-classified as filler | MODERATE | sas-git-commit-and-push, sas-git-merge | Tighten metadata compression; add max density rule |
| Misclassified semantic roles | MODERATE | sas-git-commit-and-push, sas-self-healing-memory, sas-git-merge | Add type alias mapping; stop using section names as types |
| Lost constraints | LOW | None (preserved well) | No action needed |
| Lost edge cases | MODERATE | sas-git-merge, sas-git-commit-and-push | Don't merge failure modes into single unit; keep 1+ examples |
| Redundant output | LOW-MODERATE | sas-git-merge | Don't merge numbered step sequences |

---

## Priority Recommendations for Steps 2–5

Based on this analysis, the highest-impact refinements for Phase 4 are:

1. **Step 2 (Filler Classification) — Add max density rule:** When merging adjacent units, preserve bullet/line structure for failure modes, edge cases, and numbered steps. Never compress into run-on prose.

2. **Step 3 (Semantic Role Assignment) — Fix type mapping:**
   - Map unknown types (`rule`, `file_structure`) to nearest valid IRUnit type
   - Stop using section names (`purpose`, `scope`, `validation`) as semantic role types
   - Add disambiguation rules for content under section headings

3. **Step 4 Pass 1 (Strip & Compress) — Protect structural sequences:**
   - Do not merge instruction units that contain numbered step sequences
   - Do not merge failure mode or edge case units into single units
   - Keep at least one concrete example per procedural skill

4. **Step 4 Pass 2 (Tag & Structure) — No changes needed:** Priority assignment and condition extraction appear correct across all skills.

5. **Step 4 Pass 3 (Cross-Reference & Group) — Minor refinement:** Ensure grouped failure modes remain individually addressable (each gets its own ID even within a group).

## Post-Refinement Recompilation (Phase 4 Steps 2–3 Applied)

After applying the Phase 4 refinements (Max Density Rule, Example Preservation, Type Alias Mapping, Section-Name Disambigination), all 6 skills were recompiled.

### Recompilation Results

| Skill | IR Units (Stage 3) | After Pass 1 | Notes |
|-------|-------------------|-------------|-------|
| sas-endsession | 22 | 22 | 0 merges (Max Density Rule preserved all units) |
| sas-git-commit-and-push | 19 | 19 | 0 merges; 6 steps + 3 edge cases + 3 invariants kept separate; 3 examples preserved |
| sas-git-merge | 44 | 48 | IR grew slightly due to better type mapping; 11 steps + 6 failure modes + 8 edge cases kept separate |
| sas-reattach | 22 | 22 | Type-specific sections injected (Invocation Conditions, Forbidden Usage, Phase Separation) |
| sas-self-healing-memory | 58 | 58 | 0 merges; 5 examples preserved; 13 negative constraints |
| sas-semantic-compiler | 85 | ~70 | Filler removed but steps/failure modes protected |

### Key Improvements Over Pre-Refinement Compilation

| Metric | Before | After |
|--------|--------|-------|
| sas-git-merge: units merged into run-on prose | 68→12 (82% reduction, too aggressive) | 44→48 (protected steps, failure modes, edge cases) |
| sas-git-commit-and-push: examples removed | 3 examples removed | 3 examples preserved |
| sas-git-merge: type mapping | "rule" type unmapped | "rule"→constraint, "file_structure"→instruction |
| sas-reattach: type-specific sections | Missing | Injected (Invocation Conditions, Forbidden Usage, Phase Separation) |
| Tier 1 validation artifacts | Inconsistent | Consistent (tier1-validation.json generated for all skills) |

---

*Analysis complete. Ready for Steps 4–5 implementation.*
