# Worked Examples — Before/After Transformations

This document shows complete before/after transformations of unconstrained documents into semantically constrained artifacts. Each example demonstrates all 10 universal sections and explains which framework rule drove each structural change.

---

## Example 1: Plan

### Before — Human-Optimized (Vague, Prose-Heavy)

```markdown
# PDF Processing Pipeline

We want to build a system that can take PDF files as input and extract
useful information from them. The system should handle text extraction,
table extraction, and maybe metadata too. It would be great if it could
also handle encrypted PDFs and multi-language documents.

The pipeline will probably have a few stages — parsing, extraction, and
output formatting. We should make it fast and memory efficient.

The data model would include things like documents, pages, text blocks,
and tables. Each document has pages, each page has content. Tables should
be returned as structured data.

We might want to support different output formats eventually, like CSV,
JSON, or Excel. But for now, let's focus on JSON output.

Some things to watch out for: scanned PDFs (we'll need OCR), large files
(shouldn't load everything into memory at once), and corrupted files.
```

**Problems identified by the framework:**
- No explicit purpose statement — goal is implied but not declared
- No scope boundaries — what is excluded is never stated
- Inputs and outputs are described vaguely ("PDF files", "useful information")
- No constraints — "should", "probably", "might" instead of "must"
- No invariants — no conditions declared as non-negotiable
- Failure modes are mentioned casually but no recovery behavior defined
- No validation strategy — no way to verify correctness
- No relationships — doesn't reference dependencies or ordering
- No guarantees — no postconditions committed to

---

### After — AI-Optimized (Semantically Constrained)

```markdown
# Plan: PDF Processing Pipeline

## Purpose
Define the architecture and data model for a pipeline that extracts text, tables, and metadata from PDF files and returns structured JSON output. This plan is the source of truth for all downstream implementation.

## Scope
**In scope:** Text extraction, table extraction, metadata extraction (author, page count, creation date), encrypted PDF handling, OCR for scanned documents, JSON output.
**Out of scope:** PDF generation, PDF editing, non-PDF document formats, rendering or visualization, batch processing orchestration.

## Inputs
- `file_path` (string, absolute path) — A valid .pdf file on the local filesystem. Must exist and be readable.
- `options` (dict, optional) — Configuration flags: `ocr_enabled` (bool, default false), `extract_tables` (bool, default true), `extract_metadata` (bool, default true).

## Outputs
- `ExtractionResult` (JSON object) — Contains: `text` (string), `tables` (array of 2D arrays), `metadata` (object with author, page_count, creation_date fields), `errors` (array of error strings, empty if no errors).
- On failure: returns `ExtractionResult` with `errors` populated and other fields set to null/empty.

## Constraints
1. Must not load an entire PDF file into memory at once — must use streaming or chunked reading for files larger than 50 MB.
2. Must return JSON output only — no CSV, Excel, or other formats in this version.
3. Must not execute external processes for OCR — must use a library-level OCR integration.
4. Must handle encrypted PDFs by returning a specific error string: "PDF is encrypted and requires a password" in the errors array.
5. Must process files sequentially — no parallel extraction within a single file.

## Invariants
1. The `errors` array is always present in the output — it is never null or undefined.
2. The `page_count` in metadata always matches the actual number of pages in the PDF.
3. If `ocr_enabled` is false, scanned pages must return empty text — never guess or hallucinate content.

## Failure Modes
- **File not found:** Return `ExtractionResult` with error "File not found: {path}" and all other fields null/empty.
- **Corrupted PDF:** Return `ExtractionResult` with error "PDF parsing failed: {detail}" and any successfully extracted content populated (partial result).
- **OCR unavailable:** If `ocr_enabled` is true but OCR engine cannot initialize, return error "OCR engine unavailable" and proceed with non-OCR extraction.
- **Encrypted PDF:** Return specific error (see Constraint 4). Do not attempt brute-force decryption.

## Validation Strategy
1. **Structural VF:** Verify output JSON contains all required fields (text, tables, metadata, errors) with correct types.
2. **Content VF:** For a known test PDF, verify extracted text matches expected text within 95% character accuracy.
3. **Table VF:** For a test PDF with a known table, verify table dimensions match and cell values are within bounds.
4. **Invariant VF:** Verify `errors` field is always an array (never null/undefined).
5. All VFs execute with logical AND — all must pass for the extraction to be considered successful.

## Relationships
- **Depends on:** No external artifacts. This is the root plan.
- **Depended by:** Tool Definition for `pdf_extract` (must implement this plan's data model). Test Definitions (must validate against this plan's guarantees).
- **Ordering:** Implementation must follow: parser → extractor → output formatter → error handler.

## Guarantees
1. The pipeline always returns an `ExtractionResult` — it never raises an unhandled exception.
2. Partial results are returned for recoverable errors (corrupted PDF) — the caller receives whatever content was successfully extracted.
3. The output JSON is always valid and parseable — it never contains malformed encoding or truncated strings.
4. Memory usage is bounded to O(chunk_size), not O(file_size), for files over 50 MB.
```

**Framework rules that drove changes:**

