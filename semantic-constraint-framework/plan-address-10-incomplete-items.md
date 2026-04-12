# Plan: Address 10 Incomplete Work Items

**Created:** 12 April 2026  
**Status:** Pending execution  
**Parent artifact:** [Semantic Constraint Framework.md](./Semantic%20Constraint%20Framework.md)

---

## Overview

The Semantic Constraint Framework contains 10 identified gaps ("Incomplete Work") that must be filled before the framework is considered complete. This plan defines the detailed subtasks for each item, the expected deliverables, and the order of execution.

All 10 items will be addressed by **appending new sections** to the existing `Semantic Constraint Framework.md` document — replacing the current "Incomplete Work" placeholder text with fully specified content.

---

## Execution Order

Items are ordered by dependency: earlier items produce foundations that later items build on.

| Order | Item | Dependencies |
|-------|------|-------------|
| 1 | Worked Examples | None (standalone) |
| 2 | Constraint Conflict Resolution Rules | None (standalone) |
| 3 | Artifact-to-Artifact Conflict Resolution | Item 2 |
| 4 | Versioning & Migration Strategy | None (standalone) |
| 5 | Verification Function (VF) Specification | None (standalone) |
| 6 | Constraint Sufficiency | Items 2, 5 |
| 7 | Artifact Granularity Guidelines | None (standalone) |
| 8 | Section Depth Guidance | None (standalone) |
| 9 | Validation Strategy Specification | Item 5 |
| 10 | Constraint Language Standardization | Items 2, 6, 8 |

---

## Detailed Subtasks

### 1. Worked Examples (Before/After Artifacts)

**Goal:** Provide concrete before/after transformations demonstrating the framework in practice.

**Subtasks:**
- 1a. Create `examples/` subfolder within `semantic-constraint-framework/`
- 1b. Write a **Plan** before/after example:
  - "Before": a typical human-written plan with vague goals, implied defaults, no constraints
  - "After": the same plan rewritten with all 10 universal sections, declarative constraints, KERNEL compliance
- 1c. Write a **Skill** before/after example:
  - "Before": a loose skill description with ambiguous invocation conditions
  - "After": a tight skill contract with invocation conditions, forbidden usage, phase separation, and all 10 universal sections
- 1d. Write a **Memory & Context Note** before/after example:
  - "Before": a verbose narrative session summary
  - "After": a concise, structured memory note with scope, retention policy, conflict resolution, freshness, and access patterns
- 1e. Add annotations to each "after" example explaining which framework rule drove each structural change

**Deliverable:** `examples/worked-examples.md` with 3 complete before/after pairs.

---

### 2. Constraint Conflict Resolution Rules

**Goal:** Define how to detect and resolve conflicts when two constraints within the same artifact contradict.

**Subtasks:**
- 2a. Define a **constraint priority model** with three tiers:
  - **Tier 1 — Invariants:** Non-negotiable, block execution if violated
  - **Tier 2 — Constraints:** Hard rules that must be satisfied; violation triggers retry
  - **Tier 3 — Preferences:** Guidance that should be followed but may be overridden with explicit justification
- 2b. Define a **resolution algorithm**:
  1. Detect conflict (two constraints producing mutually exclusive requirements)
  2. Classify both constraints by tier
  3. Higher-tier wins
  4. If same tier, the more specific constraint wins (narrower scope > broader scope)
  5. If same tier and same scope, flag as unresolvable
- 2c. Define **unresolvable conflict protocol**:
  - Halt execution on the affected path
  - Flag the conflict with exact constraint references
  - Defer to human operator
  - Log the conflict as a structured record for later framework evolution
- 2d. Add a "Constraint Conflict Resolution" section to the framework document

**Deliverable:** New section in `Semantic Constraint Framework.md`.

---

### 3. Artifact-to-Artifact Conflict Resolution

**Goal:** Define how to detect and resolve conflicts between different artifact types (e.g., a Skill says "always do X" but a Plan says "never do X").

