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
- `SKILL.<Human-Readable-Extension>.md` should be the human readable source file (e.g., `SKILL.md` for compiled, `SKILL.human.md` for source)

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
**Your answer:**  

---

### 26. What research or experimentation will you conduct to determine the most effective structured elements for AI agents (e.g., XML tagging, JSON-LD, constraint-based formatting, priority markers)?
**Your answer:**  

---

### 27. Should the compiled output include metadata about the compilation process? (e.g., timestamp, source file hash, compilation version, agent model used)
**Your answer:**  

---

### 28. How should the skill handle conflicting or contradictory instructions in the source document? Should it flag them, preserve them as-is, or attempt to resolve them?
**Your answer:**  

---

### 29. What should happen if the compilation process encounters errors or ambiguities in the source document? Should it fail gracefully, produce partial output, or halt entirely?
**Your answer:**  

---

### 30. Should the skill provide a summary or diff report showing what was changed/removed during compilation? This could help users understand the transformation.
**Your answer:**  

---

### 31. How will you test "agent comprehension accuracy"? Will you create a benchmark suite of tasks, use real-world usage, or both?
**Your answer:**  

---

### 32. Should the skill support incremental compilation? (e.g., only recompile sections of a document that have changed since last compilation)
**Your answer:**  

---

### 33. What is the minimum viable version of this skill? Should you start with a simpler transformation and iterate toward aggressive optimization, or build the full aggressive compiler from the start?
**Your answer:**  

---

### 34. Should compiled files include a "last compiled" indicator or versioning scheme to help users track when they were last updated relative to source changes?
**Your answer:**  

---

### 35. How should the skill handle nested or cross-referenced documents? (e.g., a SKILL.md that references another SKILL.md, or a plan that references framework documents)
**Your answer:**  

---

### 36. Should there be a "dry run" or preview mode that shows what the compiled output would look like without actually writing the file?
**Your answer:**  

---

### 37. What happens if the compiled output is larger than the source (e.g., due to added structural markup)? Should the skill warn the user, or is this acceptable if it improves agent comprehension?
**Your answer:**  

---

### 38. Should the skill enforce a maximum token limit for compiled output to ensure it fits within agent context windows?
**Your answer:**  

---

### 39. How should the post-compile validation routine work? Should it be automated (scripted comparison), manual (human review), or agent-based (AI verifies completeness)?
**Your answer:**  

---

### 40. Should the skill include examples in its SKILL.md showing before/after transformations so users understand what to expect?
**Your answer:**