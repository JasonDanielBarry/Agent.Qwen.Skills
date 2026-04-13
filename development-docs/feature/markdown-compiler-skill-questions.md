# Markdown Compiler Skill — Discussion Questions

## Scope & Target Documents

### 1. What types of documents should this skill target?
**Answer:**  
This skill should target markdown documents that are intended to be used as input for AI agents, particularly those that contain instructions, guidelines, or structured information.

For now we will focus our targets:
- Skill files
- Implementation plans

---

### 2. Should it work on any markdown file, or only documents following specific patterns (like SKILL.md files or Semantic Constraint Framework docs)?
**Answer:**  
No. Compiling documents MEANT for human consumption is NOT the goal.

The goal is to compile documents meant for AI agents to improve:
- Execution of instructions
- Adherence to guidelines
- Parsing of structured information

---

### 3. Are there any documents that should be excluded from compilation?
**Answer:**  
Documents that are meant for human consumption. This includes but is not limited to:
- README files
- Documentation intended for human end-users

---

## Transformation Type

### 4. Should the transformation be:
- Syntactic only (remove whitespace, compress formatting, strip filler phrases)?
- Semantic restructuring (reorganize content for agent parsing efficiency)?
- Both?

**Answer:**  
The goal here is to AGGRESSIVELY optimise markdown documents for AI agents. This means we want to do both syntactic and semantic transformations.

---

### 5. What human-friendly elements should be removed or compressed? (e.g., verbose explanations, redundant context, narrative prose)
**Answer:**  
All

---

### 6. What structured elements should be added or enhanced? (e.g., explicit tags, tables, key-value pairs, standardized section headers)
**Answer:**  
We must do research on what structured elements AI agents find most useful.

---

## Output Format

### 7. What should the output format be?
- Same markdown but denser/more concise?
- A different format entirely (JSON, YAML, custom markup)?
- Something else?

**Answer:**  
Whatever format is most easily parsed by AI agents. This may require research and experimentation to determine the optimal format.

Using an existing format like JSON or YAML would be beneficial for compatibility with existing tools and libraries.

---

### 8. Should the output maintain any human readability at all, or be fully optimized for machines?
**Answer:**  
NO! Fully optimized for machines. Human readability is NOT a concern for the output of this skill.

---

### 9. Where should compiled files be saved? Same directory as source, separate output folder, or alongside originals with a suffix?
**Answer:**
Same directory preferable with some kind of suffix to differentiate from source files. This allows for easy traceability between source and compiled versions while keeping them organized in the same location.

For Skills:
- The `SKILL.md` should be the compiled output
- `SKILL.human.md` should be the human readable source file

For non-Skill documents:
- Source: `{name}.md` (unchanged)
- Compiled: `{name}.compiled.md`
- Example: `design-doc.md` → `design-doc.compiled.md`

**Naming rules:**
- Always same directory as source
- Skills use the special `SKILL.human.md` → `SKILL.md` mapping
- All other documents append `.compiled` before the `.md` extension
- If a `.compiled.md` file already exists, it is overwritten (no versioning, no suffix incrementing)

---

## Reversibility & Maintenance

### 10. Do you need a "decompiler" to convert AI-optimized output back to human-readable format for editing?
**Answer:**  
No. The human-readable source file should be the one that is edited and maintained by humans.

The compiled version is ONLY EVER generated from the source and should not be edited directly.

---

### 11. How will you handle version control? Compile on-demand, or maintain compiled versions alongside source files?
**Answer:**  
The compiled versions should be generated on-demand from the source files.

This ensures that the compiled version is always up-to-date with the latest changes in the source file.

This reduces the risk of discrepancies between source and compiled versions in version control.

---

### 12. If source documents are updated, should the skill recompile automatically or require manual invocation?
**Answer:**  
Manual. Users must be intentional about when to compile. Automatic recompilation could lead to unintended consequences if users are not aware of the changes being made to the compiled version.

---

## Validation & Quality

### 13. How would you verify the "compiled" version preserves all essential information from the original?
**Answer:**  
A post-compile-routine MUST run after compilation for reviewing the compiled version against the source file to ensure that all essential information is preserved.

This could involve checking for the presence of key sections, verifying that important details are not lost, and ensuring that the overall structure of the information is maintained.

