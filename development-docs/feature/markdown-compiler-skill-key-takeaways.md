# Markdown Compiler Skill — Key Takeaways

## Overview

The `sas-semantic-compiler` aggressively optimizes markdown documents for AI agent consumption — improving instruction execution, guideline adherence, and structured information parsing. Human readability is NOT a concern.

**Compiler model:** Follows C/C++ paradigm — preprocessing phase (macro expansion, file inclusion, conflict detection) followed by compilation phase (machine-optimized output). Ambiguities or errors **HALT** compilation entirely, forcing users to resolve contradictions before producing compiled output. **Constraining probabilistic systems tends toward deterministic outputs.**

---

## Scope

### Target Documents
- Skill files (SKILL.md and related)
- Implementation plans
- Any markdown with instructions, guidelines, or structured info for AI agents

### Excluded Documents
- README files
- Documentation for human end-users
- Any human-consumption documents

---

## Transformation Approach

**Goal:** Convert human-readable markdown to machine-optimized markdown (not human-readable), like C++ → assembly. Remove everything that doesn't directly contribute to instruction execution, guideline adherence, or structured information parsing.

### Syntactic Transformations (structural/format-level)
- Strip filler phrases, polite language, conversational transitions, rhetorical questions
- Remove redundant restatements
- Collapse verbose examples into minimal forms
- Replace narrative sentences with bullets, tables, or key-value pairs
- Standardize formatting: consistent headings, uniform lists, explicit delimiters
- Remove decorative markdown (emphasis for tone, ellipses, exclamation marks)
- Compress whitespace, remove unnecessary blank lines
- Convert prose process descriptions into numbered steps
- Replace ambiguous references ("this", "that", "the above") with explicit identifiers

### Semantic Transformations (meaning/structure-level)
- Reorganize narrative flow into logical instruction hierarchies
- Extract implicit constraints/rules, make them explicit
- Convert conditional prose into explicit IF/THEN/ELSE structures
- Tag semantic roles: inputs, outputs, constraints, invariants, failure modes, edge cases
- Flatten nested explanations into direct assertions
- Replace examples with generalized patterns/schemas where possible
- Add priority/weight markers for instruction importance
- Resolve ambiguity: replace "might", "could", "should consider" with definitive directives or explicit optionality
- Group related constraints (even if scattered in source)
- Add cross-references between sections using explicit anchors/IDs

---

## Semantic Constraint Framework Integration

**CRITICAL:** The Semantic Constraint Framework already defines exactly what a "properly constrained" AI document looks like. The compiler's output **MUST** conform to this standard.

### 10 Universal Required Sections

Every compiled output **MUST** include all 10 universal sections:

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

Plus **type-specific sections** (Skills have Invocation Conditions/Forbidden Usage/Phase Separation; Plans have Data Model/Architecture/Key Operations/etc.)

### Declarative Language Rules

Compiled output **MUST** use declarative language, not suggestions:
- ✅ **Prefer:** `must`, `must not`, `required`, `forbidden`, `guaranteed`
- ❌ **Avoid:** `try to`, `ideally`, `if possible`, `approximately`

### Uncertainty Handling

If something is not decided in source:
- Do not guess
- Do not imply defaults
- Do not leave it implicit
- Instead write: "This is currently unspecified and must be decided before use."

### Negative Constraints

Compiled output **MUST** explicitly state what the agent must **not** do. Blocking unwanted behavior is more effective than only prescribing desired behavior.

### KERNEL Constraint Framework

All compiled artifacts must satisfy:

| Letter | Principle | Purpose |
|--------|-----------|---------|
| **K** | Keep it simple | Single, unambiguous primary goal — prevents scope creep |
| **E** | Easy to verify | Pre-defined success metrics and quality checkpoints |
| **R** | Reproducible results | Identical inputs must produce equivalent outputs |
| **N** | Narrow scope | Explicit domain and task limits — no general-purpose behavior |
| **E** | Explicit constraints | Hard boundaries on data sources, tools, and capabilities |
| **L** | Logical structure | Strict structural, token, or styling boundaries |

