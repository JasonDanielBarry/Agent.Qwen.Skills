# Semantic Constraint Design for AI Agents

## Foundational Philosophy

**Structure and explicit constraints can contain AI's inherent randomness, turning probabilistic behavior into reliably deterministic outcomes.**

AI cannot be made deterministic internally, but the *space of valid actions* can be narrowed, interpretation can be frozen early, and deviations can be made unlikely or detectable. Semantic artifacts are tools for **entropy reduction**.

---

## Core Principles

### 1. Artifacts Are Semantic Source Files
A semantic artifact is not documentation, prose, or a suggestion.

It is:
- An **authoritative declaration of intent**
- A **constraint-bearing artifact**
- The **source of truth** for all later actions

Implementation becomes a *generated artifact*. Semantic artifacts define **meaning**.

### 2. Structure > Clever Prompting
AI reliability increases when:
- Structure is rigid
- Sections are mandatory
- Constraints are explicit
- Ambiguity is surfaced, not hidden

Structure reduces entropy. Entropy reduction increases repeatability.

### 3. The Cost Rule
> **Any artifact that an agent reads, writes, or acts on — and where incorrect behavior has a cost — should use semantic constraint structure.**

If a mistake is harmless, structure is optional. If a mistake is expensive (data loss, security breach, broken deployment, corrupted memory), semantic constraints are mandatory.

---

## How to Write Constraints Effectively

Use **declarative language**, not suggestions.

✅ Prefer: `must`, `must not`, `required`, `forbidden`, `guaranteed`
❌ Avoid: `try to`, `ideally`, `if possible`, `approximately`

Constraints are instructions to the AI's reasoning engine.

### Make Uncertainty Explicit
If something is not decided:

- Do not guess
- Do not imply defaults
- Do not leave it implicit

Instead, write:

> "This is currently unspecified and must be decided before use."

Explicit uncertainty is still semantic signal.

---

## Constraint Language Standardization

A formal grammar for expressing constraints unambiguously, enabling automated validation and conflict detection.

### Formal Constraint Grammar

```
CONSTRAINT := MODALITY SUBJECT PREDICATE [SCOPE] [TEMPORAL]

MODALITY := "must" | "must not" | "may" | "shall" | "shall not"

SUBJECT := noun phrase identifying the constrained entity
  Examples: "the agent", "the output", "the file", "the errors array"

PREDICATE := verb phrase describing the required or prohibited behavior
  Examples: "return a valid ExtractionResult", "modify the source file",
            "prompt the user for a password"

SCOPE := "for" noun phrase            (optional — limits applicability)
  Examples: "for files larger than 50 MB", "for encrypted PDFs",
            "for the EXECUTION phase"

TEMPORAL := "always"                  (optional — when the constraint applies)
          | "once"
          | "during" phase-name
          | "before" event
          | "after" event
  Examples: "always", "once per session", "during the REVIEW phase",
            "before writing to disk", "after parsing completes"
```

**Default values:**
- If SCOPE is omitted: the constraint applies globally (to all uses of the artifact).
- If TEMPORAL is omitted: the constraint applies always (for invariants) or at the time of the governed action (for constraints).

### Constraint Types

| Type | Form | Purpose | Example |
|------|------|---------|---------|
| **Prohibitive** | `must not` + SUBJECT + PREDICATE | Blocks behavior | "The agent must not modify the source PDF file." |
| **Mandatory** | `must` + SUBJECT + PREDICATE | Requires behavior | "The output must include an errors array." |
| **Permissive** | `may` + SUBJECT + PREDICATE | Grants permission (overrides default prohibition) | "The agent may skip table extraction when the user requests text only." |
| **Conditional** | `must` + SUBJECT + PREDICATE + `when` + CONDITION | Requirement triggered by condition | "The agent must prompt for a password when the PDF is encrypted." |

### Constraint Scope Expressions

| Scope Type | Syntax | Applies To |
|-----------|--------|-----------|
| Global | (no scope clause) | All uses of the artifact |
| File-specific | `for <path-pattern>` | Only matching files, e.g., `for *.pdf` |
| Type-specific | `for <type>` | Only artifacts of a given type, e.g., `for encrypted PDFs` |
| Phase-specific | `during <phase>` | Only during a named lifecycle phase, e.g., `during EXECUTION` |

### Constraint Temporal Behavior

| Temporal | Meaning | Default For |
|----------|---------|-------------|
| `always` | Holds at all times during and after execution | Invariants |
| `once` | Must be satisfied at least once during execution | Setup constraints, initialization requirements |
| `during <phase>` | Holds only during a named phase | Phase-specific constraints |
| `before <event>` | Must be satisfied prior to the named event | Preconditions, prerequisites |
| `after <event>` | Must be satisfied following the named event | Postconditions, cleanup requirements |

### Examples in the Formal Grammar