---

### 14. Are there any metrics or benchmarks you'd want to measure? (e.g., token reduction percentage, agent comprehension accuracy)
**Answer:**  
Agent comprehension accuracy is the most important metric.

The ultimate goal of this skill is to improve how well AI agents can understand and execute instructions from markdown documents.

Therefore, measuring the impact of the compiled version on agent performance is crucial.

---

### 15. What constitutes a "successful" compilation? How would you test it?
**Answer:**  
The agent performs the intended task correctly and efficiently using the compiled version of the document.

---

## Naming & Invocation

### 16. What should the skill be named? (e.g., `sas-ai-optimizer`, `sas-md-compiler`, `sas-semantic-compiler`)
**Answer:**  
`sas-semantic-compiler`

---

### 17. How should users invoke this skill? CLI command, conversational trigger, or both?
**Answer:**  
Like any other agent skill. It should be invokable via CLI command for manual use and also be available as a function that can be called within other skills or agents for automated workflows.

---

### 18. Should it process single files, entire directories, or both?
**Answer:**  
Both. Users should have the flexibility to compile individual files or entire directories, depending on their needs.

---

## Integration & Dependencies

### 19. Should this skill integrate with other existing skills (like the git commit skill) to automate workflows?
**Answer:**  
No. This is a fully STANDALONE/INDEPENDENT skill focused solely on compiling markdown documents for AI agents.

While it can be used in conjunction with other skills, it does not need to have direct integrations or dependencies on them.

---

### 20. Are there any external tools or libraries this skill would need?
**Answer:**  
No. The agent is responsible for running the skill same as any other skill. The skill itself should not have external dependencies that could complicate its use or maintenance.

---

### 21. Should compiled files reference their source files (and vice versa) for traceability?
**Answer:**
Yes. The compiled files should include a reference to their source files, such as a comment at the top indicating the original file name and location.

This helps maintain traceability and allows users to easily identify the relationship between source and compiled versions.

But that is purely for traceability and MUST NOT interfere with the agents parsing of the compiled version.

The reference should be formatted in a way that it can be easily ignored or skipped by AI agents during processing.

**Implementation detail:**
- Format: `<!-- compiled from: {relative_source_path} | {ISO 8601 timestamp} -->`
- Placed as the very first line of the compiled file
- HTML comment format ensures AI agents skip it naturally (comments are not rendered content)
- Timestamp format: `YYYY-MM-DDTHH:mm:ssZ` (UTC)
- Example: `<!-- compiled from: skills/sas-example/SKILL.human.md | 2026-04-13T14:30:00Z -->`

---

## Edge Cases & Limitations

### 22. How should the skill handle code blocks, tables, images, or other non-text markdown elements?
**Answer:**  
This skill is focused on improving agents ability to:
- Execute instructions
- Adhere to guidelines
- Parse structured information

Anything in a markdown that does not directly contribute to those goals can be removed or transformed in a way that optimizes for machine parsing.

---

### 23. What happens if a document is already well-optimized? Should the skill detect this and skip compilation?
**Answer:**  
No. We want compiled document to conform to a standard format that we know is optimal for AI agents.

Even if a document is already well-optimized, it may not conform to the specific structure and formatting that our skill produces.

Format is therefore important for consistency and predictability in how AI agents will parse and understand the compiled documents.

---

### 24. Are there any security or privacy concerns when processing sensitive documents?
**Answer:**  
No. If an agent can read a document it is fair game.

Users should be aware of the content they are compiling and ensure that they are not inadvertently exposing sensitive information to AI agents.

---

## Additional Questions

### 25. How should the skill distinguish between "verbose filler" (safe to remove) and "contextual reasoning" (should be compressed but preserved)?
**Answer:**  
Use an established technique: **preprocess the document**.

The C/C++ preprocessor is a good example of this. Before the actual compilation step, the preprocessor handles tasks like macro expansion, file inclusion, and conditional compilation.

This allows developers to write code that is more human-friendly while still producing an output that is optimized for the compiler.

The preprocessing step can be used to:
- Identify and handle verbose filler content
- Ensure that essential contextual information is preserved in a compressed format for the final compilation step
- Perform other useful tasks before compilation is done

---

