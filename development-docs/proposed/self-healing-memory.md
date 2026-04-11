# Self-Healing Memory — Research Findings

> **Goal:** Evaluate feasibility of building a "Self-Healing Memory" skill for Qwen Code agents.
> **Date:** 10 April 2026

---

## 1. Executive Summary

Self-healing memory is an emerging pattern in agentic AI systems where the agent's knowledge store automatically detects, corrects, and reorganizes itself without external intervention. Research into Claude Code's leaked source, GitHub Copilot's memory system, and academic work on agentic memory reveals **two complementary approaches**:

| Approach | Mechanism | Example |
|---|---|---|
| **Scheduled Consolidation** | Background agent periodically deduplicates, resolves contradictions, reorganizes | Claude Code `autoDream` |
| **Real-Time Verification** | Memory validated against live source during execution; auto-corrected on conflict | GitHub Copilot |

Both approaches converge on the same principle: **memory is a hint, not truth** — it must be verified against the live codebase and repaired when stale.

---

## 2. Claude Code Memory Architecture (Leaked Source Analysis)

### 2.1 Three-Layer Memory System

| Layer | Load Behavior | Content | Purpose |
|---|---|---|---|
| **Index** | Always loaded | Lightweight pointers (~150 chars per line) | Fast lookup, low overhead |
| **Topic Files** | Loaded on-demand | Full knowledge content | Detailed facts, decisions, patterns |
| **Transcripts** | Never loaded (grep only) | Append-only interaction logs | Historical audit trail |

### 2.2 Write Discipline

1. **Always write to topic file first**, then update Index pointer
2. **Never dump raw content into Index** — Index stays lightweight
3. **Omit derivable facts** — If it can be re-derived from the codebase, don't store it
4. **Treat memory as hint, not truth** — Cross-check against live codebase before applying

### 2.3 autoDream Agent (Nightly Self-Healing)

A background subagent that runs on a schedule (nightly) with:

- **Strictly limited tool access** (cannot corrupt main agent context)
- **Runs in forked subagent** (context isolation)
- **Tasks:**
  - Consolidate daily learnings
  - Deduplicate entries
  - Remove contradictions
  - Reorganize memory structure
  - Preserve clean, context-efficient state

### 2.4 Memory Workflow

```
Capture → Store → Retrieve → Verify → Consolidate
   │         │        │         │          │
   ▼         ▼        ▼         ▼          ▼
 Agent   Topic     Index    Cross-check  autoDream
 or      file +    loaded   against      (dedup,
 KAIROS  Index     on-      live code    resolve,
 bg      update    demand              reorganize)
```

1. **Capture:** Agent or KAIROS (24/7 background agent) generates insights/logs
2. **Store:** Details written to topic file → Index pointer updated → Derivable facts discarded
3. **Retrieve:** Index always loaded → Topic files fetched on-demand → Transcripts grep'd only if needed
4. **Verify:** Retrieved memory validated against live code before use
5. **Consolidate:** autoDream runs nightly to deduplicate, resolve conflicts, reorganize

---

## 3. GitHub Copilot Agentic Memory System

### 3.1 Architecture

- **Cross-agent memory network** — memories shared across Copilot coding agents
- **Citation-based storage** — each memory explicitly tied to citations referencing exact code locations (file:line)
- **Decentralized validation** — no centralized curation pipeline; verification happens at execution time

### 3.2 Self-Healing Mechanism

**Real-time citation verification:**

1. Agent retrieves memory with citation (e.g., `src/auth.ts:42`)
2. Agent reads current content at cited location
3. **If content matches memory** → proceed with confidence
4. **If content conflicts with memory** → agent automatically saves corrected version
5. Corrected memory propagates to shared memory pool

**Key insight:** Memory staleness is resolved *proactively during execution*, not through retroactive batch processing.

### 3.3 Results

| Metric | Improvement | Statistical Significance |
|---|---|---|
| PR merge rate (coding agent) | **+7%** | p < 0.00001 |
| Positive feedback (code review) | **+2%** | p < 0.00001 |

### 3.4 Problem Solved

Eliminates **stale memory from abandoned/modified branches** — a core challenge at GitHub's scale where offline curation is unscalable.

---

## 4. Academic Agentic Memory Architecture

### 4.1 Three-Layer Taxonomy (Human-Inspired)

| Memory Type | Duration | Content | Example |
|---|---|---|---|
| **Working Memory** | Short-term (context window) | Current facts, tool outputs, scratchpads | "User wants to add feature X" |
| **Episodic Memory** | Persistent (sessions) | Task logs, action trajectories, interaction history | "Yesterday we refactored auth module" |
| **Semantic Memory** | Long-term (cross-session) | Vector-indexed facts, knowledge graphs, pattern databases | "This project uses ESLint with strict rules" |

