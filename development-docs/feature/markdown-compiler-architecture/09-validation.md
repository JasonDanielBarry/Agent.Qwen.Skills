# 09 — Validation

## Post-Compile Validation

Agent-based verification ensures compiled output preserves all essential information from source. Runs after Stage 6 completes.

**Two-tier validation:**

### Tier 1 — Cheap Structural Check (runs automatically, fast, deterministic)

- Verify all 10 universal sections present with XML-like tags
- Verify all type-specific sections present (based on document type)
- Verify declarative language used (no "try to", "ideally", "if possible")
- Verify negative constraints exist
- Verify uncertainty explicitly declared (not left implicit)
- Verify KERNEL framework compliance
- Fail = compilation fails with specific missing-element errors

### Tier 2 — Functional Equivalence Test (runs automatically, agent-based, pass/fail)

- Give an AI agent the **source document** and ask it to perform a representative task from the document's domain
- Give a **separate** AI agent the **compiled document** and ask it the **identical** task
- Compare outputs: if both agents produce semantically equivalent results (same instructions followed, same constraints respected, same output structure), the test passes
- "Semantically equivalent" means: same actions taken, same constraints obeyed, same output format — not exact string match
- Threshold: 90%+ task equivalence across a benchmark suite of 5+ representative tasks
- Fail = compilation fails, user shown which tasks diverged and why

### Separate Verification Skill (expensive, on-demand)

- Dedicated skill for deep analysis: full content coverage audit, constraint sufficiency check, conflict detection, edge case coverage
- Not part of the normal compilation pipeline — invoked manually for quality audits

---

## Success Metrics

- **Primary method:** Post-compile verification (pass/fail)
  - Verification fails → compile fails
  - Verification passes → compile passes
- User sees clear, understandable results
- If verification fails, user adjusts source and retries
- Requires testing against real agent tasks

---

## Format Consistency

- All compiled documents conform to standard optimal format
- Already-optimized documents recompiled for consistency
- Predictability prioritized over preserving existing optimization

**Analogy:** Optimized C++ doesn't run on CPU — assembly does. C++ is human-friendly way to write assembly. Compiled markdown is **"assembly code"** for AI agents, human-readable markdown is **"C++ code"** for humans.

---

## Error Handling

- No dry run/preview mode
- No diff reports
- Humans won't inspect compiled files (for AI agents only)
- **CRUCIAL:** Error reporting must be clear so users can identify and fix source issues
- Recompile at will

---

*Last updated: 13 April 2026*