### 26. What research or experimentation will you conduct to determine the most effective structured elements for AI agents (e.g., XML tagging, JSON-LD, constraint-based formatting, priority markers)?
**Answer:**  
The AI agent itself should conduct this research. It has access to all data and research on this topic.

The agent can:
- Analyze existing documents
- Review agent interaction patterns
- Examine performance metrics
- Identify which structured elements are most effective for improving agent comprehension and execution

---

### 27. Should the compiled output include metadata about the compilation process? (e.g., timestamp, source file hash, compilation version, agent model used)
**Answer:**  
No. If we want extra features we can add them later.

Right now the task is "create the compiler skill". We should focus on that and not add extra features until we have a working version of the core functionality.

---

### 28. How should the skill handle conflicting or contradictory instructions in the source document? Should it flag them, preserve them as-is, or attempt to resolve them?
**Answer:**  
The preprocessor should be used to identify and flag conflicting or contradictory instructions in the source document.

If the preprocessor detects such conflicts, the document **MUST NOT compile**.

The user **MUST be alerted** to the contradictions so that they can be resolved.

---

### 29. What should happen if the compilation process encounters errors or ambiguities in the source document? Should it fail gracefully, produce partial output, or halt entirely?
**Answer:**  
**Halt entirely.**

If the compilation process encounters errors or ambiguities in the source document, it **MUST halt** and provide a clear error message indicating the nature of the issue.

AI agents are probabilistic by nature. We want to ensure documents to be compiled convert probabilistic behaviour to deterministic outcomes.

If there are ambiguities or errors in the source document, it undermines the goal of producing a clear and optimized output for AI agents.

---

### 30. Should the skill provide a summary or diff report showing what was changed/removed during compilation? This could help users understand the transformation.
**Answer:**  
No. The compiled version **MUST** be the only version that is used by AI agents. The human-readable source file is the one that should be maintained and edited by humans.

---

### 31. How will you test "agent comprehension accuracy"? Will you create a benchmark suite of tasks, use real-world usage, or both?
**Answer:**  
The original and compiled documents **MUST** produce the same output when used as input for an AI agent.

---

### 32. Should the skill support incremental compilation? (e.g., only recompile sections of a document that have changed since last compilation)
**Answer:**  
No. The compilation process should be straightforward and deterministic.

Incremental compilation adds complexity and potential for errors if not implemented perfectly.

Compilation of a single document **MUST** be done from top to bottom in one pass to ensure consistency and reliability of the output.

---

### 33. What is the minimum viable version of this skill? Should you start with a simpler transformation and iterate toward aggressive optimization, or build the full aggressive compiler from the start?
**Answer:**
**AGGRESSIVE compiler from the start — but bootstrapped pragmatically.**

Reconciled with the Bootstrap Strategy (takeaways doc):
- **Design aggressively:** The pipeline architecture, transformation rules, and output format are all designed for the full 6-stage aggressive compiler from day one. No half-measures in the design.
- **Implement pragmatically:** Build a working v1 that implements the full pipeline but with simpler transformation rules in Stage 4 (conservative strip/compress). Once the pipeline is functional and validation passes, use the compiler on its own SKILL.human.md to produce v2. Then iterate with increasingly aggressive Stage 4 passes.
- **The key insight:** "Aggressive from the start" refers to the *architecture and ambition* — the full 6-stage pipeline, all validation, all constraint injection. "Bootstrap" refers to the *transformation aggressiveness* within Stage 4, which ramps up through self-compilation.

This is NOT a contradiction — it's two dimensions: the pipeline is fully built (aggressive), but the transformation rules mature through iteration (bootstrap).

---

### 34. Should compiled files include a "last compiled" indicator or versioning scheme to help users track when they were last updated relative to source changes?
**Answer:**  
Yes. Then you can compare the timestamp of the original document with the compiled version to see if it is up to date or if it needs to be recompiled.

---

### 35. How should the skill handle nested or cross-referenced documents? (e.g., a SKILL.md that references another SKILL.md, or a plan that references framework documents)
**Answer:**
A document that references another document **MUST** be compiled **WITH** the reference document.

An example: A `.cpp` file that includes a `.h` file. The `.cpp` file cannot be compiled without the `.h` file.

Document references **MUST** be processed during preprocessing. If a document references another document, the preprocessor **MUST** attempt to locate the referenced document.