### Human vs AI Optimization Dial

The framework defines two modes — the compiler produces the AI-optimized end:

| Human-Optimized | AI-Optimized |
|-----------------|--------------|
| Explanatory prose | Minimal prose |
| Friendly narrative | Dense constraints |
| Justification and context | Explicit guarantees |
| Designed for onboarding | Zero ambiguity |

**Same meaning, different surface. The compiler controls the dial.**

### Impact on Compiler Pipeline

The compiler pipeline **MUST** include a **"Semantic Constraint Injection"** pass that:
- Ensures output includes all 10 universal sections
- Adds type-specific sections based on document type
- Converts all language to declarative form
- Adds negative constraints
- Declares uncertainty explicitly
- Validates against KERNEL framework

→ **Action:** Update pipeline architecture to include Semantic Constraint Injection as explicit optimization pass

---

## Output

### Format
- Fully machine-optimized (no human readability concerns)
- Format TBD via research — candidates: JSON, YAML, custom markup, optimized markdown
- **Size irrelevant** — larger output acceptable if it improves agent comprehension
- **No token limit enforcement** — users responsible for fitting within their agent's context window

### File Naming
- **Skills:** `SKILL.md` = compiled output, `SKILL.human.md` = source file
- **Other documents:** Same directory with suffix (e.g., `.compiled.md`)

### Traceability
- Compiled files include source file reference at top (easily skippable by AI agents)
- Include "last compiled" timestamp for recompilation tracking

---

## Source Control

- On-demand generation only (not automatic)
- Never edit compiled files — always regenerate from source
- Humans edit source files only
- No decompiler needed
- No incremental compilation — single top-to-bottom pass for consistency/determinism

---

## Invocation

- Manual only (intentional user action required)
- CLI command invokable
- Callable function within other skills/agents
- Processes single files or entire directories

---

## Architecture

### Compilation Pipeline

```
Source (.human.md)
  → Preprocessor (detect conflicts, resolve references, handle directives)
    → Halt if errors/ambiguities found, OR
    → Compiler (syntactic + semantic transformations, single pass)
      → Post-compile validation (agent-based verification)
        → Output (.md compiled)
```

### Preprocessor Phase

Modeled after C/C++ preprocessor. Handles macro expansion, file inclusion (like `#include`), conflict detection, verbose filler identification, and contextual reasoning compression.

**Temporary preprocessing document:** Agent MUST create a temporary document during preprocessing containing expanded macros, included files, and annotations for conflict detection/filler identification. This document:
- Aids the compilation phase
- Can be referenced if compilation fails (provides insights into issues and fixes)
- **MUST be deleted after successful compilation**

**Conflict detection:** If preprocessor finds conflicts, contradictions, or ambiguities → document **MUST NOT compile**, user **MUST be alerted** to resolve contradictions.

**File inclusion:** If referenced document found → include in compilation. If NOT found → **halt with clear error message**.

**Gatekeeper rule:** Preprocessor must complete **FULLY** without errors before compiler can run. Only clean, unambiguous sources proceed to compilation — crucial for maintaining integrity and predictability.

### Compiler Phase

Runs only if preprocessor completes successfully. Behaves like real compiler:
- Single pass, top-to-bottom (no incremental compilation)
- Deterministic output (converts probabilistic AI behavior to predictable results)
- Aggressive from the start (no gradual iteration)
- **HALTS entirely** on errors/ambiguities (no partial output)
- Clear error messages

### Post-Compile Validation

Agent-based verification ensures compiled output preserves all essential information from source.

**Validation strategy:**
- **Cheap functional equivalence test:** Original and compiled documents MUST produce same output when used as AI agent input
- **Separate verification skill:** Dedicated skill for in-depth, expensive analysis to ensure essential information preservation
- **On failure:** Compilation fails, appropriate errors shown to user, user must fix source and retry

---

## Bootstrap Strategy

