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