- If the referenced document is found, it should be included in the compilation process to ensure that all relevant information is available for the final output.
- If the referenced document is **NOT** found, the compilation process **MUST halt** and provide a clear error message indicating that the reference document is missing.

**Implementation detail:**
- **What constitutes a reference:** Any Markdown link (`[text](path/to/file.md)`) or explicit path mention (`see file.md`, `refer to path/file.md`) pointing to another `.md` file within the same repository
- **Implicit references** ("see the SKILL.md for details", "as defined in the framework") are NOT resolved — only explicit file paths/links are processed
- **Resolution depth:** Transitive — if A references B and B references C, all three are compiled together. Maximum depth: 5 levels (prevent infinite recursion / runaway compilation)
- **Compilation order:** Referenced documents are compiled first (leaves), then the referencing document (root). This ensures all included content is already optimized before the parent document is processed
- **Inclusion method:** Referenced document content is inlined during Stage 1 (Preprocessor) with a clear section boundary: `<!-- begin included: {path} -->` ... `<!-- end included: {path} -->`
- **Circular reference detection:** If the preprocessor detects A→B→A or any cycle, it halts with `PRE_002` error

---

### 36. Should there be a "dry run" or preview mode that shows what the compiled output would look like without actually writing the file?
**Answer:**  
No. The compiled output may be large and complex, and a dry run or preview mode may not be practical or useful for users.

Inspecting the compiled output is best done by reviewing the actual compiled file, which will provide a more accurate representation of the final result.

Recompilation can be rerun at will, so users can easily generate the compiled version when they are ready to review it.

---

### 37. What happens if the compiled output is larger than the source (e.g., due to added structural markup)? Should the skill warn the user, or is this acceptable if it improves agent comprehension?
**Answer:**  
**Goal: AI agent comprehension. We DO NOT care about the size of the compiled output.**

If the compiled output is larger than the source but improves agent comprehension, that is acceptable.

---

### 38. Should the skill enforce a maximum token limit for compiled output to ensure it fits within agent context windows?
**Answer:**  
Users are responsible for ensuring that the compiled output fits within the context window of the AI agents they intend to use it with.

The compiler **WILL** compile whatever you give it.

If the user gives it a document that results in a compiled output that exceeds the token limit of your target AI agent it is **THEIR** problem.

Eg. if you want to compile a 100000 line C++ source file you can do that. But that is terrible software design practice.

Users should be encouraged to write concise and well-structured source documents to ensure that the compiled output is manageable and effective for AI agents.

---

### 39. How should the post-compile validation routine work? Should it be automated (scripted comparison), manual (human review), or agent-based (AI verifies completeness)?
**Answer:**  
**Agent-based.**

An AI agent can be used to verify that the compiled output preserves all essential information from the original source document.

---

### 40. Should the skill include examples in its SKILL.md showing before/after transformations so users understand what to expect?
**Answer:**
This can be documented in the skill **README.md**.

The skill that executes the compilation will itself be **COMPILED**.

Like the C compiler was originally written in assembly language. Once the compiler existed, it was rewritten in C.

The same approach will be taken here:

1. The initial version of the skill can be developed with a simple transformation process
2. Once it is functional, it will be used to compile the skill itself
3. This allows for more aggressive optimizations and transformations in subsequent iterations

---

### 41. Should the compilation pipeline replicate the C/C++ multi-stage architecture (preprocessing → AST → IR → optimization passes → code generation → linker)?
**Answer:**
**No — not 1:1.** The C++ pipeline exists to solve problems markdown doesn't have (complex type systems, memory layout, cross-file symbol resolution). Use a **6-stage streamlined pipeline** instead.

#### What to Drop
- **The Linker:** The preprocessor already handles `#include`-style document resolution before compilation. There is no separate "object file" stage.
- **Full Traditional AST:** Markdown doesn't have scopes, type hierarchies, template instantiations, or memory lifetimes. Overkill.

#### What to Keep (But Simplify)
- **Document Structure Tree (DST)** instead of AST: A lightweight tree capturing headings, lists, tables, paragraphs, and semantic markers.
- **Intermediate Representation (IR):** Crucial — separates "what this means" from "how it's written". Enables format swapping, IR validation, and composable optimization passes.

