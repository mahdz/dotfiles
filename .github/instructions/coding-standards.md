# Coding Standards

This document outlines coding standards and best practices for this repository. These standards ensure consistency, maintainability, and quality across all code and configuration files.

## General Principles

### Code Quality

- **Always lint code** before committing
- **Follow language-specific style guides** (e.g., PEP 8 for Python, JSDoc for JavaScript)
- **Write self-documenting code** with clear variable and function names
- **Use consistent indentation** (spaces preferred, 2-4 spaces depending on language)
- **Keep functions small and focused** on a single responsibility

### File Standards

- **🚨 CRITICAL: All files must end with a blank line** - This applies to EVERY file you create or edit, no exceptions
- **Use UTF-8 encoding** for all text files
- **Use Unix line endings** (LF, not CRLF)
- **Remove trailing whitespace** from all lines
- **Use meaningful file and directory names**

### File Editing Requirements

When editing ANY file:

1. **ALWAYS ensure the file ends with a blank line** after your changes
2. **Check for and remove trailing whitespace** on modified lines
3. **Maintain consistent indentation** with the existing file
4. **Preserve the original file encoding** (UTF-8)
5. **Test that your changes don't break functionality**

### Documentation

- **Every script must have a header** explaining its purpose
- **Complex functions require docstrings/comments**
- **Configuration files should include inline comments** explaining key settings
- **README files should be up-to-date** with current functionality

## Language-Specific Standards

### Shell Scripts (Bash/Zsh)

```bash
#!/usr/bin/env bash
# Script description and purpose

set -euo pipefail  # Always use strict mode

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Functions should be documented
# Usage: log "message"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Use proper error handling
main() {
    # Implementation here
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

**Standards:**

- Always use `#!/usr/bin/env bash` shebang
- Use `set -euo pipefail` for strict error handling
- Quote variables to prevent word splitting
- Use `readonly` for constants
- Functions should have clear names and purposes
- Always end with blank line

### YAML Files

```yaml
---
# Document purpose and structure

# Use 2-space indentation
key:
  nested_key: value
  list:
    - item1
    - item2

# Comments should explain complex configurations
complex_setting:
  enabled: true  # Enable this feature for production
```

**Standards:**

- Use 2-space indentation
- Start with `---` document separator
- Quote strings when necessary
- Use lowercase with underscores for keys
- Add comments for complex configurations

### Markdown Files

````markdown
# Title (H1 - only one per document)

Brief description of the document's purpose.

## Section (H2)

Content with proper formatting.

### Subsection (H3)

- Use bullet points for lists
- **Bold** for emphasis
- `code` for inline code
- Proper spacing between sections

```code-block
# Code blocks should specify language
echo "example"
```
````

**Standards:**

- One H1 per document
- Use proper heading hierarchy
- Include table of contents for long documents
- Use consistent bullet point style
- Always end with blank line

### Configuration Files

#### Dotfiles (.zshrc, .gitconfig, etc.)

- **Organize in logical sections** with clear comments
- **Use consistent formatting** and indentation
- **Include explanatory comments** for complex configurations
- **Group related settings** together

#### Template Files (.tmpl)

- **Use clear template variable names** that indicate purpose
- **Add comments** explaining template logic
- **Test templates** with sample data

## Repository Standards

### Git Standards

- **Use semantic commit messages**:
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation
  - `refactor:` for code refactoring
  - `test:` for adding tests
  - `chore:` for maintenance tasks

- **Keep commits focused** on a single change
- **Write descriptive commit messages** explaining the "why"
- **Test before committing**

### Testing Standards

- **Test all scripts** before committing
- **Verify cross-platform compatibility** (macOS, Linux, WSL2)
- **Test installation on clean systems**
- **Validate configuration files** with appropriate tools

## Linting and Validation

### Required Tools

- **ShellCheck** for shell scripts: `shellcheck script.sh`
- **yamllint** for YAML files: `yamllint file.yaml`
- **markdownlint** for Markdown: `markdownlint file.md`

### Pre-commit Checks

Before committing any file:

1. **Run appropriate linters**
2. **Check for trailing whitespace**
3. **Ensure file ends with blank line**
4. **Verify no secrets are included**
5. **Test functionality**

### Automated Checks

```bash
# Example pre-commit script
#!/bin/bash
set -e

# Check shell scripts
find . -name "*.sh" -exec shellcheck {} \;

# Check YAML files
find . -name "*.yml" -o -name "*.yaml" | xargs yamllint

# Check for trailing whitespace
if git diff --cached --check; then
    echo "✓ No trailing whitespace"
else
    echo "✗ Fix trailing whitespace before committing"
    exit 1
fi

# Ensure files end with newline
for file in $(git diff --cached --name-only); do
    if [[ -f "$file" && ! -s "$file" ]]; then
        continue  # Skip empty files
    fi
    if [[ -f "$file" && $(tail -c1 "$file" | wc -l) -eq 0 ]]; then
        echo "✗ File $file does not end with a newline"
        exit 1
    fi
done

echo "✓ All pre-commit checks passed"
```

## Security Standards

### Secrets Management

- **Never commit secrets, API keys, or passwords**
- **Use environment variables** for sensitive data
- **Use .gitignore** to exclude sensitive files
- **Audit for accidental secret commits**

### File Permissions

- **Scripts should be executable** (755)
- **Configuration files** should be readable (644)
- **SSH keys** should have correct permissions (600 for private keys)

## Performance Standards

### Script Performance

- **Avoid unnecessary loops** and command substitutions
- **Cache expensive operations**
- **Use built-in shell features** over external commands when possible
- **Parallelize independent operations**

### Configuration Performance

- **Optimize shell startup time**
- **Lazy-load expensive plugins**
- **Use efficient aliases and functions**

## Maintenance Standards

### Regular Maintenance

- **Update dependencies** regularly
- **Review and update documentation**
- **Remove deprecated configurations**
- **Test on fresh systems** periodically

### Version Management

- **Tag stable releases**
- **Document breaking changes**
- **Maintain backward compatibility** when possible
- **Use semantic versioning** for releases

## Compliance Checklist

Before submitting any code change:

- [ ] Code follows language-specific style guide
- [ ] All files end with a blank line
- [ ] No trailing whitespace
- [ ] Proper indentation used consistently
- [ ] Comments explain complex logic
- [ ] Scripts have proper error handling
- [ ] Files have correct permissions
- [ ] No secrets committed
- [ ] Linters pass without errors
- [ ] Functionality tested
- [ ] Documentation updated if needed

## Tools Integration

### Editor Configuration

Ensure your editor is configured to:

- Show trailing whitespace
- Insert final newline
- Use consistent indentation
- Highlight syntax errors
- Run linters on save

### IDE/Editor Settings

```json
// VS Code settings.json example
{
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "editor.detectIndentation": true,
  "editor.insertSpaces": true
}
```

## References

- [Bash Style Guide](https://google.github.io/styleguides/shellguide.html)
- [YAML Style Guide](https://yamllint.readthedocs.io/en/stable/rules.html)
- [Markdown Style Guide](https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md)
- [Git Commit Message Conventions](https://www.conventionalcommits.org/)

---

*This document should be reviewed and updated regularly to ensure it reflects current best practices and project needs.*
