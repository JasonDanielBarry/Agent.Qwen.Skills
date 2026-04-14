<!-- compiled from: skills/sas-semantic-compiler-verify/SKILL.human.md | 2026-04-14T09:30:00Z -->

---
name: sas-semantic-compiler-verify
description: Perform an expensive, on-demand quality audit of a compiled skill. Runs deep analysis: full content coverage audit, constraint sufficiency check, conflict detection, edge case coverage, instruction fidelity, and semantic drift. Not part of the normal compilation pipeline — invoked manually for quality audits.
---

## Purpose

<purpose>
[P0] Perform deep quality audit of compiled skill: verify no essential information was lost, no constraints conflict, no semantic drift occurred during compilation.
[P1] Runs on-demand when: user suspects compilation produced degraded output; before major compiler changes are merged; periodic quality gate for compiler pipeline; Phase 4 optimization validation.
[P0] NOT a replacement for Tier 1 or Tier 2 — these are automatic. This skill is the expensive, thorough, human-readable audit that goes beyond structural checks and functional equivalence.
[rationale: Tier 1 checks structure, Tier 2 checks functional equivalence — this skill checks semantic integrity, constraint quality, and compilation correctness at a depth neither automated tier can reach]
</purpose>

## Scope

<scope>
- Target: Single compiled skill (SKILL.human.md + SKILL.md pair). Audits 6 dimensions: content coverage, constraint sufficiency, conflict detection, edge case coverage, instruction fidelity, semantic drift.
- Excluded: Multiple skills at once (audit one skill per invocation). Not a replacement for automated Tier 1/Tier 2 validation. Not a functional test — does not execute the skill against benchmark tasks.
</scope>

## Inputs

<inputs>
- Source document: SKILL.human.md (human-editable source).
- Compiled document: SKILL.md (pipeline output).
- Optional: Tier 1 validation results (tier1-validation.json).
- Optional: Tier 2 benchmark results (tier2-result-*.json).
</inputs>

## Outputs

<outputs>
[P0] Verification report file at `.verification/verify-<skill-name>-YYYYMMDD-HHmmss.md` containing: YAML frontmatter (skill_name, source_path, compiled_path, verify_date), 6 audit pass results (content coverage, constraint sufficiency, conflict detection, edge case coverage, instruction fidelity, semantic drift), each pass: PASS/FAIL/WARNING with detailed findings, overall verdict: PASS (all 6 passes pass), FAIL (any pass fails), WARNING (all pass but with warnings), specific remediation recommendations for any failures.
</outputs>

## Constraints

<constraints>
[P0] Must NOT modify source or compiled documents — read-only audit.
[P0] Must NOT run the compilation pipeline — this is a post-compilation audit only.
[P0] Each of the 6 audit passes must produce a binary PASS/FAIL result (with optional WARNING).
[P0] Must compare source against compiled — cannot audit compiled document in isolation.
[P1] If Tier 2 results are available, incorporate them into the overall verdict (Tier 2 failures → overall FAIL).
[P0] Write the verification report directly without asking for user confirmation.
</constraints>

## Invariants

<invariants>
[P0] All 6 audit passes always execute — no early exit even if an early pass fails.
[P0] Verification report always includes an overall verdict (PASS/FAIL/WARNING).
[P0] Source and compiled documents are never modified.
</invariants>

## Failure Modes

<failure_modes>
[P0] IF source document not found → report FAIL, cannot continue.
[P0] IF compiled document not found → report FAIL, cannot continue.
[P0] IF source and compiled have different section structures (missing sections) → report as structural mismatch in content coverage pass.
[P0] IF audit pass produces inconclusive results (cannot determine pass/fail) → report as WARNING with explanation.
[P1] IF .verification/ directory does not exist → create it.
</failure_modes>

## Validation Strategy

<validation_strategy>
- Verify output file exists at `.verification/` with correct naming pattern (verify-<skill-name>-YYYYMMDD-HHmmss.md).
- Verify all 6 audit passes present in report.
- Verify overall verdict is present and is one of: PASS, FAIL, WARNING.
- Verify each audit pass has a binary PASS/FAIL result.
</validation_strategy>

## Relationships

<relationships>
- Depends on: sas-semantic-compiler (produces the compiled skills this skill audits).
- Complements: Tier 1 validation (structural check), Tier 2 validation (functional equivalence).
- Produces: verification reports consumed by developers to assess compiler quality.
- May reference: architecture/09-validation.md for audit criteria definitions.
</relationships>

## Guarantees

<guarantees>
[P0] All 6 audit passes always executed and reported.
[P0] Verification report is always written (even if audit cannot complete — report explains why).
[P0] Source and compiled documents are never modified by this skill.
</guarantees>

## Invocation Conditions

<invocation_conditions>
- Invoke when: user suspects compilation produced degraded output; before major compiler changes are merged; periodic quality gate; Phase 4 optimization validation.
- After writing report, show user the file path and overall verdict summary.
- Must be invoked with both source (SKILL.human.md) and compiled (SKILL.md) documents available.
</invocation_conditions>

