# Task Planner Skill

## Overview
A skill that breaks down high-level requirements and features into actionable, structured task lists with dependencies, priorities, and acceptance criteria.

## What It Does
- Analyzes feature requests and breaks them into implementable tasks
- Identifies dependencies between tasks and suggests execution order
- Estimates complexity and flags risky or ambiguous requirements
- Generates acceptance criteria for each task
- Creates todo lists compatible with Gemini CLI's todo_write tool
- Tracks task progress and updates status automatically
- Suggests parallel execution opportunities
- Identifies missing information or unclear requirements
- Links tasks to relevant files, modules, or components

## Why It's Valuable

### For Project Execution
- **Structured Approach**: Transforms vague ideas into concrete implementation steps
- **Risk Mitigation**: Identifies blockers and ambiguities early
- **Visibility**: Provides clear progress tracking for complex work

### For Quality
- **Completeness**: Ensures no implementation step is forgotten
- **Testability**: Generates acceptance criteria for validation
- **Dependencies**: Prevents work from starting before prerequisites are ready

### For Team Collaboration
- **Shared Understanding**: Makes implementation plans explicit and reviewable
- **Delegation**: Enables splitting work among multiple developers
- **Handoff**: Supports session management with clear task state

## Example Use Cases
- "Plan the implementation for user authentication"
- "Break this feature into tasks with dependencies"
- "What's blocking progress on the current task?"
- "Generate acceptance criteria for this task"
- "Update task status to completed"
- "What tasks can I work on in parallel?"
- "Create a phased rollout plan for this migration"

## Technical Considerations
- Must integrate with Gemini CLI's built-in todo_write tool
- Should support task hierarchies (epics → tasks → subtasks)
- Needs to handle both sequential and parallel task execution
- Must persist task state across sessions (via sas-endsession/sas-reattach)
- Should link to external project management tools (Jira, Linear, GitHub Projects)
- Must support task re-prioritization and scope changes
- Should validate task completeness before marking features done

