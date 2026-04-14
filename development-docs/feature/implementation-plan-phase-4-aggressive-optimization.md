# Implementation Plan: `sas-semantic-compiler` — Phase 4 (v3.0+ — Aggressive Optimization)

## Goal

Add Tier 2 functional equivalence validation, refine filler classification based on real-world compilation results, and create the separate expensive verification skill. This phase pushes the compiler's transformation aggressiveness to the limit.

---

## What Changes from Phase 3

| Area | Phase 3 | Phase 4 |
|------|---------|---------|
| Validation | Tier 1 structural only | Tier 1 + Tier 2 functional equivalence |
| Filler classification | As defined in Phase 2 | Refined based on real-world results across many documents |
| Verification | None | Separate expensive verification skill for quality audits |
| Transformation aggressiveness | Conservative (preserves most content) | Pushed to the limit — maximal compression without semantic loss |

---

## Steps

### Step 1: Analyze Real-World Compilation Results

Before refining any rules, collect data from Phase 2 and Phase 3 compilations:

- Compile all 5 existing skills + the compiler's own `SKILL.human.md`
- For each compilation, inspect every stage's output in the `.DocName.compilation/` folder
- Identify patterns:
  - **Over-classified as filler:** Content removed that should have been preserved (false positives)
  - **Under-classified as filler:** Content preserved that should have been removed (false negatives)
  - **Misclassified semantic roles:** IRUnits assigned wrong types (e.g., `rationale` classified as `fact`)
  - **Lost constraints:** Constraints from source that didn't survive to compiled output
  - **Lost edge cases:** Edge conditions dropped during optimization passes
  - **Redundant output:** Content in compiled output that adds no instruction value

Document findings in a new file: `development-docs/feature/compiler-optimization-analysis.md`

### Step 2: Refine Filler Classification Rules

Update the 8-category filler classification in `SKILL.human.md` based on Step 1 analysis:

| Classification | Potential Refinements |
|---|---|
| **Verbose filler** | Tighten the definition — are polite phrases consistently caught? Are there false positives in technical prose that looks like filler? |
| **Redundant restatement** | Refine "no new constraint or detail" — are subtle restatements being incorrectly removed? |
| **Justification/provenance** | Is `[rationale: X]` compression always sufficient? Are there cases where the full rationale must be preserved? |
| **Hedging language** | Are all hedging patterns caught? ("might", "could", "should consider", "it may be beneficial to") |
| **Contextual reasoning** | Is the COMPRESS but PRESERVE rule producing the right balance? Too verbose? Too compressed? |
| **Examples** | Is "minimal schema/pattern + reference" sufficient for agent execution, or are concrete examples sometimes required? |
| **Instructions/constraints/rules** | Are all instructions being captured? Any missed implicit constraints? |
| **Metadata/provenance** | Is single-line header compression sufficient for version history that may be needed for traceability? |

### Step 3: Refine Semantic Role Assignment Heuristics

Update Stage 3 keyword heuristics based on Step 1 analysis:

- Add missing keyword patterns that weren't being classified correctly
- Refine structural context rules (e.g., "content under a 'Rules' heading should default to `constraint` type")
- Handle edge cases: content that matches multiple keywords, content that matches no keyword
- Add disambiguation rules for borderline classifications

### Step 4: Refine Stage 4 Pass 2 — Tag & Structure

Update Pass 2 transformation rules based on Step 1 analysis:

- **Priority assignment:** Are P0/P1/P2 assignments correct? Are critical constraints being downgraded? Are examples being over-prioritized?
- **Condition extraction:** Are all conditional statements being converted to `Condition` objects? Are false positives being created (non-conditional prose wrapped in Conditions)?
- **Negation detection:** Are all negative constraints being flagged? Any missed?
- **Example schema generalization:** Are generalized schemas useful for agent execution, or do they lose critical detail?

### Step 5: Refine Stage 4 Pass 3 — Cross-Reference & Group

Update Pass 3 transformation rules based on Step 1 analysis:

- **Reference resolution:** Are all cross-references being resolved? Are false links being created?
- **Semantic grouping:** Are grouped IRUnits genuinely semantically related? Are unrelated units being incorrectly grouped?
- **Deduplication:** Are deduplicated units truly identical, or is subtle information being lost?

### Step 6: Implement Tier 2 Functional Equivalence Validation

Tier 2 tests that the compiled skill produces equivalent agent behavior to the source skill.

#### 6a: Define Benchmark Task Suite

For each compiled skill, define 5+ representative tasks that exercise the skill's domain:

| Task Category | Example for `sas-endsession` |
|---|---|
| **Core function** | "Save a session handoff note for a refactoring session" |
| **Edge case** | "Save a session handoff note when nothing was accomplished" |
| **Constraint obedience** | "Try to save a session note without checking `.sessions/` directory" |
| **Error handling** | "Save a session note in a directory without `.git`" |
| **Complex scenario** | "Save a session handoff after implementing a multi-step feature with deferred items" |