```
must the output include an errors array                              [Mandatory, Global, always]
must not the agent modify the source file                             [Prohibitive, Global, always]
must the agent prompt for a password when the PDF is encrypted       [Conditional, Global, always]
must the agent use streaming for files > 50 MB for large files       [Mandatory, File-specific, always]
must all VFs pass before returning output to user                    [Mandatory, Global, before return]
may the agent skip OCR during EXECUTION when OCR is unavailable       [Permissive, Phase-specific, during EXECUTION]
```

---

## Constraint Sufficiency

When is an artifact constrained enough? The sufficiency test determines the stopping point.

### The Constraint Sufficiency Test

An artifact passes the sufficiency test when ALL three conditions are met:

1. **Path Coverage:** For every execution path the artifact governs, at least one applicable constraint exists.
   - Method: enumerate all execution paths from the artifact's Scope and Inputs sections. For each path, identify at least one constraint that applies.

2. **Failure Coverage:** For every failure mode listed in the artifact, at least one constraint addresses it.
   - Method: for each Failure Mode, identify at least one constraint that prevents, detects, or governs the recovery behavior.

3. **Input Coverage:** For every input field, the artifact declares: required/optional status, expected format, and a validation rule.
   - Method: for each input in the Inputs section, verify all three declarations are present.

If any condition fails, the artifact is under-constrained and must be revised before use.

### Minimum Constraint Density Guidelines

These are baseline guidelines, not hard limits. The Sufficiency Test is the final arbiter.

| Artifact Type | Minimum Constraints | Maximum Constraints | Notes |
|--------------|-------------------|-------------------|-------|
| Plans | 5 | 25 | Plans govern what will be built — they need constraints on scope, data, architecture, and behavior. |
| Skills | 8 | 30 | Skills govern agent behavior — they need constraints on invocation, forbidden actions, phase separation, and outputs. |
| Tool Definitions | 3 per tool | 15 per tool | Each tool needs at minimum: precondition, postcondition, side-effect declaration. |
| Memory Notes | 2 | 10 | Memory notes need constraints on scope and freshness at minimum. |
| Prompts & Templates | 3 | 15 | Prompts need constraints on role definition, output format, and forbidden behavior. |
| Session Handoffs | 2 | 10 | Handoffs need constraints on completeness (no placeholders) and actionability (next steps must be specific). |

**Below minimum:** artifact is almost certainly under-constrained. Add constraints.
**Above maximum:** artifact may be too large. Consider splitting (see Artifact Granularity Guidelines).

### Self-Check Protocol

Before declaring an artifact complete, run this self-check:

1. **List every thing that could go wrong** for this artifact's domain. Write them as risks: "The agent might...", "The input could be...", "The output might..."
2. **For each risk, identify which constraint addresses it.** Write the constraint reference (section, number).
3. **Any risk with no addressing constraint → add a constraint.** This is the primary mechanism for achieving sufficiency.
4. **Any constraint that addresses no risk → remove it.** Dead constraints add noise without value.
5. **Repeat steps 1-4** until every risk is covered and every constraint is necessary.

This protocol converges because each iteration either adds a necessary constraint or removes a dead one, both of which move the artifact toward sufficiency.

---

## Section Depth Guidance

Each of the 10 universal sections has a target depth. This prevents one-line summaries that miss critical detail and paragraphs of prose that waste context window.

### Min/Max Guidance per Section

| Section | Minimum | Maximum | What "Complete" Looks Like |
|---------|---------|---------|---------------------------|
| **Purpose** | 1 sentence | 3 sentences | The single reason the artifact exists is unambiguously stated. A reader can answer "why does this exist?" without reading further. |
| **Scope** | 1 sentence naming both in-scope and out-of-scope | 1 paragraph | Both what is covered and what is excluded are explicitly named. No implied scope. |
| **Inputs** | 1 item with name, type, format, precondition | 10 items | Every declared input has all four declarations. No input is referenced only in prose. |
| **Outputs** | 1 item with name, type, format, postcondition | 10 items | Every declared output has all four declarations. Error outputs are declared alongside success outputs. |
| **Constraints** | 3 rules | 20 rules | Each rule is declarative ("must"/"must not"), testable, and scoped. Each rule addresses at least one identified risk (see Sufficiency Test). |
| **Invariants** | 1 rule | 10 rules | Each invariant holds across ALL execution paths. Each invariant is independently testable. No invariant is redundant with a constraint. |
| **Failure Modes** | 1 mode with trigger, behavior, recovery | 10 modes | Each mode has all three components. Error paths are as well-defined as success paths. No "unknown" or "other" catch-all. |
| **Validation Strategy** | 1 method referencing a VF or equivalent | 5 methods | Each method is specific enough to execute. Coverage is defined. Report format and escalation are declared. |
| **Relationships** | 0 (may state "none") | 10 references | Each reference names the artifact, direction (depends on / depended by), and the nature of the dependency. |
| **Guarantees** | 1 guarantee | 10 guarantees | Each guarantee is a postcondition that can be verified after execution. No guarantee restates an invariant. |

