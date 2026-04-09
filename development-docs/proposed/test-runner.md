# Test Runner Skill

## Overview
A skill that automatically discovers, executes, and reports on test results across various testing frameworks and languages.

## What It Does
- Automatically detects the testing framework in use (Jest, pytest, Mocha, JUnit, etc.)
- Discovers test files and test suites within the project
- Runs tests with appropriate flags (coverage, verbosity, watch mode)
- Parses and formats test output into readable reports
- Identifies failed tests with contextual error messages
- Provides suggestions for fixing common test failures
- Supports running specific test files, test suites, or full test runs

## Why It's Valuable

### For Development Workflow
- **Immediate Feedback**: Quickly validates code changes by running relevant tests
- **Reduced Context Switching**: No need to remember framework-specific commands
- **Consistent Interface**: One skill works across different projects and testing frameworks

### For Code Quality
- **Encourages Testing**: Lowers the barrier to running tests frequently
- **Covers Edge Cases**: Can identify uncovered code paths and suggest tests
- **Regression Prevention**: Catches breaking changes before they reach production

### For Team Collaboration
- **Standardized Reporting**: Consistent test output format across team members
- **Shared Knowledge**: Documents which tests to run for different types of changes
- **Onboarding**: Helps new developers understand the test structure

## Example Use Cases
- "Run the tests for the authentication module"
- "Run all tests and show coverage report"
- "Why is this test failing?"
- "Run tests related to the recent changes"
- "Add a test for this new function"

## Technical Considerations
- Must support multiple languages and frameworks
- Should handle both unit and integration tests
- Needs to parse various output formats
- Should integrate with existing CI/CD pipelines
- Must handle async/await and concurrent test execution