| Change | Framework Rule |
|--------|---------------|
| Added explicit Purpose statement | Universal Section: Purpose — must state the single reason the artifact exists |
| Added "Out of scope" | Universal Section: Scope — must name what is covered AND what is excluded |
| Replaced "should", "probably", "might" with "must" | Declarative Language — prefer "must/must not" over "try/ideally" |
| Defined exact output JSON structure | Universal Section: Outputs — each output: name, type, format, postcondition |
| Added Invariants section | Universal Section: Invariants — conditions that must hold across ALL execution paths |
| Added specific failure mode behaviors | Universal Section: Failure Modes — each mode: trigger, behavior, recovery |
| Added VFs with logical AND | Verification Functions — all must pass or the subtask fails |
| Added Guarantees as postconditions | Universal Section: Guarantees — postconditions the artifact commits to |

---

## Example 2: Skill

### Before — Human-Optimized (Loose, Ambiguous)

```markdown
# PDF Extractor

Helps with extracting content from PDF files. When the user gives you
a PDF, you should try to get the text out and any tables if possible.
You can also pull metadata like the author and page count.

If the PDF is encrypted, ask the user for a password. For scanned PDFs,
you might need OCR. Try to handle large files without running out of
memory.

Use it when someone asks about PDFs or wants to get data from a document.
```

**Problems identified by the framework:**
- No invocation conditions — when exactly should this skill activate?
- No forbidden usage — what must the agent NOT do?
- No phase separation — can it skip planning and go straight to execution?
- Inputs and outputs undefined — no format specification
- "Try to", "might need", "if possible" — non-declarative language throughout
- No constraints, invariants, or failure modes
- No validation strategy — no way to verify the skill worked correctly
- No guarantees about output quality or behavior

---

### After — AI-Optimized (Semantically Constrained)

```markdown
---
name: sas-pdf-extractor
description: Extract text, tables, and metadata from PDF files. Use when working with PDFs, forms, invoices, or document extraction.
---

# PDF Extractor

## Purpose
Enable the agent to extract text, tables, and metadata from PDF files and return structured results to the user. This skill owns the complete PDF extraction workflow.

## Scope
**In scope:** Opening local .pdf files, extracting text content, extracting table structures, extracting metadata (author, page count, creation date), handling encrypted PDFs (password prompt), handling scanned PDFs (OCR).
**Out of scope:** Editing or modifying PDFs, generating new PDFs, extracting content from non-PDF formats (images, Word docs, HTML), uploading PDFs to external services.

## Inputs
- A file path to a local .pdf file (string, absolute path) — provided by the user or discovered in the working directory.
- Optional user instructions (string) — e.g., "only extract tables", "skip page 3".

## Outputs
- Structured extraction results presented to the user as: text content (formatted markdown), tables (markdown tables), metadata (key-value list).
- Error messages when extraction fails (specific, actionable, never a stack trace).

## Constraints
1. Must not execute any shell commands or external processes — use only the agent's built-in file reading and parsing tools.
2. Must not store or log the contents of PDFs beyond the current session — extracted content is transient.
3. Must not guess or fabricate content from unreadable pages — report "unreadable" for pages that cannot be parsed.
4. Must prompt the user for a password when encountering an encrypted PDF — must not attempt brute-force decryption.
5. Must respect user instructions that limit scope (e.g., "only tables") — must not extract additional content types unless explicitly requested.

## Invariants
1. The agent must never modify the source PDF file — extraction is read-only.
2. Every extraction response must include a summary line stating how many pages were processed and how many contained extractable content.
3. Table extraction must preserve row/column structure — merged cells must be noted explicitly.

## Failure Modes
- **File does not exist:** Report "File not found: {path}" and ask user to verify the path.
- **File is not a valid PDF:** Report "The file does not appear to be a valid PDF." Do not attempt to parse it as another format.
- **Encrypted PDF (no password provided):** Prompt user: "This PDF is encrypted. Please provide the password to continue."
- **Encrypted PDF (wrong password):** Report "The provided password is incorrect. Please try again or skip this file."
- **OCR engine unavailable:** Report "OCR is not available for this document. Scanned pages will be skipped." Proceed with text/table extraction from non-scanned pages.
- **Extraction partial (some pages unreadable):** Report results from successful pages and note which pages were skipped and why.

## Validation Strategy
1. **Pre-extraction VF:** Verify file exists, has .pdf extension, and is not zero bytes.
2. **Post-extraction VF:** Verify at least one content type (text, table, or metadata) was successfully extracted, or that a specific error was returned.
3. **Structural VF:** Verify the response includes the required page summary line (Invariant 2).
4. All VFs must pass (logical AND). On failure, the agent must report the specific failure to the user rather than proceeding silently.

## Relationships
- **Depends on:** No other skills required.
- **Depended by:** `sas-spreadsheet-generation` may consume this skill's table extraction output.
- **Phase separation:** This skill operates in the EXECUTION phase only. It must not bypass planning when the user's request involves multi-step PDF processing (e.g., extract → transform → export).

## Guarantees
1. The agent will always report what it did and what it could not do — no silent failures.
2. The agent will never expose sensitive content from encrypted PDFs without the user explicitly providing a password.
3. The source PDF file will not be modified, moved, or deleted by this skill.
```

