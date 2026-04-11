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
**AGGRESSIVE compiler from the start. Go big or GO HOME!**

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