### When to Expand vs. Keep Minimal

**Expand a section when:**
- The section governs a complex domain with many moving parts
- There are known failure modes or edge cases in this area
- The artifact is high-cost per the Cost Rule (mistakes here are expensive)
- Prior constraint violations have occurred in this area

**Keep minimal when:**
- The domain is simple and well-understood
- The artifact is low-cost per the Cost Rule (mistakes here are cheap)
- The section is self-evident (e.g., "Relationships: none" for a standalone artifact)
- Additional detail would restate what is already declared elsewhere in the artifact

---

## Proven Techniques for Constraining Probabilistic Behavior

Research and production experience have identified several techniques that reliably constrain LLM behavior:

### A. Prompt Chaining & Step-Locked Execution
- Break complex tasks into discrete, sequential stages instead of single prompts
- Each stage's output becomes the next stage's input
- Apply mandatory validation gates between steps — no bypassing
- Use when tasks exceed single-prompt complexity or require clean checkpoints

### B. Structured Output Passing
- Constrain intermediate outputs between chain steps into predictable, structured formats (JSON, schemas, fixed templates)
- Never pass loose text between stages
- Ensures downstream steps receive exact, parseable fields, preventing format drift

### C. Verification Functions (VFs)
- Embed subtask-specific acceptance criteria directly into artifacts
- **Python VFs:** Self-contained executable assertions that deterministically validate output structure, data types, format, and functional correctness
- **Natural Language VFs:** Prompt-based criteria that guide an LLM verifier to assess semantic accuracy and reasoning alignment
- Evaluate all VFs with logical AND — all must pass or the subtask fails
- On failure: return precise diagnostics, retry with updated context (max 3), then replan if still failing

### D. Formal Invariants & Transition Verification
- Define strict, non-negotiable safety conditions that must hold across all execution paths
- Treat state changes as atomic operations — simulate proposed transitions and reject entirely if any invariant fails
- Pre-execution enforcement: unsafe proposals are blocked at simulation stage, not corrected after execution

### E. Self-Verification Loops
- Mandatory pre-output checklist or self-critique against constraints
- Controlled reflection with strict validation checklists, maximum refinement passes, and explicit "good enough" stop conditions
- Prevents expensive indecision and infinite refinement loops

### F. The KERNEL Constraint Framework
Apply this checklist when designing any semantic artifact:

| Letter | Principle | Purpose |
|---|---|---|
| **K** | Keep it simple | Single, unambiguous primary goal — prevents scope creep |
| **E** | Easy to verify | Pre-defined success metrics and quality checkpoints |
| **R** | Reproducible results | Identical inputs must produce equivalent outputs |
| **N** | Narrow scope | Explicit domain and task limits — no general-purpose behavior |
| **E** | Explicit constraints | Hard boundaries on data sources, tools, and capabilities |
| **L** | Logical structure | Strict structural, token, or styling boundaries |

### G. Negative Constraints
- Explicitly state what the agent must **not** do
- "Do not use external libraries," "Do not modify files outside scope," "Do not guess unspecified values"
- Blocking unwanted behavior is more effective than only prescribing desired behavior

### H. Observability & Monitoring
- Track real-time metrics: milestone progress, tool outcomes, error rates, token usage, escalation frequency
- Continuous trajectory evaluation — assess both final outputs and execution paths
- Native exception handling: design error detection, retries, fallbacks, rollbacks, and human escalation into the workflow architecture

---

## Universal Artifact Design

### When an Artifact Needs Semantic Discipline

Apply semantic structure when the artifact is:
- Reusable
- Long-lived
- Authority-granting
- A prerequisite for other actions
- Able to affect downstream artifacts or system state

### Universal Required Sections

Every semantic artifact **must** define:

1. **Purpose** — why this artifact exists
2. **Scope** — what it covers and what it excludes
3. **Inputs** — explicit sources, formats, and preconditions
4. **Outputs** — artifacts produced or state changes made
5. **Constraints** — hard boundaries on behavior, data, and side effects
6. **Invariants** — conditions that must hold across all execution paths
7. **Failure Modes** — how missing info, errors, and edge cases are handled
8. **Validation Strategy** — how correctness is verified
9. **Relationships** — dependencies, ordering, and boundaries with other artifacts
10. **Guarantees** — postconditions the artifact commits to

Type-specific sections are added on top of this universal base.

---

## Artifact Granularity Guidelines

Artifacts that are too large overwhelm context windows. Artifacts that are too small fragment knowledge.

### Maximum Size Guidelines

| Metric | Soft Limit | Hard Limit | Action |
|--------|-----------|------------|--------|
| Token count | 1,500 tokens (~1,000 words) | 3,000 tokens (~2,000 words) | Above hard limit: must split |
| Section count | 15 sections | 25 sections | Above hard limit: must split |
| Constraint count | 15 constraints | 25 constraints | Above hard limit: must split |