**Subtasks:**
- 3a. Define an **artifact authority hierarchy**:
  - **Invariants** in any artifact override all other artifact types
  - **Plans** are the source of truth for *what* will be built
  - **Skills** are the source of truth for *how* an agent may act
  - **Configuration Files** override default behavior declared in other artifacts
  - **Session Handoffs** are transient and never override persistent artifacts
- 3b. Define a **detection mechanism**:
  - Agents must cross-reference constraints from all active artifacts before execution
  - Flag any constraint that contradicts a higher-authority artifact
  - Run detection at artifact creation time and at session start
- 3c. Define a **resolution protocol**:
  - Auto-resolve when authority hierarchy is clear
  - Flag and defer to human when authority is ambiguous or circular
  - Log all cross-artifact conflicts as structured records
- 3d. Add an "Artifact-to-Artifact Conflict Resolution" section to the framework document

**Deliverable:** New section in `Semantic Constraint Framework.md`.

---

### 4. Versioning & Migration Strategy

**Goal:** Define how to version the framework itself and migrate artifacts when framework rules change.

**Subtasks:**
- 4a. Define a **framework versioning scheme**:
  - Use `MAJOR.MINOR.PATCH` for the framework itself
  - Each artifact declares `framework_version: X.Y` in its frontmatter
  - MAJOR = breaking structural changes (new required sections, section removals)
  - MINOR = additive changes (new optional sections, clarifications)
  - PATCH = typo fixes, prose improvements, no structural change
- 4b. Define **migration rules**:
  - When framework MAJOR version changes, all artifacts must be migrated before use
  - Provide a migration checklist per framework version bump
  - Migration is itself a semantic-constrained task (must follow the framework)
- 4c. Define **backward compatibility policy**:
  - MINOR and PATCH updates are backward-compatible — old artifacts remain valid
  - MAJOR updates require explicit migration — old artifacts are marked stale
- 4d. Define **staleness detection**:
  - Compare artifact `framework_version` against current framework version
  - If MAJOR versions differ, artifact is stale and must not be used until migrated
  - If MINOR versions differ, artifact is valid but should be updated at next edit
- 4e. Add a "Versioning & Migration" section to the framework document

**Deliverable:** New section in `Semantic Constraint Framework.md`.

---

### 5. Verification Function (VF) Specification

**Goal:** Define standard formats and protocols for Python VFs and Natural Language VFs.

**Subtasks:**
- 5a. Define **Python VF standard format**:
  - Function signature: `def verify_<subtask_name>(output: Any, context: dict) -> VFResult`
  - Return type: `VFResult` dataclass with fields: `passed: bool`, `reason: str`, `details: dict`
  - Assertion style: prefer explicit assertions over try/except for expected failures
  - Error reporting: return `VFResult(passed=False, reason="...", details={...})` — never raise exceptions
- 5b. Define **Natural Language VF standard format**:
  - Structured template with sections: Task Description, Input Reference, Expected Output Criteria, Pass/Fail Reporting Format
  - Evaluation criteria must be binary (pass/fail) — no partial credit
  - Report format: "PASS: <reason>" or "FAIL: <reason> — expected X, got Y"
- 5c. Define **VF execution protocol**:
  1. Run all VFs for the subtask
  2. Aggregate results with logical AND — all must pass
  3. On failure: log precise diagnostics
  4. Retry with updated context (max 3 attempts)
  5. If still failing after 3 retries: replan the subtask
- 5d. Define **VF failure handling protocol**:
  - Retry: same subtask, same VFs, with failure diagnostics appended to context
  - Replan: rewrite subtask definition, update VFs if they were too strict
  - Escalate: flag for human review if replan also fails
- 5e. Add a "Verification Function Specification" section to the framework document

**Deliverable:** New section in `Semantic Constraint Framework.md`.

---

### 6. Constraint Sufficiency — "When Is It Constrained Enough?"

**Goal:** Define stopping criteria and guidelines for constraint density.

**Subtasks:**
- 6a. Define the **Constraint Sufficiency Test**:
  - For every execution path the artifact governs, at least one applicable constraint must exist
  - For every possible failure mode listed in the artifact, at least one constraint must address it
  - For every input field, the artifact must declare: required/optional, format, validation rule
