# Lint & Format Skill

## Overview
A skill that automatically detects, runs, and configures linting and formatting tools across different languages and frameworks to maintain consistent code quality.

## What It Does
- Detects linting and formatting tools already configured in the project (ESLint, Prettier, Black, Ruff, etc.)
- Runs linting checks and auto-fixes common issues
- Formats code according to project standards or suggests configurations
- Identifies code smells, anti-patterns, and potential bugs
- Supports multiple languages in polyglot projects
- Integrates with pre-commit hooks for automated quality checks
- Provides explanations for linting violations
- Suggests linting rules appropriate for the project

## Why It's Valuable

### For Code Quality
- **Consistency**: Ensures uniform code style across the entire codebase
- **Early Detection**: Catches bugs, security issues, and anti-patterns before runtime
- **Best Practices**: Enforces language-specific conventions and modern patterns

### For Development Workflow
- **Saves Time**: Eliminates manual formatting debates and style reviews
- **Auto-Fix Capable**: Automatically resolves common linting errors
- **Project-Aware**: Respects existing configurations instead of imposing new standards

### For Team Collaboration
- **Reduced Review Friction**: Removes style comments from code reviews, focusing on logic
- **Onboarding**: Helps new developers match team conventions immediately
- **Documentation**: Explains why certain linting rules exist

## Example Use Cases
- "Format this file according to project standards"
- "Run the linter and fix what you can"
- "What linting tools are configured in this project?"
- "Set up Prettier for this project"
- "Why is the linter complaining about this line?"
- "Add a pre-commit hook for linting"
- "Check for unused imports across the project"

## Technical Considerations
- Must detect existing tooling before introducing new tools
- Should respect .editorconfig, .prettierrc, .eslintrc, and similar config files
- Needs to handle multiple languages in the same project
- Should distinguish between errors, warnings, and style suggestions
- Must understand when auto-fix is safe vs. when manual review is needed
- Should integrate with CI/CD pipelines without breaking builds
