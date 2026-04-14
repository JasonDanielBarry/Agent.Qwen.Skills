# Git Assistant Skill

## Overview
A skill that streamlines Git workflows by automating common version control tasks, generating intelligent commit messages, and managing branches.

## What It Does
- Analyzes code changes and generates descriptive, conventional commit messages
- Creates and manages Git branches with naming conventions
- Prepares pull requests with structured descriptions
- Resolves common Git conflicts intelligently
- Shows clean, contextual Git status and history
- Automates rebasing, squashing, and cherry-picking
- Generates release tags and version bumps
- Provides Git best practices guidance

## Why It's Valuable

### For Development Workflow
- **Saves Time**: Automates repetitive Git commands and decision-making
- **Better Commits**: Generates meaningful commit messages that explain "why" not just "what"
- **Reduced Errors**: Prevents common Git mistakes like force-pushing to protected branches

### For Team Collaboration
- **Consistent History**: Enforces conventional commit formats across the team
- **Clear PRs**: Creates well-structured pull request descriptions
- **Branch Hygiene**: Automatically cleans up stale branches

### For Project Management
- **Traceable Changes**: Links commits to features, bugs, or tasks
- **Release Management**: Automates versioning and release tagging
- **Audit Trail**: Maintains clean, reviewable Git history

## Example Use Cases
- "Commit these changes with a good message"
- "Create a feature branch for user authentication"
- "What changed since yesterday?"
- "Create a PR for this branch"
- "Resolve these merge conflicts"
- "Squash the last 3 commits into one"
- "Tag this as v1.2.0"

## Technical Considerations
- Must understand Git conventions (Conventional Commits, GitFlow, etc.)
- Should respect project-specific commit message formats
- Needs to handle both simple and complex merge scenarios
- Must integrate with GitHub/GitLab/Bitbucket APIs for PR creation
- Should validate commits before pushing
- Must preserve Git history integrity during operations