#### Recommended 6-Stage Pipeline

```
Source (.human.md)
   ↓
[1] Preprocessor — macro expansion, file inclusion, conflict detection
   ↓
[2] Structural Parse (lightweight DST) — markdown → traversable tree of blocks
   ↓
[3] Semantic IR Extraction — flatten tree into semantic units, strip formatting
   ↓
[4] Optimization Passes — Pass 1: strip/compress, Pass 2: tag/structure, Pass 3: cross-reference/group
   ↓
[5] Semantic Constraint Injection — 10 universal sections, declarative language, KERNEL validation
   ↓
[6] Code Generation — emit target format, add traceability header + timestamp
```

**Conclusion:** Keep the stages that give determinism, debuggability, and composability. Cut the rest.

⚠️ **Needs detailed stage specifications** — this answer works as a decision record but is insufficient for implementation. The following gaps must be filled before coding the compiler:

| Gap | What's needed |
|-----|--------------|
| DST specification | Node types, attributes, traversal interface for the Document Structure Tree |
| IR specification | Concrete data structure for "semantic units" — how instructions, constraints, facts map to IR nodes |
| Per-stage I/O contracts | Explicit inputs/outputs — how stage N's output becomes stage N+1's input |
| Optimization pass details | Concrete transformation rules, not just labels ("strip/compress", "tag/structure", etc.) |
| Semantic Constraint Injection mapping | How are the 10 universal sections injected? Template fill? Structural reorganization? What if source lacks a section? |
| Code generation mechanics | IR → output format process. Template-based? Rule-based? How does format choice affect generation? |
| Per-stage error handling | What does "halt" look like at each stage? What error information gets surfaced? |

---

## Open Research Items — RESOLVED

*All research items have been answered and all architecture specifications have been defined. No open items remain.*

### R1. Structured Elements for AI Agents (relates to Q6, Q26) — ✅ RESOLVED
**Answer:** XML-like tags for section boundaries, priority markers `[P0]`/`[P1]`/`[P2]`, IF/THEN/ELSE blocks, numbered lists, key-value pairs, negative constraints, cross-reference anchors. See A2 (IR Specification) for complete structured element definitions.

### R2. Output Format (relates to Q7) — ✅ RESOLVED
**Answer:** Optimized Markdown with XML-like tags. No JSON/YAML conversion. Non-Skill documents use `.compiled.md` suffix. See R1 and A6 (Code Generation Mechanics).

### R3. Validation Methodology (relates to Q13, Q14, Q15, Q31, Q39) — ✅ RESOLVED
**Answer:** Two-tier validation: Tier 1 (cheap structural check — section presence, declarative language, KERNEL compliance), Tier 2 (functional equivalence test — source vs. compiled produce same agent output, 90%+ threshold across 5+ tasks). Separate expensive verification skill for on-demand deep audits.

### R4. Filler vs. Context Distinction Rules (relates to Q25) — ✅ RESOLVED
**Answer:** 8-category classification table (verbose filler → remove, redundant restatement → remove, justification → compress, hedging → resolve, contextual reasoning → compress+preserve, examples → generalize, instructions → preserve+restructure, metadata → compress). Decision heuristic: "what to do?" → preserve, "why written?" → compress, "social lubricant" → remove.

---

## Architecture Specifications

*These specifications define the 6-stage pipeline in implementation-level detail. They resolve the 7 architecture gaps flagged in the key takeaways document.*

### A1. Document Structure Tree (DST) Specification

The DST is a lightweight tree representation of the source markdown's block-level structure. Each node has:

```
DSTNode {
  type: "heading" | "paragraph" | "list" | "ordered_list" | "table" | "code_block" | "blockquote" | "thematic_break" | "link" | "image" | "html"
  level: int?              // For headings only (1-6)
  content: string          // Raw text/markdown of the block
  children: DSTNode[]      // For lists: items; for headings: following blocks until next heading of same/higher level
  metadata: {
    source_line: int       // Original line number for error reporting
    section_path: string   // Full heading path (e.g., "Architecture > Compilation Pipeline")
    semantic_role: string? // Added during Stage 3: "instruction" | "constraint" | "fact" | "example" | "rationale" | "edge_case" | "invariant" | "failure_mode" | "guarantee" | "input" | "output" | "relationship" | "validation" | "metadata" | "filler"
  }
}
```