- 6b. Define **minimum constraint density guidelines** per artifact type:
  - Plans: minimum 5 constraints, maximum 25
  - Skills: minimum 8 constraints, maximum 30
  - Tool Definitions: minimum 3 constraints per tool, maximum 15
  - Memory Notes: minimum 2 constraints, maximum 10
  - Prompts & Templates: minimum 3 constraints, maximum 15
- 6c. Define the **self-check protocol**:
  1. List every thing that could go wrong for this artifact's domain
  2. For each, identify which constraint addresses it
  3. Any unaddressed risk → add a constraint
  4. Any constraint that addresses no risk → remove it
  5. Repeat until every risk is covered and every constraint is necessary
- 6d. Add a "Constraint Sufficiency" section to the framework document

**Deliverable:** New section in `Semantic Constraint Framework.md`.

---

### 7. Artifact Granularity Guidelines

**Goal:** Define when to split or merge artifacts.

**Subtasks:**
- 7a. Define **maximum size guidelines**:
  - Soft limit: 1,500 tokens per artifact (≈ 1,000 words)
  - Hard limit: 3,000 tokens per artifact (≈ 2,000 words)
  - Artifacts exceeding the hard limit must be split
- 7b. Define **splitting criteria** (split one artifact into two when):
  - The artifact governs two or more distinct domains or subsystems
  - The artifact has more than 15 constraints
  - The artifact has more than 5 type-specific sections
  - Different teams or agents own different parts of the artifact
- 7c. Define **merging criteria** (merge two artifacts into one when):
  - Both artifacts govern the same domain and share >50% of their constraints
  - Both artifacts are under 400 tokens and always used together
  - Cross-references between the two artifacts exceed 3 bidirectional references
- 7d. Add an "Artifact Granularity" section to the framework document

**Deliverable:** New section in `Semantic Constraint Framework.md`.

---

### 8. Section Depth Guidance

**Goal:** Define how deep each of the 10 universal sections should be.

**Subtasks:**
- 8a. Define **min/max guidance per section**:

| Section | Min | Max | Notes |
|---------|-----|-----|-------|
| Purpose | 1 sentence | 3 sentences | Must state the single reason the artifact exists |
| Scope | 1 sentence | 1 paragraph | Must name what is covered AND what is excluded |
| Inputs | 1 item | 10 items | Each input: name, type, format, precondition |
| Outputs | 1 item | 10 items | Each output: name, type, format, postcondition |
| Constraints | 3 rules | 20 rules | Each rule: declarative, testable, scoped |
| Invariants | 1 rule | 10 rules | Each invariant: must hold across ALL execution paths |
| Failure Modes | 1 mode | 10 modes | Each mode: trigger, behavior, recovery |
| Validation Strategy | 1 method | 5 methods | Must reference VF spec or equivalent |
| Relationships | 0 (may be "none") | 10 references | Each reference: artifact name, direction (depends on / depended by) |
| Guarantees | 1 guarantee | 10 guarantees | Each guarantee: postcondition, scope |

- 8b. Define **when to expand vs. keep minimal**:
  - Expand when: the section governs a complex domain, there are known failure modes, the artifact is high-cost (per the Cost Rule)
  - Keep minimal when: the domain is simple, the artifact is low-cost, the section is self-evident
- 8c. Define **what "complete" looks like** for each section:
  - Complete = every declared input/output/constraint has a matching counterpart (inputs are consumed, outputs are produced, constraints are testable)
- 8d. Add a "Section Depth Guidance" section to the framework document

**Deliverable:** New section in `Semantic Constraint Framework.md`.

---

### 9. Validation Strategy Specification

**Goal:** Define what "good" validation looks like per artifact type.

**Subtasks:**
- 9a. Define **validation strategy templates** per artifact type:
  - Plans: structural validation (all 10 sections present), constraint validation (all constraints are declarative), guarantee validation (all guarantees are testable)
  - Skills: invocation condition validation, phase separation validation, constraint validation
  - Tool Definitions: signature validation, side-effect declaration validation, idempotency check
  - Memory Notes: freshness validation, conflict resolution validation, scope validation
  - Prompts & Templates: KERNEL compliance, placeholder validation, constraint block validation
