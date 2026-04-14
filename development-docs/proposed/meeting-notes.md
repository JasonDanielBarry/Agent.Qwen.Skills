# Meeting Notes Skill

## Overview
A skill that structures, formats, and manages meeting notes, action items, and decisions for teams and projects.

## What It Does
- Creates structured meeting note templates with agenda, attendees, and outcomes
- Extracts action items with owners and deadlines from discussions
- Records decisions, rationale, and alternatives considered
- Tracks open questions and follow-up items
- Links to relevant project artifacts (docs, PRs, issues)
- Generates meeting summaries and distributes them
- Maintains a searchable archive of past meetings
- Supports recurring meeting patterns and series tracking

## Why It's Valuable

### For Team Alignment
- **Clear Outcomes**: Ensures meetings result in actionable decisions
- **Accountability**: Tracks who owns what action items
- **Transparency**: Makes meeting outcomes visible to absent stakeholders

### For Project Management
- **Decision Trail**: Maintains historical record of why decisions were made
- **Follow-Through**: Prevents action items from falling through cracks
- **Time Efficiency**: Reduces meeting overhead with structured formats

### For Knowledge Management
- **Searchable History**: Enables finding past decisions and context
- **Onboarding**: Helps new team members understand project history
- **Institutional Memory**: Preserves knowledge beyond individual tenure

## Example Use Cases
- "Create meeting notes for today's standup"
- "What action items came out of the architecture review?"
- "Summarize the decisions from last week's planning meeting"
- "Generate a template for a retrospective meeting"
- "Who owns the database migration task?"
- "Show me all meetings where we discussed the API redesign"

## Technical Considerations
- Must support multiple output formats (Markdown, Google Docs, Confluence)
- Should integrate with calendar systems (Google Calendar, Outlook)
- Needs to parse natural language for action item extraction
- Must handle sensitive information and access controls
- Should link to project management tools (Jira, Linear, GitHub Issues)
- Must support both synchronous and async meeting notes
- Should remind about overdue action items