Soft limits are warnings — the artifact should be reviewed for splitting. Hard limits are rules — the artifact must be split before use.

### Splitting Criteria

Split one artifact into two when ANY of these conditions are met:

1. **Distinct domains:** The artifact governs two or more distinct subsystems or domains that could be owned independently.
   - Example: a Skill that handles both PDF extraction and spreadsheet generation should be two Skills.
2. **Constraint overload:** The artifact has more than 15 constraints (see Constraint Sufficiency maximums).
3. **Section overload:** The artifact has more than 5 type-specific sections in addition to the 10 universal sections.
4. **Ownership split:** Different teams, agents, or roles own different parts of the artifact.
5. **Context pressure:** The artifact is loaded into context alongside other artifacts and the combined token count approaches the model's limit.

### Merging Criteria

Merge two artifacts into one when ALL of these conditions are met:

1. **Domain overlap:** Both artifacts govern the same domain and share more than 50% of their constraint subject matter.
2. **Small size:** Both artifacts are under 400 tokens (~270 words) each.
3. **Co-use:** Both artifacts are always loaded together (the agent uses them in the same workflow every time).
4. **Cross-reference density:** Cross-references between the two artifacts exceed 3 bidirectional references.

**Never merge artifacts solely to reduce file count.** Merging must improve clarity, not reduce it.

---

## Artifact Catalog

Each artifact type below uses the universal required sections plus its type-specific requirements.

### 1. Plans
**Role:** Authoritative declaration of what will be built. Source of truth for all downstream implementation.

**Type-specific sections:**
- **High-Level Summary** — overview for quick orientation
- **Data Model (Semantic)** — meaning-bearing data definitions, not structural schemas
- **System Architecture** — component layout and interaction patterns
- **Key Operations** — primary use cases and workflows
- **Optimization Policy** — performance, memory, and efficiency priorities
- **Extensibility** — future considerations and extension points

**Must also:** Be written before implementation, contain no executable logic, separate intent from mechanism.

---

### 2. Skills
**Role:** Capability contracts declaring what an agent is allowed to do.

**Type-specific sections:**
- **Invocation Conditions** — when the skill may run
- **Forbidden Usage** — concrete prohibitions
- **Phase Separation** — which lifecycle phases this skill participates in and may not bypass

**Must also:** Be more constrained than plans. Enforce PLAN → CODE → REVIEW → REVISE ordering — no phase may be skipped.

---

### 3. Tool Definitions
**Role:** Interface contracts for functions, APIs, or commands an agent may call.

**Type-specific sections:**
- **Tool Signature** — name, parameters (types, required/optional), return type
- **Side Effects** — what external state this tool modifies (files, network, database)
- **Preconditions** — state that must exist before calling
- **Postconditions** — guaranteed state after successful execution
- **Destructive Operations** — flag if tool performs irreversible actions; require explicit confirmation flow
- **Idempotency** — whether repeated calls produce the same result

**Must also:** Distinguish read-only from write tools. Declare error behavior (throw, return code, retry).

---

### 4. Memory & Context Notes
**Role:** Persistent state carried across agent sessions.

**Type-specific sections:**
- **Memory Scope** — global (user-level) vs project-level vs session-level
- **Retention Policy** — what is kept, what is discarded, when consolidation occurs
- **Conflict Resolution** — how contradictory entries are detected and resolved
- **Freshness** — how stale entries are identified and expired
- **Access Patterns** — who reads, who writes, when updates trigger

**Must also:** Be concise — verbose memory wastes context window. Structured facts over narrative prose.

---

### 5. Review & Validation Criteria
**Role:** Standards by which agent output is evaluated.

**Type-specific sections:**
- **Checklist** — explicit pass/fail conditions, one per line
- **Acceptance Thresholds** — minimum criteria for pass (e.g., "all critical items must pass, max 2 warnings")
- **Review Scope** — what is in-scope and out-of-scope for this review
- **Escalation Rules** — when review failure requires human intervention vs automated retry

**Must also:** Reference the artifact being reviewed (plan, code, skill) — never review in isolation.

---

### 6. Session Handoffs
**Role:** Context transfer between agent sessions.

**Type-specific sections:**
- **What Was Done** — completed work summary
- **Where It Stopped** — exact stopping point with file paths and line references
- **What's Next** — ordered next steps as actionable items
- **Known Blockers** — unresolved issues, missing information, or dependencies
- **Key Decisions** — choices made during the session that affect downstream work

**Must also:** Be auto-generatable. The agent producing the handoff must fill all sections — no placeholders.

---

### 7. Prompts & Templates
**Role:** Reusable input structures that guide agent reasoning.

**Type-specific sections:**
- **Role Definition** — what persona or expertise the agent adopts
- **Task Specification** — the single, unambiguous primary goal
- **Input Slots** — clearly marked positions for variable content
- **Output Format** — exact structure the response must follow
- **Constraint Block** — what the agent must not do

