# Markdown Compiler Architecture

Architecture and design specification for the `sas-semantic-compiler` — a skill that aggressively optimizes markdown documents for AI agent consumption.

## Table of Contents

| Document | Content |
|----------|---------|
| [01-overview.md](./01-overview.md) | Compiler goal, scope (target/excluded documents), C/C++ compiler model analogy |
| [02-transformation-rules.md](./02-transformation-rules.md) | Syntactic transformations, semantic transformations, 8-category filler classification, decision heuristic |
| [03-semantic-constraints.md](./03-semantic-constraints.md) | 10 universal required sections, declarative language rules, KERNEL framework, uncertainty handling, negative constraints, Human vs AI optimization dial |
| [04-pipeline-architecture.md](./04-pipeline-architecture.md) | 6-stage pipeline design, what to keep/drop, pipeline diagram, C++ comparison table, all 6 stage specifications, per-stage I/O contracts, per-stage error codes and handling, preprocessor phase invariants, compiler phase characteristics |
| [05-compilation-file-structure.md](./05-compilation-file-structure.md) | Persistent `.DocName.compilation/` folder structure, file JSON schemas for all 6 stages, naming conventions, collision handling, source file stem derivation |
| [06-execution-workflow.md](./06-execution-workflow.md) | Context window load→process→write→clear cycle, rationale, clarification on hallucinations vs context contamination/attention dilution, cleanup/lifecycle management, git configuration, disk space considerations, error diagnosis workflow with example |
| [07-cross-reference-resolution.md](./07-cross-reference-resolution.md) | Reference detection, implicit vs explicit references, transitive resolution depth, inclusion method, circular reference detection, compilation ordering with example, cross-document resolution using `.compilation/` folders, maximum reference depth |
| [08-output-format.md](./08-output-format.md) | Format decision research (Markdown vs XML vs JSON vs YAML), structured elements in compiled output, file naming conventions (Skills and general documents), traceability header specification, size and token limit policy |
| [09-validation.md](./09-validation.md) | Two-tier validation (Tier 1 cheap structural check, Tier 2 functional equivalence test), separate verification skill, success metrics, format consistency, post-compile verification rules, error handling behavior |
| [10-bootstrap-strategy.md](./10-bootstrap-strategy.md) | Phase 1–4 progression (MVP → Full Pipeline → Self-Compilation → Aggressive Optimization), key principle |
| [11-operational-concerns.md](./11-operational-concerns.md) | Source control rules, invocation methods, skill characteristics (standalone/docs/security), skill naming convention |

## Document Organization

This folder supersedes two source documents that previously existed separately:
- `markdown-compiler-skill-key-takeaways.md` (the original key takeaways document)
- `compilation-stage-file-folder-structure.md` (the persistent file structure document)

**What the key takeaways covered:**
- Transformation approach (syntactic + semantic)
- Filler classification rules
- 10 universal required sections
- KERNEL framework
- Naming conventions for source/output files
- Pipeline architecture (6 stages)
- Bootstrap strategy
- Validation requirements

**What the file structure document covered:**
- Persistent folder structure for each stage
- File formats and schemas
- Context window workflow
- Cleanup and lifecycle management
- Cross-document reference resolution using folders
- Error diagnosis using compilation folders

All content from both documents is preserved across the 11 files above, reorganized into logical, self-contained modules.

## Design Principles

- **Trust file persistence over AI context window memory** — each stage reads only what it needs, writes its output, and the context is cleared before the next stage
- **Aggressive from the start** — full 6-stage pipeline, all validation, all constraint injection
- **HALT on errors** — no partial output, no guessing, clear error messages with source locations
- **Deterministic output** — constraining probabilistic systems tends toward deterministic results
- **Same meaning, different surface** — the compiler controls the human-to-AI optimization dial

---

*Last updated: 13 April 2026*
