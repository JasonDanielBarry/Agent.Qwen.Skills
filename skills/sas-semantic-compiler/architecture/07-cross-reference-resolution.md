# 07 — Cross-Reference Resolution

## From Key Takeaways Document

Documents that reference other documents **MUST** be compiled together.

- **What constitutes a reference:** Any Markdown link (`[text](path/to/file.md)`) or explicit path mention pointing to another `.md` file within the same repository
- **Implicit references** ("see the SKILL.md for details") are NOT resolved — only explicit file paths/links
- **Resolution depth:** Transitive (A→B→C compiles all three). Maximum depth: 5 levels to prevent runaway compilation
- **Compilation order:** Referenced documents compiled first (leaves), then referencing document (root)
- **Inclusion method:** Content inlined during preprocessor stage with clear boundaries: `<!-- begin included: {path} -->` ... `<!-- end included: {path} -->`
- **Circular reference detection:** Cycles (A→B→A) halt compilation with `PRE_002` error
- **Missing references:** Halt with clear error message

---

## From Compilation File Structure Document

When compiling documents that reference each other (e.g., A.human.md links to B.human.md):

1. **Detect references** during Stage 1 preprocessing
2. **Compile referenced documents first** (dependency order — leaves before roots)
3. **Read the referenced document's Stage 3 or Stage 5 output** from its `.compilation/` folder instead of re-parsing the raw source
4. **Inline or link** the referenced content per the key takeaways specification

This means compilation order matters for cross-referenced documents:

```
A.human.md → references → B.human.md → references → C.human.md

Compilation order:
1. C.human.md (leaf — no references out)
2. B.human.md (references C, which is now compiled)
3. A.human.md (references B, which is now compiled)
```

**Maximum reference depth:** 5 levels (from key takeaways document). Circular references halt compilation with `PRE_002` error.

---

*Last updated: 13 April 2026*