**Must also:** Apply the KERNEL framework. Use placeholder markers for variable content (`{{input}}`, `[variable]`).

---

### 8. Error Handling Protocols
**Role:** Rules governing how agents detect, report, and recover from failures.

**Type-specific sections:**
- **Error Classification** — categories of failure (transient, permanent, unknown)
- **Retry Policy** — max attempts, backoff strategy, what context is preserved
- **Fallback Behavior** — what happens when retries are exhausted
- **Escalation Path** — when and how to involve human operators
- **State Preservation** — what must be rolled back vs retained on failure

**Must also:** Prevent infinite loops — every retry chain must have a bounded maximum.

---

### 9. Multi-Agent Communication Contracts
**Role:** Protocols for agent-to-agent interaction.

**Type-specific sections:**
- **Message Format** — structure, required fields, data types
- **Protocol Sequence** — expected order of exchanges (request → acknowledge → respond → confirm)
- **Timeout Policy** — how long to wait before declaring failure
- **Disagreement Resolution** — what happens when agents produce conflicting outputs
- **Authority Hierarchy** — which agent has final say in disputes

**Must also:** Prevent compounding misinterpretation — every message must reference a shared artifact or contract.

---

### 10. Configuration Files
**Role:** Agent behavior settings and environment parameters.

**Type-specific sections:**
- **Setting Definition** — name, type, valid range, default, description
- **Constraint Expression** — what behavior this setting constrains and how
- **Boundary Behavior** — what happens at min/max/invalid values
- **Dependency Map** — which other settings interact with this one
- **Override Rules** — whether and how runtime values can override configuration

**Must also:** Use declarative format settings (YAML, TOML, JSON) — never free-text configuration for agent behavior.

---

### 11. Test Definitions & Acceptance Criteria
**Role:** Specifications for what tests must verify.

**Type-specific sections:**
- **Test Scope** — what functionality or behavior is under test
- **Input Fixtures** — specific inputs or input generators
- **Expected Outputs** — exact or range-bounded expected results
- **Edge Cases** — boundary conditions, empty inputs, error inputs
- **Invariants Under Test** — conditions that must hold before, during, and after test execution

**Must also:** Be generatable from plans — tests validate plan guarantees, not just code behavior.

---

### 12. Data Models & Schemas
**Role:** Semantic definitions of data the agent creates, reads, or transforms.

**Type-specific sections:**
- **Entity Definitions** — logical entities, their meaning, and relationships
- **Field Specifications** — name, type, required/optional, constraints, derivation rules
- **Invariants** — conditions that must hold (uniqueness, referential integrity, value ranges)
- **Forbidden States** — data configurations that must never exist
- **Transformation Rules** — how data changes shape across operations