- 9b. Define **minimum validation coverage**:
  - Every constraint must have at least one validation method
  - Every invariant must be independently verifiable
  - Every failure mode must have a detection method
- 9c. Define **validation report format**:
  - Header: artifact name, version, validator, timestamp
  - Body: per-section pass/fail with reasons
  - Summary: total pass, total fail, warnings
  - Verdict: PASS / FAIL / PASS_WITH_WARNINGS
- 9d. Define **escalation protocol**:
  - FAIL → block use of artifact, flag for revision
  - PASS_WITH_WARNINGS → allow use, schedule revision within next edit cycle
  - PASS → no action required
- 9e. Add a "Validation Strategy Specification" section to the framework document

**Deliverable:** New section in `Semantic Constraint Framework.md`.

---

### 10. Constraint Language Standardization

**Goal:** Define a formal constraint grammar and language for expressing rules unambiguously.

**Subtasks:**
- 10a. Define a **formal constraint grammar**:
  ```
  CONSTRAINT := MODALITY SUBJECT PREDICATE [SCOPE] [TEMPORAL]
  MODALITY := "must" | "must not" | "may" | "shall" | "shall not"
  SUBJECT := noun phrase identifying the constrained entity
  PREDICATE := verb phrase describing the required/prohibited behavior
  SCOPE := "for" noun phrase (optional — limits applicability)
  TEMPORAL := "always" | "once" | "during" phase-name | "before" event | "after" event (optional)
  ```
- 10b. Define **constraint types**:
  - **Prohibitive:** "must not X" — blocks behavior
  - **Mandatory:** "must X" — requires behavior
  - **Permissive:** "may X" — grants permission (overrides default prohibition)
  - **Conditional:** "must X when Y" — requirement triggered by condition
- 10c. Define **constraint scope expression**:
  - Global: applies to all uses of the artifact
  - File-specific: `for <path-pattern>` — applies only to matching files
  - Type-specific: `for <type>` — applies only to artifacts of a given type
  - Phase-specific: `during <phase>` — applies only during a named lifecycle phase
- 10d. Define **constraint temporal behavior**:
  - Always: holds at all times (default for invariants)
  - Once: must be satisfied at least once during execution
  - During: holds only during a named phase
  - Before/After: ordering constraints relative to events
- 10e. Add a "Constraint Language Standardization" section to the framework document

**Deliverable:** New section in `Semantic Constraint Framework.md`.

---

## Summary of Deliverables

| Item | Deliverable | Location |
|------|------------|----------|
| 1 | Worked examples (3 before/after pairs) | `semantic-constraint-framework/examples/worked-examples.md` |
| 2 | Constraint Conflict Resolution Rules | Section in `Semantic Constraint Framework.md` |
| 3 | Artifact-to-Artifact Conflict Resolution | Section in `Semantic Constraint Framework.md` |
| 4 | Versioning & Migration Strategy | Section in `Semantic Constraint Framework.md` |
| 5 | Verification Function Specification | Section in `Semantic Constraint Framework.md` |
| 6 | Constraint Sufficiency | Section in `Semantic Constraint Framework.md` |
| 7 | Artifact Granularity Guidelines | Section in `Semantic Constraint Framework.md` |
| 8 | Section Depth Guidance | Section in `Semantic Constraint Framework.md` |
| 9 | Validation Strategy Specification | Section in `Semantic Constraint Framework.md` |
| 10 | Constraint Language Standardization | Section in `Semantic Constraint Framework.md` |

---

## Post-Execution Validation

After all 10 items are addressed:

1. The "Incomplete Work" section in `Semantic Constraint Framework.md` must be replaced with a "Completed Work" summary
2. All new sections must pass the framework's own validation rules (all 10 universal sections present, declarative language, explicit uncertainty)
3. The worked examples must be reviewed for correctness and clarity
4. The constraint language must be self-consistent (the framework must be expressible in its own constraint language)