**Node type handling:**
- `heading` → section nodes, drives tree hierarchy
- `paragraph` → text block nodes
- `list` / `ordered_list` → list nodes with children as items
- `table` → structured data node (preserved as markdown table)
- `code_block` → preserved verbatim (language tag if present)
- `blockquote` → treated as nested content
- `thematic_break` (`---`) → section separator, discarded in Stage 3
- `link` → preserved with URL extraction for cross-reference resolution
- `image` → preserved with alt text and URL
- `html` → preserved verbatim (may contain XML-like tags)

**Traversal interface:** Depth-first, pre-order. Parent pointer available for section context. Section boundaries determined by heading levels.

### A2. Semantic IR Specification

The IR flattens the DST into a linear sequence of semantic units with all markdown formatting stripped. Each IR unit:

```
IRUnit {
  id: string                // Unique identifier (e.g., "sec-purpose-001")
  type: "instruction" | "constraint" | "fact" | "example" | "rationale" | "edge_case" | "invariant" | "failure_mode" | "guarantee" | "input" | "output" | "relationship" | "validation" | "metadata" | "filler"
  section: string           // Target section for constraint injection (e.g., "Purpose", "Constraints")
  content: string           // Cleaned text, no markdown syntax
  priority: "P0" | "P1" | "P2"  // P0 = must obey, P1 = important, P2 = nice-to-have
  conditions: Condition[]   // IF/THEN/ELSE conditions that gate this unit
  references: string[]      // IDs of other IRUnits this unit references
  negation: boolean         // True if this is a negative constraint (what NOT to do)
}

Condition {
  predicate: string         // The condition to check
  then: IRUnit[]            // Units to include if true
  else: IRUnit[]            // Units to include if false (may be empty)
}
```

**Semantic role assignment (Stage 3):** Determined by keyword heuristics + structural context:
- "must", "must not", "required", "forbidden" → `constraint`
- "do", "run", "execute", "perform" → `instruction`
- "is", "are", "defines" → `fact`
- "for example", "e.g.", code examples → `example`
- "because", "since", "rationale" → `rationale`
- "if", "when", "unless", "edge case" → `edge_case`
- "always", "invariant", "holds" → `invariant`
- "fail", "error", "fallback" → `failure_mode`
- "guarantee", "ensures", "commits" → `guarantee`
- "input", "source", "precondition" → `input`
- "output", "produces", "result" → `output`
- "depends", "relates", "requires" → `relationship`
- "verify", "validate", "test", "check" → `validation`
- "version", "author", "date" → `metadata`
- Everything else → classified by R4 filler rules

### A3. Per-Stage I/O Contracts

| Stage | Input | Output | Format |
|-------|-------|--------|--------|
| [1] Preprocessor | Source `.human.md` file path | Preprocessed source string + annotation map | `(string, Map<string, Annotation[]>)` |
| [2] Structural Parse | Preprocessed source string | DST (root node with children) | `DSTNode` tree |
| [3] Semantic IR Extraction | DST | Flat list of IRUnits | `IRUnit[]` |
| [4] Optimization Passes | IRUnits | Transformed IRUnits (filtered, tagged, linked) | `IRUnit[]` |
| [5] Semantic Constraint Injection | IRUnits | Augmented IRUnits with all 10 sections filled | `IRUnit[]` |
| [6] Code Generation | Augmented IRUnits | Final `.compiled.md` file | `string` → written to disk |

**Handoff mechanism:** Each stage receives the output of the previous stage as its sole input. No stage reads from disk directly (except Stage 1). No stage writes to disk directly (except Stage 6). Errors propagate up the chain — any stage failure aborts the pipeline and surfaces the error.

### A4. Optimization Pass Details

**Pass 1 — Strip & Compress:**
- Remove all IRUnits with `type: "filler"` (per R4 rules)
- Compress `type: "rationale"` units to single-line `[rationale: X]` format
- Compress `type: "metadata"` units to single-line header format
- Merge adjacent IRUnits of same type in same section into single unit
- Strip decorative formatting from content (emphasis for tone, etc.)

