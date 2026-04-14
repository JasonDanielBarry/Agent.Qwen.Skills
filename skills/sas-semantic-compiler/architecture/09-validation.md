# 09 — Validation

## Post-Compile Validation

Agent-based verification ensures compiled output preserves all essential information from source. Runs after Stage 6 completes.

**Two-tier validation:**

### Tier 1 — Cheap Structural Check (runs automatically, fast, deterministic)

- Verify all 10 universal sections present with XML-like tags
- Verify all type-specific sections present (based on document type)
- Verify declarative language used (no "try to", "ideally", "if possible")
- Verify negative constraints exist
- Verify uncertainty explicitly declared (not left implicit)
- Verify KERNEL framework compliance
- Fail = compilation fails with specific missing-element errors

### Tier 2 — Functional Equivalence Test (runs automatically, agent-based, pass/fail)

Runs after Tier 1 passes. Validates that the compiled SKILL.md is functionally equivalent to the source SKILL.human.md by executing both through identical benchmark tasks and comparing agent behavior.

**Execution flow:**
1. Grader agent loads both documents (SKILL.human.md + SKILL.md)
2. For each benchmark task in `benchmarks/tier-2-benchmarks.md`:
   a. Spawn Source Agent → load SKILL.human.md → execute task → capture actions/output
   b. Spawn Compiled Agent → load SKILL.md → execute identical task → capture output
   c. Grade: compare both against rubric → PASS / FAIL per criterion
   d. Task passes if ALL criteria pass
3. Aggregate: compute pass rate across all tasks
4. Threshold check: ≥95% → Tier 2 PASS; <95% → Tier 2 FAIL

**Benchmark suite:** 25 tasks total (5 per skill × 5 skills). See `benchmarks/tier-2-benchmarks.md` for full definitions.

**Capability dimensions tested per skill:**
- **Happy Path** — normal invocation, correct execution under standard conditions
- **Edge Case** — unusual input state, proper boundary condition handling
- **Constraint Obedience** — P0 constraint enforcement, invariant preservation
- **Failure Mode** — error scenario, correct response when things go wrong
- **Multi-Step** — full procedural sequence, complete step-by-step execution in order

**Semantic equivalence** means: same actions taken, same constraints obeyed, same invariants preserved, same output structure — NOT identical text.

**Stochastic handling:** If a task fails on first run, re-run once to check for stochastic false negatives. Second-run pass → marked FLAKY (pass but flagged). Both runs fail → hard FAIL.

**Threshold:** 95%+ task equivalence across the benchmark suite (max 1 failure in 25-task suite). If threshold not met during early runs, may be dialed back to 90%.

**Fail =** compilation fails, user shown divergence report with: which tasks failed, which criteria failed per task, source vs compiled agent behavior side-by-side, root cause hypothesis.

**Result format:** JSON output written to `benchmarks/results/tier2-result-YYYYMMDD-HHmmss.json` with per-task status, per-criterion results, pass rate, and overall Tier 2 result. See benchmark document for full JSON schema.

### Separate Verification Skill (expensive, on-demand)

- ~~Dedicated skill for deep analysis~~ **DONE — Phase 4 Step 7 complete**
- Skill: `sas-semantic-compiler-verify`
- 6 audit passes: content coverage, constraint sufficiency, conflict detection, edge case coverage, instruction fidelity, semantic drift
- Not part of the normal compilation pipeline — invoked manually for quality audits
- Output: verification report at `.verification/verify-<skill-name>-YYYYMMDD-HHmmss.md` with per-pass PASS/FAIL/WARNING and overall verdict

---

## Success Metrics

- **Primary method:** Post-compile verification (pass/fail)
  - Verification fails → compile fails
  - Verification passes → compile passes
- User sees clear, understandable results
- If verification fails, user adjusts source and retries
- Requires testing against real agent tasks

---

## Format Consistency

- All compiled documents conform to standard optimal format
- Already-optimized documents recompiled for consistency
- Predictability prioritized over preserving existing optimization

**Analogy:** Optimized C++ doesn't run on CPU — assembly does. C++ is human-friendly way to write assembly. Compiled markdown is **"assembly code"** for AI agents, human-readable markdown is **"C++ code"** for humans.

---

## Error Handling

- No dry run/preview mode
- No diff reports
- Humans won't inspect compiled files (for AI agents only)
- **CRUCIAL:** Error reporting must be clear so users can identify and fix source issues
- Recompile at will

---

*Last updated: 13 April 2026*
