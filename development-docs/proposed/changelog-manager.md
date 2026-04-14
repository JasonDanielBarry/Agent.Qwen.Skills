# Changelog Manager Skill

## Overview
A skill that automatically generates, maintains, and formats CHANGELOG files based on Git history, commits, and release notes.

## What It Does
- Parses Git history and commit messages to identify changes
- Groups changes into conventional categories (Features, Fixes, Breaking Changes, etc.)
- Generates formatted CHANGELOG entries following Keep a Changelog conventions
- Supports semantic versioning and release tracking
- Links to relevant commits, PRs, and issues
- Identifies breaking changes and migration notes
- Updates existing CHANGELOG files or creates new ones
- Supports multiple output formats (Markdown, plain text, HTML)

## Why It's Valuable

### For Release Management
- **Automated Documentation**: Eliminates manual changelog writing overhead
- **Consistency**: Maintains uniform format across releases
- **Traceability**: Links every change back to its source (commit, PR, issue)

### For Communication
- **User-Facing Updates**: Creates readable release notes for end users
- **Developer Notes**: Includes technical details for downstream consumers
- **Breaking Changes**: Clearly highlights migrations and incompatibilities

### For Project Health
- **Release Discipline**: Encourages structured release processes
- **Historical Record**: Maintains comprehensive project history
- **Transparency**: Shows stakeholders what changed and why

## Example Use Cases
- "Generate a changelog for the latest release"
- "What changed since v1.2.0?"
- "Add this fix to the changelog"
- "Create release notes for v2.0.0 with breaking changes"
- "Update the changelog from the last sprint's commits"
- "Show me all features added this month"

## Technical Considerations
- Must understand Conventional Commits format
- Should integrate with GitHub/GitLab release workflows
- Needs to handle both simple and complex versioning schemes
- Must distinguish between user-facing and internal changes
- Should support monorepo structures with per-package changelogs
- Must handle edge cases like reverted commits and cherry-picks
- Should validate semantic versioning bumps