**Pass 2 — Tag & Structure:**
- Assign explicit `id` to every IRUnit (format: `sec-{section}-{index}`)
- Add `priority` markers: P0 for constraints/invariants/negative constraints, P1 for instructions/failure modes, P2 for examples/relationships
- Convert conditional prose into explicit `Condition` objects on IRUnits
- Add `negation: true` to units that express negative constraints
- Wrap examples in generalized schema patterns

**Pass 3 — Cross-Reference & Group:**
- Resolve all `references` by matching explicit anchors/IDs to IRUnit IDs
- Group related IRUnits by semantic affinity (constraints with their edge cases, instructions with their failure modes)
- Add cross-reference links between sections (e.g., a constraint that references an invariant)
- Deduplicate IRUnits with identical content in the same section

### A5. Semantic Constraint Injection Mapping

**Injection method:** Structural reorganization + template fill.

**Process:**
1. Group existing IRUnits by their `section` field into a `Map<string, IRUnit[]>`
2. For each of the 10 universal sections (Purpose, Scope, Inputs, Outputs, Constraints, Invariants, Failure Modes, Validation, Relationships, Guarantees):
   - If IRUnits exist for this section → use them, reorganize into canonical order
   - If no IRUnits exist → inject an explicit placeholder: `<section_name> — This is currently unspecified and must be decided before use.`
3. Add type-specific sections based on document type detection:
   - Skill detection (has `name:` + `description:` in frontmatter) → add Invocation Conditions, Forbidden Usage, Phase Separation
   - Plan detection (has timeline/milestone language) → add Data Model, Architecture, Key Operations
4. Convert ALL IRUnit content to declarative language (apply R4 hedging resolution)
5. Ensure at least one negative constraint exists — if none detected, inject: "Do not guess or imply defaults for unspecified behavior."
6. Run KERNEL validation checklist against the section map

### A6. Code Generation Mechanics

**Method:** Template-based rendering from augmented IR.

**Process:**
1. Start with traceability header: `<!-- compiled from: {source_path} | {timestamp} -->`
2. For each of the 10 universal sections (in canonical order):
   - Emit `## {Section Name}`
   - Emit `<{section_tag}>` XML-like wrapper
   - For each IRUnit in the section:
     - Emit priority marker if P0: `[P0] `
     - Emit content as bullet point (for instructions/constraints) or prose (for facts/rationale)
     - If `conditions` present: emit `IF {predicate} THEN ... ELSE ...`
     - If `negation: true`: emit with explicit negative framing
   - Emit `</{section_tag}>`
3. Emit type-specific sections the same way
4. Write to `{output_path}`

**Format choice impact:** Since output is Markdown with XML tags (R1/R2 decision), the generator emits markdown syntax (headings, bullets, tables) wrapped in XML-like tags for section-level strictness. No JSON/YAML serialization needed.

### A7. Per-Stage Error Handling

**Error model:** Every stage returns either `Success(output)` or `Error(stage_name, code, message, context)`.

**Error codes by stage:**

| Stage | Error Code | Meaning |
|-------|-----------|---------|
| [1] Preprocessor | `PRE_001` | Referenced file not found |
| | `PRE_002` | Conflicting/contradictory instructions detected |
| | `PRE_003` | Ambiguous reference (multiple possible targets) |
| | `PRE_004` | Invalid directive syntax |
| [2] Structural Parse | `DST_001` | Malformed markdown (unclosed block) |
| | `DST_002` | Empty document (no parseable content) |
| [3] Semantic IR Extraction | `IR_001` | Unable to classify content into any semantic role |
| | `IR_002` | Circular reference detected |
| [4] Optimization | `OPT_001` | All content classified as filler (nothing to preserve) |
| | `OPT_002` | Priority conflict (two P0 constraints contradict) |
| [5] Constraint Injection | `SCI_001` | Too many unspecified sections (>3 universal sections empty) |
| | `SCI_002` | KERNEL validation failed (specify which principle) |
| [6] Code Generation | `GEN_001` | Output path not writable |
| | `GEN_002` | Template rendering failure |

**Error propagation:**
- Any error → pipeline halts immediately
- Error message displayed to user with: stage name, error code, human-readable description, and source location (line number from DST metadata)
- Temporary preprocessing document (if created) is cleaned up on error
- No partial output is written to disk
- User must fix source and retry
