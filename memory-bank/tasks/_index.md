# Tasks

Task management system for organizing work items, improvements, and project planning.

## Directory Structure

- **`active/`** - Current work items and ongoing tasks
- **`completed/`** - Archive of finished tasks for reference
- **`backlog/`** - Future improvements, ideas, and planned work

## Task Management Guidelines

### Creating Tasks

1. **Create descriptive filenames**: Use kebab-case with clear, actionable names
   - ✅ `fix-zsh-startup-performance.md`
   - ✅ `add-git-commit-templates.md`
   - ❌ `task1.md` or `stuff-to-do.md`

2. **Use consistent task format**:
   ```markdown
   # Task Title
   
   ## Description
   Brief description of what needs to be done
   
   ## Acceptance Criteria
   - [ ] Specific deliverable 1
   - [ ] Specific deliverable 2
   - [ ] Testing/verification steps
   
   ## Context
   Any relevant background information, links, or dependencies
   
   ## Status
   - Created: YYYY-MM-DD
   - Started: YYYY-MM-DD (if applicable)
   - Completed: YYYY-MM-DD (if applicable)
   ```

### Workflow

1. **New tasks** → Create in `active/` if starting immediately, or `backlog/` for future work
2. **In progress** → Keep in `active/` with regular updates
3. **Completed** → Move to `completed/` with final status update

### Task Categories

Use tags or prefixes to categorize tasks:

- **`config-`** - Configuration changes and dotfiles updates
- **`tool-`** - Adding new tools or updating existing ones
- **`fix-`** - Bug fixes and issue resolution  
- **`doc-`** - Documentation improvements
- **`perf-`** - Performance optimizations
- **`security-`** - Security-related improvements

### Best Practices

- Keep tasks focused and actionable
- Include relevant context and links
- Update task status regularly
- Archive completed tasks for future reference
- Review backlog periodically to prioritize work

## Integration

This task system integrates with:

- **Dotfiles management**: Track configuration changes and improvements
- **Development workflow**: Organize coding tasks and tool updates
- **Knowledge management**: Link to relevant notes and documentation
- **Version control**: Track task-related commits and branches

---

*This task management system follows the XDG Base Directory Specification and integrates with the overall dotfiles architecture.*