**Must also:** Separate semantic meaning (what data represents) from structural representation (how it's encoded).

---

## Enforcement & Validation

Semantic structure alone is insufficient — violations must be detectable and correctable.

### Artifact Validation
- Every universal section must be present and non-empty
- Constraints must use declarative language (must/must not, not try/ideally)
- Uncertainty must be explicitly declared, not silently defaulted
- Invariants must be testable — if an invariant cannot be verified, the artifact is incomplete

### Type-Specific Validation
- Each artifact type's specific sections must be present
- Type-specific rules (listed above) must be satisfied
- Artifacts referencing other artifacts must resolve all references

### Verification Functions

VFs are the mechanism for deterministic validation of artifact outputs.

#### Python VF Standard Format

Every Python VF follows this signature and return type:

```python
from dataclasses import dataclass
from typing import Any

@dataclass
class VFResult:
    passed: bool       # True if the VF passes, False otherwise
    reason: str        # Human-readable explanation of pass or failure
    details: dict      # Structured diagnostic details (optional fields, always present)

def verify_<subtask_name>(output: Any, context: dict) -> VFResult:
    """
    Validate the output of <subtask>.

    Args:
        output: The output to validate (type depends on subtask).
        context: Dictionary with execution context (inputs, artifact references, previous failures).

    Returns:
        VFResult with pass/fail status, reason, and diagnostics.

    Never raises exceptions — always returns a VFResult.
    """
    try:
        # Validation logic
        if <condition>:
            return VFResult(passed=True, reason="Description of what passed", details={})
        else:
            return VFResult(
                passed=False,
                reason="Expected X, got Y",
                details={"expected": X, "actual": Y, "field": "name"}
            )
    except Exception as e:
        return VFResult(
            passed=False,
            reason=f"VF execution error: {e}",
            details={"error_type": type(e).__name__, "error": str(e)}
        )
```

**Rules for Python VFs:**
- Must never raise exceptions — always return `VFResult`.
- Must be self-contained — no external dependencies beyond the Python standard library (unless explicitly declared in `context`).
- Must report precise diagnostics — `"failed"` is not sufficient; `"expected string, got None"` is.
- Must handle unexpected input gracefully — the `try/except` wrapper is mandatory.

#### Natural Language VF Standard Format

Natural Language VFs are structured prompts for LLM-based validation:

```markdown
## VF: <subtask_name>

**Input Reference:** <what output or artifact is being evaluated>

**Evaluation Criteria:**
1. <binary criterion 1> — PASS if X is present, FAIL otherwise.
2. <binary criterion 2> — PASS if Y matches Z, FAIL otherwise.
3. ...

**Pass/Fail Reporting Format:**
- PASS: "<brief reason>"
- FAIL: "<brief reason> — expected <X>, got <Y>"

**All criteria must pass (logical AND).** Report the first failure encountered.
```

**Rules for Natural Language VFs:**
- Every criterion must be binary — no partial credit, no "mostly correct."
- The evaluation must produce a clear PASS or FAIL verdict.
- The first failure is reported — evaluation stops at the first FAIL (short-circuit AND).

#### VF Execution Protocol

1. **Run all VFs** defined for the subtask.
2. **Aggregate results** with logical AND — all must pass.
3. **On failure:**
   a. Log precise diagnostics from the failing VF(s).
   b. Retry the subtask with updated context including the failure diagnostics (max 3 attempts).
   c. If still failing after 3 retries: replan the subtask.
4. **On replan failure:** escalate to human operator with structured report:
   ```
   VF FAILURE after retry and replan:
   - Subtask: <name>
   - VF: <name>
   - Attempts: 3 retries + 1 replan
   - Last failure: <reason>
   - Diagnostics: <details>
   ```

#### VF Failure Handling Summary

| Stage | Action |
|-------|--------|
| First failure | Retry subtask with failure diagnostics appended to context |
| After 3 retries | Replan subtask — rewrite definition, update VFs if they were too strict |
| After replan failure | Escalate to human — do not retry again |

### Validation Strategy Specification

The Validation Strategy section must define how the artifact's correctness is verified — not merely list checks.

#### Validation Strategy Templates per Artifact Type

Each artifact type has a standard validation profile:

**Plans:**
- Structural validation: all 10 universal sections present and non-empty, all type-specific sections present
- Constraint validation: all constraints use declarative language, Constraint Sufficiency Test passes
- Guarantee validation: all guarantees are testable postconditions, no guarantee restates an invariant
- Reference resolution: all artifact references resolve to existing artifacts

**Skills:**
- Invocation condition validation: conditions are specific and testable (not "when the user asks about PDFs")
- Phase separation validation: declared phases are valid (PLAN, CODE, REVIEW, REVISE), no prohibited bypasses
- Constraint validation: same as Plans
- Forbidden usage validation: all prohibitions are specific (not "don't do bad things")

**Tool Definitions:**
- Signature validation: all parameters have names, types, required/optional status
- Side-effect declaration validation: all external state modifications are declared
- Idempotency check: idempotency status is declared and consistent with side-effect declaration
- Error behavior declaration: error behavior (throw, return code, retry) is declared

**Memory Notes:**
- Freshness validation: `session_date` or equivalent timestamp is present and parseable
- Conflict resolution validation: no contradictions with higher-authority artifacts (see Artifact-to-Artifact Conflict Resolution)
- Scope validation: memory scope is declared (global, project, session)

**Prompts & Templates:**
- KERNEL compliance: all 6 KERNEL principles are satisfied
- Placeholder validation: all variable content uses recognized placeholder markers (`{{input}}`, `[variable]`)
- Constraint block validation: forbidden behaviors are explicitly listed

#### Minimum Validation Coverage

| Requirement | Coverage |
|-------------|----------|
| Every constraint must have at least one validation method | 100% constraint coverage |
| Every invariant must be independently verifiable | 100% invariant coverage |
| Every failure mode must have a detection method | 100% failure mode coverage |
| Every output must have a validation criterion | 100% output coverage |

#### Validation Report Format

Every validation produces a structured report:

```
VALIDATION REPORT
=================
Artifact: <name>
Version: <framework_version>
Validator: <agent name or human name>
Timestamp: <ISO 8601>

SECTION RESULTS:
- Purpose:          PASS
- Scope:            PASS
- Inputs:           PASS
- Outputs:          PASS
- Constraints:      PASS (N constraints, all declarative, sufficiency test passed)
- Invariants:       PASS (N invariants, all testable)
- Failure Modes:    PASS (N modes, all with trigger+behavior+recovery)
- Validation:       PASS (N methods, all coverage requirements met)
- Relationships:    PASS
- Guarantees:       PASS

VERDICT: PASS / FAIL / PASS_WITH_WARNINGS
```

#### Escalation Protocol

| Verdict | Action |
|---------|--------|
| **PASS** | No action required. Artifact is ready for use. |
| **PASS_WITH_WARNINGS** | Artifact may be used. Warnings must be addressed at next edit cycle. Warnings are non-blocking issues (e.g., constraint at soft limit, section nearing maximum depth). |
| **FAIL** | Artifact must NOT be used. Block until revision. Each failing section is listed with specific remediation instructions. |

### Runtime Enforcement
- Verification Functions (VFs) execute after each subtask — all must pass (logical AND)
- On VF failure: precise diagnostics → retry with updated context (max 3) → replan if still failing
- Formal invariants block unsafe state transitions before they commit
- Self-verification loops run before output delivery with explicit stop conditions

### Feedback Loop & Evolution
- When an agent repeatedly violates a constraint, the artifact must be updated — not the agent re-prompted
- Track constraint violations as structured data: which constraint, what deviation, outcome
- Use violation patterns to refine constraint language, add missing prohibitions, or tighten ambiguous sections
- Version all artifact changes — regression is detectable via diff

---

## Constraint Conflict Resolution

When two constraints within the same artifact contradict, the agent must detect and resolve the conflict before proceeding.

### Constraint Priority Model

Every constraint belongs to one of three tiers. Higher tiers always win over lower tiers.

| Tier | Name | Description | Behavior on Violation |
|------|------|-------------|----------------------|
| 1 | **Invariants** | Conditions that must hold across ALL execution paths. Non-negotiable safety conditions. | Block execution immediately. No retry. |
| 2 | **Constraints** | Hard rules that govern behavior within specific execution paths. Must be satisfied for correct operation. | Retry with updated context (max 3). Replan if still failing. |
| 3 | **Preferences** | Guidance that should be followed but may be overridden with explicit justification in the output. | Override allowed if justified. Justification must be stated. |

### Resolution Algorithm

When a conflict is detected (two constraints produce mutually exclusive requirements):

1. **Classify** both constraints by tier (Invariant, Constraint, or Preference).
2. **Higher tier wins.** A Tier 1 constraint overrides any Tier 2 or Tier 3 constraint. A Tier 2 constraint overrides any Tier 3 constraint.
3. **If same tier, apply specificity rule:** the constraint with the narrower scope wins. Specificity is determined by:
   - File-specific scope > type-specific scope > global scope
   - Conditional constraint (applies "when X") > unconditional constraint
   - Later constraint in document order > earlier constraint (only when scopes are identical)
4. **If same tier and same scope, mark as unresolvable.** Proceed to the Unresolvable Conflict Protocol.

### Unresolvable Conflict Protocol

When a conflict cannot be resolved by the algorithm above:

1. **Halt** execution on the affected execution path.
2. **Flag** the conflict with exact constraint references (section name, constraint text, line if available).
3. **Defer** to the human operator with a structured report:
   ```
   CONFLICT [unresolvable]:
   - Artifact: <name>
   - Constraint A: <full text>, tier <N>, scope <S>
   - Constraint B: <full text>, tier <N>, scope <S>
   - Conflict: <description of mutual exclusivity>
   ```
4. **Log** the conflict as a structured record for later framework evolution.
5. **Do not guess** which constraint to follow. An unresolvable conflict is a design error in the artifact, not an execution error.

---

## Artifact-to-Artifact Conflict Resolution

When constraints in different artifacts contradict, resolution follows an authority hierarchy and detection protocol.

### Artifact Authority Hierarchy

When two artifacts conflict, the higher-authority artifact wins. The hierarchy is:

| Rank | Artifact Type | Authority Level | Notes |
|------|--------------|-----------------|-------|
| 1 | **Invariants** (in any artifact) | Absolute | An invariant declared anywhere overrides all other declarations everywhere. |
| 2 | **Configuration Files** | High | Override default behavior declared in other artifacts. Settings are explicit behavior selectors. |
| 3 | **Plans** | High | Source of truth for *what* will be built. Plans override Skills when the plan explicitly forbids or requires behavior. |
| 4 | **Skills** | Medium | Source of truth for *how* an agent may act. Skills override Memory Notes and Prompts. |
| 5 | **Tool Definitions** | Medium | Source of truth for interface contracts. Tools override Prompts when tool preconditions contradict prompt instructions. |
| 6 | **Prompts & Templates** | Low | Reusable input structures. Overridden by all persistent artifacts. |
| 7 | **Memory & Context Notes** | Lowest | Transient state. Never override persistent artifacts. Memory notes that contradict persistent artifacts are stale and must be ignored. |

**Session Handoffs** are transient and ranked equal to Memory Notes — they never override persistent artifacts.

### Detection Mechanism

Cross-artifact conflicts must be detected before execution begins:

1. **At artifact creation time:** When creating a new artifact, the author (human or agent) must cross-reference constraints from all active artifacts in the workspace. Any constraint that contradicts a higher-authority artifact must be flagged immediately.
2. **At session start:** When `sas-reattach` or equivalent loads session context, the agent must scan for conflicts between the loaded context and persistent artifacts (Plans, Skills, Configuration Files).
3. **Continuous detection:** During execution, if the agent encounters a constraint from one artifact that contradicts a constraint from another, it must halt the affected path and apply the resolution protocol.

### Resolution Protocol

1. **Auto-resolve** when the authority hierarchy is clear (higher-rank artifact wins).
2. **Flag and defer** to human when:
   - Two artifacts at the same rank contradict (e.g., two Skills with opposing constraints)
   - The authority relationship is ambiguous
   - An invariant in a lower-rank artifact contradicts a constraint in a higher-rank artifact (rank-1 invariants are absolute, but this signals a design error that must be corrected)
3. **Log** all cross-artifact conflicts as structured records:
   ```
   CROSS-ARTIFACT CONFLICT:
   - Artifact A: <name>, rank <N>, constraint: <text>
   - Artifact B: <name>, rank <N>, constraint: <text>
   - Resolution: <auto-resolved to A | deferred to human>
   ```

---

## Versioning & Migration Strategy

Artifacts drift as the framework evolves. Versioning and migration ensure consistency.

### Framework Versioning Scheme

The framework itself uses `MAJOR.MINOR.PATCH` versioning:

| Component | Meaning | Examples |
|-----------|---------|----------|
| **MAJOR** | Breaking structural change: new required sections added, sections removed, universal base redefined | Adding an 11th universal section, removing the Guarantees section |
| **MINOR** | Additive change: new optional sections, new artifact types, clarifications that do not invalidate existing artifacts | Adding a new artifact type to the catalog, adding an optional section to Skills |
| **PATCH** | Non-breaking: typo fixes, prose improvements, examples added, no structural change | Rewording a description, fixing a typo in a section name |

The current framework version is **1.0.0**.

### Artifact Version Declaration

Every artifact declares its framework version in YAML frontmatter:

```yaml
---
framework_version: "1.0"
---
```

The artifact declares the `MAJOR.MINOR` version only — PATCH-level changes are always backward-compatible and do not require migration.

### Migration Rules

| Framework Change | Artifact Action |
|-----------------|-----------------|
| **MAJOR version change** (e.g., 1.0 → 2.0) | All artifacts must be migrated before use. New required sections must be added. Removed sections must be deleted. Migration is itself a semantic-constrained task — the migration plan must follow this framework. |
| **MINOR version change** (e.g., 1.0 → 1.1) | Existing artifacts remain valid. New optional sections may be added at next edit. No forced migration required. |
| **PATCH version change** (e.g., 1.0.0 → 1.0.1) | No action required. All artifacts remain valid. |

### Backward Compatibility Policy

- MINOR and PATCH updates are **backward-compatible** — artifacts written against older MINOR/PATCH versions remain valid.
- MAJOR updates are **breaking** — artifacts written against a previous MAJOR version are marked stale and must not be used until migrated.

### Staleness Detection

Compare the artifact's `framework_version` against the current framework version:

| Comparison | Status | Action |
|-----------|--------|--------|
| MAJOR versions differ | **Stale** | Artifact must not be used until migrated. Flag on load. |
| MAJOR same, MINOR artifact < MINOR current | **Valid, outdated** | Artifact may be used. Should be updated at next edit cycle. |
| MAJOR same, MINOR same | **Current** | No action required. |

Agents must report staleness status when loading an artifact:
- Stale: `"WARNING: This artifact was written for framework v{X}.0 but the current framework is v{Y}.0. It must be migrated before use."`
- Outdated: `"NOTE: This artifact was written for framework v{X}.{A} and the current framework is v{X}.{B}. It is valid but may be missing newer optional sections."`

---

## Human vs AI Optimization Dial

### Human-Optimized Artifacts
- Explanatory prose
- Friendly narrative
- Justification and context
- Designed for onboarding

### AI-Optimized Artifacts
- Minimal prose
- Dense constraints
- Explicit guarantees
- Zero ambiguity

Same meaning, different surface. Control the dial intentionally.

---

## Why Markdown Works (for Now)

Markdown is effective because it is:
- Textual
- Diffable
- Versionable
- Tool‑agnostic
- LLM‑friendly

Markdown is acting as a **proto‑semantic language carrier**. Over time, syntax may formalize — structure should not change.

---

## How This Improves AI Behavior

Semantic artifacts:
- Freeze interpretation early
- Reduce degrees of freedom
- Anchor reasoning
- Increase self-consistency pressure
- Make violations detectable

This produces:
- Higher repeatability
- Fewer "creative" deviations
- Safer regeneration
- More trustworthy automation

---

## Final Mental Model

- AI is probabilistic
- You don't remove probability — you **contain** it
- Semantic artifacts define the container
- The cost rule determines which artifacts need structure
- The container turns chaos into controlled search

---

## One-Sentence Rule

> **If an artifact constrains future behavior, it deserves semantic structure.**