## Forbidden Usage

<forbidden_usage>
[P0] Must NOT modify source or compiled documents.
[P0] Must NOT run the compilation pipeline.
[P0] Must NOT audit compiled document in isolation (without source for comparison).
[P0] Must NOT skip any of the 6 audit passes.
[P0] Must NOT ask user for confirmation before writing the report.
</forbidden_usage>

## Phase Separation

<phase_separation>
Procedural execution sequence:
1. Validate inputs: verify SKILL.human.md and SKILL.md both exist at the specified skill path.
2. Create `.verification/` directory if it does not exist.
3. Execute 6 audit passes (described below). Each pass runs independently.
4. Aggregate results: compute overall verdict.
5. Write verification report.
6. Show user file path and verdict summary.

### Audit Pass 1: Content Coverage

Compare source SKILL.human.md against compiled SKILL.md. For every semantic unit (instruction, constraint, fact, example, rationale, edge case, invariant, failure mode, guarantee) in the source, verify it has a corresponding unit in the compiled output.

**Pass criteria:**
- Every P0 constraint from source present in compiled (exact or semantically equivalent)
- Every instruction from source present in compiled (may be compressed but not lost)
- Every failure mode from source present in compiled
- Every invariant from source present in compiled
- Every edge case from source present in compiled
- No essential content silently removed (metadata compression is acceptable)

**FAIL if:** any P0 constraint, instruction, failure mode, invariant, or edge case is missing from compiled.
**WARNING if:** content is present but significantly harder to parse (e.g., merged into dense prose without line structure).

### Audit Pass 2: Constraint Sufficiency

Evaluate whether the compiled skill's constraints satisfy the Constraint Sufficiency Test from the Semantic Constraint Framework:

1. **Path Coverage:** Does the skill handle all expected execution paths? (happy path, edge cases, error paths)
2. **Failure Coverage:** Are failure modes explicitly declared with recovery/exit strategies?
3. **Input Coverage:** Are all expected input variations handled?

**Pass criteria:**
- At least one constraint per execution path (happy, edge, error)
- Failure modes have explicit recovery strategies
- Input variations are covered by constraints or failure modes

**FAIL if:** any execution path has no constraint coverage, or failure modes lack recovery strategies.
**WARNING if:** coverage is present but sparse (e.g., only happy path has detailed constraints).

### Audit Pass 3: Conflict Detection

Scan the compiled skill for internal contradictions:

1. Check for constraints that conflict with each other (e.g., "always do X" vs "never do X")
2. Check for invariants that contradict failure modes
3. Check for instructions that violate forbidden usage rules
4. Check for priority conflicts (P0 vs P0 contradictions)

**Pass criteria:**
- No P0 vs P0 contradictions found
- No instruction contradicts a forbidden usage rule
- No invariant conflicts with a failure mode recovery strategy

**FAIL if:** any P0 vs P0 contradiction found.
**WARNING if:** non-P0 conflicts found (P1 vs P1, P2 vs P2).

### Audit Pass 4: Edge Case Coverage

Verify that the compiled skill adequately covers edge cases relevant to its domain:

1. Check that edge cases are individually addressable (not buried in dense merged text)
2. Check that each edge case has a clear trigger condition and response
3. Check that edge case priority markers are correct

**Pass criteria:**
- Edge cases are individually scanable (not merged into run-on prose)
- Each edge case has: trigger condition → agent response
- Priority markers ([P0], [P1], [P2]) are appropriate

**FAIL if:** edge cases are merged into unreadable dense text.
**WARNING if:** edge cases are present but lack clear trigger/response structure.

### Audit Pass 5: Instruction Fidelity

Verify that the compiled skill's instructions preserve the procedural intent of the source:

1. For procedural skills: numbered step sequences must be preserved in execution order
2. For declarative skills: fact assertions must be semantically equivalent
3. Examples must be preserved for skills that included them in source

**Pass criteria:**
- Procedural skills: step order preserved, no steps skipped, no steps reordered
- Declarative skills: all facts present and semantically equivalent
- Skills with examples in source: at least one example present in compiled

**FAIL if:** procedural step order changed, or examples removed from procedural skills.
**WARNING if:** instructions are present but reworded in a way that could change interpretation.

### Audit Pass 6: Semantic Drift

Compare the compiled skill against the source for subtle meaning changes:

1. Check that constraint scope hasn't expanded or contracted (e.g., "always do X in situation Y" became "always do X")
2. Check that failure mode triggers haven't been broadened or narrowed
3. Check that invariant guarantees haven't been weakened
4. Check that forbidden usage rules haven't been relaxed

**Pass criteria:**
- Constraint scopes match (no expansion/contraction)
- Failure mode triggers match (no broadening/narrowing)
- Invariant guarantees match (no weakening)
- Forbidden usage rules match (no relaxation)

**FAIL if:** any P0 constraint scope changed, or any P0 forbidden usage rule relaxed.
**WARNING if:** non-P0 constraint scope changed slightly, or instructions reworded in ways that could affect edge cases.

</phase_separation>