### 4.2 Advanced Structuring

- **Parallel/orthogonal modules:** spatial, temporal, causal, entity, semantic
- **Multi-graph architectures:** MAGMA (Multi-Agent Graph Memory Architecture)
- **Hierarchical overlapping clustering** for shared vs. agent-specific knowledge
- **Hierarchical multi-agent memory graphs** coordinating shared, agent-specific, and cross-trial knowledge

### 4.3 Lifecycle Management

| Operation | Description |
|---|---|
| **Retention** | Keep high-utility memories |
| **Eviction** | TTL (time-to-live), epochal summarization, budgeted scratchpads |
| **Compaction** | Compress multiple related entries into single summary |
| **CRUD as Tools** | Create, Read, Update, Delete, Summarize, Filter — formalized as agentic tools under unified policies |

### 4.4 Self-Healing & Self-Correction Mechanisms

| Mechanism | How It Works |
|---|---|
| **Consistency & Validation** | Iterative judgment, multi-agent validation, targeted updates for retrieval relevance and factual consistency |
| **Recovery & Hygiene** | Strict typed schemas, capability tokens, provenance tagging, two-phase draft→verify→publish cycles |
| **Rollback & Versioning** | Graceful recovery from memory drift, hallucinations, contamination |
| **Adaptive Pruning** | Selective, usage-aware admission controllers; RL-shaped sparsity to evict low-utility or stale slots |
| **Conflict Resolution** | Dynamic rewriting during consolidation when new evidence contradicts stored memories |

### 4.5 Indexing & Retrieval

- **DAG-Tag indexing** — beyond simple cosine similarity
- **Multi-graph traversals** and coherence reasoning
- **Dynamic granularity routing** — queries routed to raw, fact, or episodic levels using learned intent
- **Temporal/recency weighting** and causal subgraph expansion (simulates human memory decay)

---

## 5. Context Engineering & Memory Consolidation

### 5.1 The Problem: Context Rot

LLMs are stateless. Expanded context windows alone cause:
- Performance degradation
- Inaccuracy (hallucination from stale info)
- High token costs

### 5.2 Three-Stage Architecture

| Stage | Description | Techniques |
|---|---|---|
| **Extraction** | Filter massive outputs to identify high-value facts | Atomic statement isolation, entity/relationship encoding, timestamp indexing |
| **Consolidation** | Periodically summarize/rewrite entries; new evidence updates old records | Structured summarization + conflict resolution (Mem0: +26% accuracy, reduced token usage) |
| **Retrieval** | Fetch memories weighted by recency and contextual relevance | Vector stores, knowledge graphs, filesystem indexing |

### 5.3 Implementation Approaches

| Approach | Strengths | Weaknesses | Example |
|---|---|---|---|
| **Vector Stores** | Fast cosine-similarity search | Surface-level recall | Pinecone, Weaviate |
| **Summarization** | Rolling compressed transcripts | Loses detail over time | Mem0 (+26% benchmark accuracy) |
| **Knowledge Graphs** | Interconnected nodes (people, events, time, places) | Complex to maintain | Zep TKG (+18.5% long-horizon accuracy, -90% latency) |
| **Filesystem/Indexing** | Simple, effective in some scenarios | Manual organization | Letta (timestamp-indexed text files) |

---

## 6. Key Patterns for Self-Healing Memory

### Pattern 1: Verification-First Retrieval

```
Memory retrieved → Check against live source → 
  If match: use with confidence
  If conflict: update memory, then use corrected version
```

**Source:** GitHub Copilot

### Pattern 2: Scheduled Consolidation

```
Background agent runs on schedule →
  Deduplicate entries →
  Resolve contradictions →
  Reorganize structure →
  Publish clean state
```

**Source:** Claude Code autoDream

### Pattern 3: Conflict Resolution During Consolidation

```
New evidence detected →
  Identify conflicting stored memory →
  Rewrite outdated entry →
  Prevent context drift
```

**Source:** Mem0, Zep, general agentic memory systems

### Pattern 4: Provenance & Rollback

```
Memory tagged with source, timestamp, version →
  If drift/hallucination detected →
  Rollback to last known-good version
```

**Source:** Academic agentic memory research

---

## 7. Feasibility Assessment for Qwen Code Skill

### 7.1 What's Feasible

