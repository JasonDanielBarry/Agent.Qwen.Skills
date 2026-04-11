# Markdown Compiler Skill — Key Takeaways

## Overview

The `sas-semantic-compiler` skill will aggressively optimize markdown documents designed for AI agent consumption. The goal is to improve agent execution of instructions, adherence to guidelines, and parsing of structured information.

Human readability is explicitly NOT a concern for the compiled output.

---

## Core Decisions

### Target Documents
- **Skill files** (SKILL.md and related)
- **Implementation plans**
- Any markdown documents intended for AI agent input containing instructions, guidelines, or structured information

### Excluded Documents
- README files
- Documentation intended for human end-users
- Any human-consumption documents

### Transformation Approach
- **Aggressive optimization** combining both syntactic and semantic transformations
- Remove ALL human-friendly elements (verbose explanations, redundant context, narrative prose)
- Compress contextual reasoning while preserving functional semantics
- Remove or transform anything that doesn't directly contribute to:
  - Instruction execution
  - Guideline adherence
  - Structured information parsing

### Output Format
- Fully machine-optimized format (no human readability concerns)
- May use existing formats like JSON or YAML for compatibility
- Format to be determined through research on what AI agents parse most effectively

### File Naming Convention
- **For Skills:**
  - `SKILL.md` = compiled output (agent reads this)
  - `SKILL.human.md` = human-readable source file
- **For other documents:**
  - Same directory as source
  - Suffix to differentiate from source (e.g., `.compiled.md`)
  - Maintains traceability between source and compiled versions

### Source Control
- Compiled versions generated **on-demand only** (not automatic)
- No direct editing of compiled files — always regenerate from source
- Humans edit source files only
- No decompiler needed

### Invocation
- Manual invocation only (users must be intentional about when to compile)
- Invokable via CLI command
- Available as callable function within other skills or agents
- Can process **single files or entire directories**

---

## Validation & Quality

### Post-Compile Verification
- **MUST run after every compilation**
- Reviews compiled version against source file
- Ensures all essential information is preserved
- Checks for presence of key sections
- Verifies important details aren't lost
- Confirms overall information structure is maintained

### Success Metrics
- **Primary metric:** Agent comprehension accuracy
- **Definition of success:** Agent performs intended task correctly and efficiently using compiled version
- Requires testing compiled documents against real agent tasks

### Format Consistency
- All compiled documents must conform to a standard optimal format
- Even already-optimized documents will be recompiled to ensure consistency
- Predictability in agent parsing is prioritized over preserving existing optimization

---

## Architecture

### Standalone Skill
- Fully independent — no dependencies on other skills
- No external tools or libraries required
- Agent itself is the compilation engine
- Can be used alongside other skills but doesn't integrate directly

### Security
- No additional security concerns beyond normal agent access
- If an agent can read a document, it's eligible for compilation
- Users responsible for ensuring they're not exposing sensitive information

---

## Naming
- **Skill name:** `sas-semantic-compiler`
- Follows `sas-` prefix convention
- Clear, descriptive of purpose

---

## Open Questions Requiring Research

1. **What structured elements do AI agents find most useful?**
   - Need to investigate: XML tagging, JSON-LD, constraint-based formatting, priority markers

2. **What output format is most easily parsed by AI agents?**
   - JSON, YAML, custom markup, or optimized markdown?

3. **How to distinguish between verbose filler (safe to remove) vs contextual reasoning (should be compressed but preserved)?**

4. **How to implement robust validation methodology?**
   - Structural checks vs functional testing against agent tasks

---

*Last updated: 11 April 2026*