Each task needs:
- **Input:** What the agent is told to do
- **Expected behavior:** What the agent should do (actions, outputs, constraint checks)
- **Equivalence criteria:** What "same" means for this task (same actions taken, same constraints obeyed, same output structure — not exact string match)

#### 6b: Define the Equivalence Test Procedure

```
For each benchmark task:
  1. Spawn Agent A with the SOURCE document (.human.md)
  2. Give Agent A the task
  3. Record Agent A's actions and output
  4. Spawn Agent B with the COMPILED document (.md)
  5. Give Agent B the identical task
  6. Record Agent B's actions and output
  7. Compare: do both agents exhibit semantically equivalent behavior?
     - Same actions taken?
     - Same constraints obeyed?
     - Same output structure?
     - Same errors caught (or not caught)?
  8. Score: pass or fail
```

#### 6c: Define the Pass Threshold

- **Threshold:** 90%+ task equivalence across all benchmark tasks
- **Meaning:** If 9 out of 10 tasks produce equivalent behavior, the compilation passes
- **Below threshold:** Compilation fails, user shown which tasks diverged and why

#### 6d: Integrate into Pipeline

- Tier 2 runs after Stage 6 completes and Tier 1 passes
- If Tier 2 fails → compilation fails, error message includes diverged tasks
- All intermediate files retained in `.DocName.compilation/` for diagnosis

### Step 7: Create the Separate Verification Skill

Build `sas-semantic-compiler-verify` — an expensive, on-demand quality audit skill.

**Purpose:** Deep analysis of compiled output for quality assurance — not part of the normal compilation pipeline, invoked manually when users want to audit compilation quality.

**What it checks:**

| Check | Description |
|-------|-------------|
| **Full content coverage audit** | Does every piece of essential information from the source appear in the compiled output? Not just structurally — semantically. |
| **Constraint sufficiency** | Are all constraints from the source preserved? Are there gaps where the source implied constraints that the compiler missed? |
| **Conflict detection** | Are there contradictory constraints in the compiled output that the compiler failed to flag? |
| **Edge case coverage** | Are all edge cases from the source present in the compiled output? |
| **Instruction fidelity** | Can every instruction from the source be executed from the compiled output without additional context? |
| **Semantic drift detection** | Has the meaning of any content shifted during compilation (not just format, but semantics)? |

**How it works:**

1. Spawn a dedicated sub-agent with both the source `.human.md` and the compiled `.md`
2. Give it the verification checklist above
3. Agent produces a report: pass/fail for each check, with evidence
4. Report written to `.DocName.compilation/verification-report.md`
5. Agent terminates

**Invocation:** Manual only — `sas-semantic-compiler-verify <source-file>` — never automatic.

### Step 8: Push Transformation Aggressiveness

With Tier 2 validation and the verification skill in place, the compiler can safely become more aggressive:

- **Remove more filler:** If Tier 2 confirms that removing certain content doesn't change agent behavior, remove it
- **Compress more aggressively:** If `[rationale: X]` is sufficient, use it everywhere justification appears
- **Generalize more examples:** If generalized schemas work as well as concrete examples, prefer schemas
- **Flatten more explanations:** If direct assertions produce equivalent behavior to nested explanations, use assertions

**Rule:** Each increase in aggressiveness must be validated by Tier 2. If equivalence drops below 90%, dial back that specific transformation.

### Step 9: Test — Full Regression

After all refinements:

1. Recompile all 5 existing skills + the compiler's own skill
2. Run Tier 1 + Tier 2 on each
3. Run the verification skill on at least 2 compiled skills (spot check)
4. All must pass

---

## Success Criteria

- [ ] Filler classification refined based on real-world analysis (documented in `compiler-optimization-analysis.md`)
- [ ] Semantic role assignment heuristics refined
- [ ] Stage 4 Pass 2 and Pass 3 transformation rules refined
- [ ] Tier 2 functional equivalence validation implemented and integrated into pipeline
- [ ] Benchmark task suite defined for all compiled skills (5+ tasks each)
- [ ] 90%+ task equivalence achieved across all benchmark tasks
- [ ] Separate verification skill (`sas-semantic-compiler-verify`) created and functional
- [ ] Full regression passes — all skills compile and pass Tier 1 + Tier 2

---

## Future Work (Post-Phase 4)

| Feature | Description |
|---------|-------------|
| **Tier 3 — User feedback loop** | Collect real user reports on compiled skill quality, feed back into transformation rules |
| **Automated benchmark expansion** | Dynamically add new benchmark tasks based on how skills are actually used |
| **Multi-format output** | Support output targets beyond markdown (e.g., JSON for API consumers, YAML for configuration) |
| **Incremental compilation** | Detect which parts of source changed and only re-run affected stages |
| **Compiler plugin system** | Allow custom transformation rules per project or domain |

---

*Created: 13 April 2026*

