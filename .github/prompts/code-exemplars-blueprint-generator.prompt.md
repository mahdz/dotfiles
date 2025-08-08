---
mode: 'agent'
description: 'Generate documentation of exemplary code patterns and best practices found in the codebase to guide consistent implementation'
tools: ['semantic_search', 'file_search', 'read_file']
---

# Code Exemplars Blueprint Generator

Your task is to analyze the codebase and create a comprehensive exemplars document that highlights best practices, patterns, and high-quality implementations. Focus on code that demonstrates excellent:

- Python best practices and patterns
- Type hints and documentation
- Error handling and validation
- Testing approaches
- Documentation standards
- Clean code principles

## Analysis Process

1. Scan the codebase for representative examples of:
   - Well-structured modules and classes
   - Clear and effective function implementations
   - Comprehensive type hints and docstrings
   - Effective error handling
   - Clean testing patterns

2. For each exemplar:
   - Document the file location
   - Explain why it's exemplary
   - Highlight key patterns and principles
   - Note any specific conventions used

3. Group exemplars by category:
   - Data Processing Patterns
   - Validation & Error Handling
   - Testing Patterns
   - Documentation Examples
   - Configuration Management
   - Utility Functions

## Output Format

Generate `docs/code_exemplars.md` with:

1. Introduction explaining document purpose
2. Table of contents with category links
3. Organized sections by category
4. For each exemplar:
   - File path and line numbers
   - Purpose and context
   - Key implementation details
   - What makes it exemplary
   - Usage guidance
5. Best practices summary
6. Style guide alignment notes

## Documentation Standards

- Keep descriptions clear and concise
- Include context for why patterns are effective
- Note any related files or dependencies
- Highlight type safety and error handling
- Document any assumptions or requirements

## Special Considerations

1. Python-Specific Patterns:
   - Type hint usage
   - Context managers
   - Generator patterns
   - Decorator usage
   - Exception handling

2. Project-Specific Patterns:
   - Transaction processing flows
   - Data validation approaches
   - Configuration management
   - Testing strategies
   - Documentation conventions

Only include actual examples from the codebase - no hypothetical code.