| Component | Feasibility | Notes |
|---|---|---|
| **MEMORY.md file structure** | ✅ High | Simple markdown file with sections for facts, decisions, patterns |
| **Index file (lightweight pointers)** | ✅ High | Small markdown file with ~150-char summaries |
| **Topic files (on-demand knowledge)** | ✅ High | Individual markdown files per topic/domain |
| **Write discipline (topic first, then index)** | ✅ High | Can be encoded in SKILL.md instructions |
| **Verification against live codebase** | ✅ High | Agent reads cited files, compares to memory |
| **Real-time conflict resolution** | ✅ High | Agent updates memory when conflict detected |
| **Deduplication & contradiction detection** | ⚠️ Medium | Requires agent attention; not automated background process |
| **Scheduled consolidation** | ⚠️ Medium | No native scheduler in Qwen Code; could use loop skill |
| **Transcript logging (append-only)** | ✅ High | Simple file append per session |

### 7.2 What's NOT Feasible (as a Skill)

| Component | Why Not | Alternative |
|---|---|---|
| **Background agent (autoDream equivalent)** | Qwen Code skills don't run independently | Manual consolidation trigger; `/loop` skill for scheduling |
| **Vector store indexing** | Requires external infrastructure | Out of scope for file-based skill |
| **Knowledge graph** | Requires external database | Out of scope |
| **RL-optimized memory management** | Requires training infrastructure | Out of scope |
| **Forked subagent isolation** | Qwen Code doesn't support subagent forking | Trust agent discipline; use separate session for consolidation |

### 7.3 Proposed Skill Architecture

```
skills/sas-self-healing-memory/
├── SKILL.md                  # Instructions + write discipline rules
├── MEMORY.md                 # Index file (lightweight pointers)
├── topics/                   # Topic files (on-demand knowledge)
│   ├── project-structure.md
│   ├── coding-patterns.md
│   ├── decisions.md
│   └── ...
└── transcripts/              # Append-only session logs
    └── YYYY-MM-DD.md
```

**SKILL.md would encode:**

1. **Write discipline:** Topic file first → Index update second
2. **Verification rule:** Always check memory against live code before use
3. **Conflict resolution:** If conflict found, update memory immediately
4. **Consolidation trigger:** Manual or `/loop` scheduled consolidation session
5. **Retention policy:** Omit derivable facts; keep only non-obvious knowledge
6. **Memory as hint, not truth:** Cross-check always required

---

## 8. Sources

| # | Source | URL |
|---|---|---|
| 1 | Engineers Codex — Diving into Claude Code's Source Code Leak | https://read.engineerscodex.com/p/diving-into-claude-codes-source-code |
| 2 | GitHub Engineering — Building an Agentic Memory System for GitHub Copilot | Referenced via LinkedIn post |
| 3 | Emergent Mind — Agentic Memory Systems | https://www.emergentmind.com/topics/agentic-memory-systems |
| 4 | The New Stack — Memory for AI Agents: A New Paradigm of Context Engineering | https://thenewstack.io/memory-for-ai-agents-a-new-paradigm-of-context-engineering/ |
| 5 | Medium — What Claude Code's Source Leak Actually Reveals | https://medium.com/@marc.bara.iniesta/what-claude-codes-source-leak-actually-reveals-e571188ecb81 |
| 6 | The Register — Claude Code's source reveals extent of system access | https://www.theregister.com/2026/04/01/claude_code_source_leak_privacy_nightmare/ |
| 7 | LinkedIn — GitHub's AI Memory Solution: Self-Healing Agents | https://www.linkedin.com/posts/sangampandey_the-hardest-problem-in-agent-memory-is-not-activity-7427224768040505344-J2Te |
| 8 | Medium — The Rise of Agentic Memory | https://medium.com/@sarup.etceju/the-rise-of-agentic-memory-why-the-next-generation-of-ai-agents-will-remember-reason-and-adapt-bcfb3290f2e5 |

---

## 9. Conclusion

Self-healing memory is **feasible as a Qwen Code skill** with the following constraints:

- **Core mechanism** (verification-first retrieval + conflict resolution) can be encoded in SKILL.md instructions
- **Memory structure** (Index + Topic Files + Transcripts) maps cleanly to markdown files
- **Scheduled consolidation** requires manual trigger or `/loop` skill integration
- **Background agents** (autoDream equivalent) are not natively supported

The skill would focus on **encoding the write discipline, verification rules, and conflict resolution patterns** into agent instructions, relying on the agent's own reasoning to maintain memory integrity rather than automated background processes.

**Skill name:** `sas-self-healing-memory` (follows `sas-` prefix convention)

**Next step:** Draft the `sas-self-healing-memory` skill based on this research.