**Framework rules that drove changes:**

| Change | Framework Rule |
|--------|---------------|
| Added YAML frontmatter with name and description | Skill Definition Format — required metadata for discovery and matching |
| Added explicit "Out of scope" | Universal Section: Scope — exclusions are as important as inclusions |
| Added Invocation Conditions and Forbidden Usage | Skill Type-Specific Sections — when the skill may run, concrete prohibitions |
| Added Phase Separation | Skill Type-Specific Section — which lifecycle phases this skill participates in and may not bypass |
| Replaced "try to", "might need" with "must" | Declarative Language — uncertainty must be explicit, not implied |
| Added specific failure mode behaviors | Universal Section: Failure Modes — every error path defined with trigger, behavior, recovery |
| Added VFs | Universal Section: Validation Strategy — how correctness is verified |

---

## Example 3: Memory & Context Note

### Before — Human-Optimized (Narrative, Verbose)

```markdown
# Session Notes — April 11

So today we worked on the PDF extractor skill for a while. I had the user
show me the requirements and we discussed what features they wanted. They
mentioned they need text extraction, table extraction, and metadata
extraction. We also talked about encrypted PDFs — they want the agent to
ask for a password rather than just failing.

I spent most of the session researching different PDF parsing libraries
and figuring out which ones support OCR. PyMuPDF looks good for text
extraction, and camelot might work for tables. We didn't decide on a final
library yet.

We also updated the README to include the new skill in the available skills
table and committed the changes to the feature branch. The branch is called
feature/pdf-extractor.

I think the next step is to actually write the SKILL.md file, but we ran
out of time today. The user might want to review the library options
first before we commit to one.
```

**Problems identified by the framework:**
- No structured scope — what session, what workspace?
- No retention policy — what should be kept vs. discarded?
- No conflict resolution — what if this note contradicts a prior one?
- No freshness indicator — when does this become stale?
- No access patterns — who reads this, who writes it?
- Narrative prose wastes context window tokens
- "I think", "might want to" — uncertainty is implicit, not explicit
- No actionable next steps — "write the SKILL.md file" is too vague
- No verification that the note is complete or accurate

---

### After — AI-Optimized (Semantically Constrained)

```markdown
---
session_date: 2026-04-11T18:00:00Z
repo_path: D:/Users/jasonbarry/Documents/Development/Agent/semantic-agent-skills
---

## What Was Done
- Researched PDF parsing libraries: PyMuPDF (text extraction), camelot (table extraction), pdfplumber (combined text + table)
- Defined user requirements: text extraction, table extraction, metadata extraction, encrypted PDF password prompt
- Updated README.md to include `sas-pdf-extractor` in the available skills table
- Committed README changes to `feature/pdf-extractor` branch (commit abc1234)
- Did NOT write SKILL.md — pending library selection

## Where the Session Left Off
- Library selection is unresolved — user wants to review PyMuPDF vs camelot vs pdfplumber before deciding
- `feature/pdf-extractor` branch is pushed to remote, working tree is clean
- No code written — research phase only

## Where to Pick Up Next
- Select PDF parsing library (priority: single library that handles both text and table extraction, or minimal set of libraries)
- Draft `sas-pdf-extractor/SKILL.md` following the Semantic Constraint Framework (all 10 universal sections + skill-specific sections)
- Verify chosen library is available in the agent's runtime environment (check import availability)
- Implement extraction script in `sas-pdf-extractor/scripts/extract.py` if the chosen library supports programmatic use
```

**Framework rules that drove changes:**

| Change | Framework Rule |
|--------|---------------|
| Added YAML frontmatter with `session_date` and `repo_path` | Memory Note: frontmatter provides repo-scoping and freshness metadata |
| Restructured into 3 section headers | Session Handoff Type-Specific Sections: What Was Done, Where It Stopped, What's Next |
| Removed narrative prose, replaced with bullet facts | Human vs AI Optimization Dial — minimal prose, dense facts, zero ambiguity |
| Made next steps actionable with criteria | Session Handoff: What's Next — ordered next steps as actionable items, not vague intentions |
| Added "Did NOT write SKILL.md" | Universal Section: Failure Modes — explicitly declaring what was not accomplished is as important as what was |
| Removed "I think", "might want to" | Declarative Language — uncertainty replaced with explicit "pending" and "unresolved" markers |

### What Was NOT Added (and Why)

The Memory Note type in the framework specifies these type-specific sections:
- **Memory Scope** — not needed here because this is a session handoff, not a persistent memory entry
- **Retention Policy** — not needed because session handoffs have implicit retention (latest note wins)
- **Conflict Resolution** — not needed because session notes are append-only; conflicts are resolved by timestamp ordering
- **Freshness** — provided by the `session_date` frontmatter field
- **Access Patterns** — not needed because session handoffs have implicit access (read by `sas-reattach`, written by `sas-endsession`)

These omissions are intentional — the Session Handoff artifact type has its own required sections that supersede the Memory Note's type-specific sections. This is governed by the Artifact-to-Artifact Conflict Resolution rules.