1. Develop initial version with simpler transformation process
2. Once functional, use skill to compile **itself** (SKILL.human.md → SKILL.md)
3. Iterate with increasingly aggressive optimizations

Self-compilation enables gradual optimization increases while maintaining a working compiler at each stage — powerful evolution toward sophisticated transformations without breaking early functionality.

---

## Skill Characteristics

### Standalone
- Fully independent — no dependencies on other skills
- No external tools/libraries required
- **Agent and skill itself are the entire compilation engine**
- Can be used alongside other skills but doesn't integrate directly

### Documentation
- Before/after examples in **README.md** (not SKILL.md)
- Skill's own SKILL.md will be **compiled** following same pattern it produces

### Security
- No additional concerns beyond normal agent access
- If agent can read a document, it's eligible for compilation
- **User responsibility** — if someone leaks sensitive information, it's their problem

---

## Validation & Quality

### Post-Compile Verification
- **MUST run after every compilation**
- Agent-based verification
- **Test criterion:** Original and compiled produce same AI agent output
- **Action items:**
  - Design cheap functional equivalence test
  - Create separate skill for expensive analysis

### Success Metrics
- **Primary method:** Post-compile verification (pass/fail)
  - Verification fails → compile fails
  - Verification passes → compile passes
- User sees clear, understandable results
- If verification fails, user adjusts source and retries
- Requires testing against real agent tasks

### Format Consistency
- All compiled documents conform to standard optimal format
- Already-optimized documents recompiled for consistency
- Predictability prioritized over preserving existing optimization

**Analogy:** Optimized C++ doesn't run on CPU — assembly does. C++ is human-friendly way to write assembly. Compiled markdown is **"assembly code"** for AI agents, human-readable markdown is **"C++ code"** for humans.

### Error Handling
- No dry run/preview mode
- No diff reports
- Humans won't inspect compiled files (for AI agents only)
- **CRUCIAL:** Error reporting must be clear so users can identify and fix source issues
- Recompile at will

---

## Research & Open Questions

### Structured Elements (Q26)
What structured elements do AI agents find most useful? (XML tagging, JSON-LD, constraint-based formatting, priority markers)
→ **Action:** Research, document results

### Output Format
What format do AI agents parse most easily? (JSON, YAML, custom markup, optimized markdown)
→ **Action:** Research, document results

### Validation Methodology
Structural checks (good starting point, **MUST** be included) + functional testing against real agent tasks (ultimate effectiveness test)

### Distinguishing Filler vs. Context (Q25)
Preprocessor handles identification and separation with clear rules for verbose filler (remove) vs. contextual reasoning (compress and preserve)

### Compilation Pipeline Architecture

C++ compilers use a multi-stage pipeline (for good reason):

```
C++ source
   ↓
Preprocessing
   ↓
Parsing + semantic analysis
   ↓
Abstract Syntax Tree (AST)
   ↓
Intermediate Representation (IR)
   ↓
Optimization passes
   ↓
Lower-level IR / machine IR
   ↓
Assembly or object code
   ↓
Linker → executable or library
```

**Questions to investigate:**
- Should we adopt a similar multi-stage pipeline (parsing, AST, IR, optimization passes)?
- What would an "AST" look like for markdown documents?
- What would "intermediate representation" mean in our context?
- Should we have separate optimization passes (each targeting specific improvements) vs. single-pass aggressive compilation?
- Would multi-stage pipeline improve determinism, debuggability, and incremental optimization over time?
- Does the added complexity of multiple stages justify the benefits, or is single-pass sufficient for our use case?

→ **Action:** Research C/C++ compiler pipeline stages, evaluate applicability to markdown compilation, document findings

---

### Pipeline Architecture Analysis

**Do we replicate the C++ pipeline 1:1?**
**No.** The C++ pipeline exists because of specific problems: complex type systems, memory layout, cross-file symbol resolution, and CPU architecture targets. Markdown for AI agents has a completely different profile.

#### What to Drop
- **The Linker:** In C++, the linker exists because compilation units (`.cpp` files) are compiled separately and combined later. Our preprocessor already handles `#include`-style document resolution *before* compilation. There is no separate "object file" stage that needs linking. The output of our compiler is the final artifact.
- **Full Traditional AST:** A C++ AST tracks scopes, type hierarchies, template instantiations, symbol tables, and memory lifetimes. Markdown doesn't have any of that. A full AST is overkill.

#### What to Keep (But Simplify)
- **Document Structure Tree (DST)** instead of AST: A lightweight tree that captures:
  - Headings → section nodes
  - Lists → ordered/unordered block nodes
  - Tables → structured data nodes
  - Paragraphs → text block nodes
  - Semantic markers → constraint/instruction/fact tags (added during parsing)
  - *Benefit:* Gives optimization passes a predictable tree to traverse without the complexity of a language AST.
- **Intermediate Representation (IR):** Crucial to keep. The IR cleanly separates "what this means" from "how it's written".
  - Without an IR layer, transformation logic mixes with formatting logic, causing edge cases, broken formatting, and lost context.
  - *Benefit:* Enables swapping output formats later without rewriting transforms, running validation against the IR, and adding new optimization passes without breaking existing ones.

#### Recommended Streamlined 6-Stage Pipeline

```
Source (.human.md)
   ↓
[1] Preprocessor
   - Macro expansion, file inclusion, conflict detection
   - Outputs: Cleaned source + preprocessing annotations
   ↓
[2] Structural Parse (lightweight DST)
   - Converts markdown into a traversable tree of blocks
   ↓
[3] Semantic IR Extraction
   - Flattens tree into semantic units: instructions, constraints, facts, edge cases
   - Strips all markdown formatting syntax
   ↓
[4] Optimization Passes
   - Pass 1: Remove filler, compress context, resolve ambiguity
   - Pass 2: Add explicit tags, priority markers, IF/THEN/ELSE structures
   - Pass 3: Cross-reference linking, constraint grouping
   ↓
[5] Semantic Constraint Injection
   - Ensures all 10 universal sections present (Purpose, Scope, Inputs, Outputs, Constraints, Invariants, Failure Modes, Validation, Relationships, Guarantees)
   - Adds type-specific sections (Skills: Invocation/Forbidden/Phase Separation; Plans: Data Model/Architecture/etc.)
   - Converts all language to declarative form (must/must not, not try/ideally)
   - Adds negative constraints
   - Declares uncertainty explicitly
   - Validates against KERNEL framework
   ↓
[6] Code Generation
   - Emits final output in target format (JSON/YAML/Optimized MD)
   - Adds traceability header + timestamp
```

**Why This Works Better:**

| C++ Stage | Markdown Equivalent | Keep? | Why |
|-----------|---------------------|-------|-----|
| Preprocessor | Preprocessor | ✅ Yes | Handles includes, macros, early conflict detection |
| AST | Document Structure Tree | ⚡ Simplified | Gives passes a tree to traverse, no type/scope complexity |
| IR | Semantic IR | ✅ Yes | Strips formatting, isolates pure meaning/instructions |
| Optimization | Multi-pass optimizer | ✅ Yes | Each pass does one thing well (strip, structure, tag) |
| — | Semantic Constraint Injection | ✅ NEW | Ensures 10 universal sections, declarative language, KERNEL validation |
| Machine Code | Target Format | ✅ Yes | Final AI-readable output |
| Linker | None | ❌ Drop | Preprocessor already resolves cross-doc references |

**Conclusion:** Don't replicate C++ 1:1. Use a **6-stage pipeline** tailored for semantic document compilation. Keep the IR (it's the biggest architectural win), add Semantic Constraint Injection (ensures framework compliance), drop the linker, and simplify the AST to a Document Structure Tree. The key is keeping the stages that give **determinism, debuggability, and composability** while cutting the rest.

---

## Naming
- **Skill name:** `sas-semantic-compiler`
- Follows `sas-` prefix convention

---

*Last updated: 11 April 2026*
