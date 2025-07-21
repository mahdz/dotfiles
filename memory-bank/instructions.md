# Dotfiles Project Instructions

## Project Overview

This dotfiles project uses a bare Git repository pattern for seamless home directory management with XDG Base Directory Specification compliance. The repository is located at `~/.dotfiles` with `~/` as the work tree.

**Memory Bank Location**: `~/memory-bank/` (project-specific notes and documentation)  
**Knowledge Vault**: `/Users/mh/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault` (main Obsidian vault)

## How to Add New Tool Configurations

### 1. Tool Version Management with Mise
- **Global Configuration**: Edit `~/.config/mise/config.toml`
- **Install Tools**: Use `mise use -g <tool>@<version>`
- **Example**:
  ```toml
  [tools]
  "node" = "latest"
  "npm:eslint" = "latest"
  "npm:prettier" = "latest"
  ```
- **Post-Install**: Run `mise reshim` if there are errors before moving on

### 2. Adding New CLI Tool Configurations
1. Create tool config in appropriate XDG directory: `~/.config/<tool>/`
2. Update `.gitignore` to include the new configuration
3. Test the configuration locally
4. Add to dotfiles tracking: `dot add .config/<tool>/`

### 3. Python Tools via UV
- Install using Homebrew's `uv`: `uv tool install <package>`
- UV creates symlinks in `~/.local/bin/` pointing to `~/.local/share/uv/tools/`
- Recreate symlinks: `uv tool sync`
- **Note**: UV-managed symlinks are NOT tracked (they change frequently)

## Gitignore Pattern Best Practices

### Understanding the Deny-All Strategy
The dotfiles repository uses a "deny-all" strategy starting with `*` then selectively allowing patterns with `!`.

### When Adding New Patterns
1. **Understand Existing Structure**: Review current `.gitignore` before modifications
2. **Pattern Interaction**: Be careful - new patterns interact with existing `!` patterns
3. **Testing**: Verify desired files are still included after changes
4. **Structure**:
   ```gitignore
   # Ignore everything by default
   *
   
   # Add back specific directories/files
   !.config/
   !.config/newtool/
   !.config/newtool/**
   ```

### Common Patterns
- **Tools with Secrets**: Include config, exclude sensitive files
- **Cache Directories**: Generally excluded (`.cache/`, `.local/state/`)
- **Generated Files**: Exclude build artifacts, logs, temporary files

## XDG Directory Usage Conventions

### Standard Locations
- **Configuration**: `$XDG_CONFIG_HOME` (`~/.config/`) - All application configs
- **Data**: `$XDG_DATA_HOME` (`~/.local/share/`) - User-specific data
- **Cache**: `$XDG_CACHE_HOME` (`~/.cache/`) - Cache files (not tracked)
- **State**: `$XDG_STATE_HOME` (`~/.local/state/`) - State files (not tracked)
- **Binaries**: `~/.local/bin/` - User executables

### Shell Configuration
- **ZDOTDIR**: `~/.config/zsh/` - All Zsh configurations
- **Environment**: `.zshenv` in home directory (required for XDG setup)

### Best Practices
- Always check if tools support XDG before creating custom configs
- Use environment variables to redirect non-compliant tools
- Keep tracked files in `~/.config/`, not tracked files in cache/state

## Testing Changes Before Committing

### Pre-Commit Workflow
1. **Review Changes**: `dot status` and `dot diff`
2. **Test Locally**: 
   - Source updated configs: `source ~/.zshenv && source ~/.zshrc`
   - Test tool functionality
   - Verify no broken symlinks or missing dependencies
3. **Check Gitignore**: Ensure new files are properly included/excluded
4. **Validate XDG Compliance**: Check that configs are in correct directories

### Verification Commands
```bash
# Check what will be committed
dot status
dot diff --staged

# Verify tool configurations
mise list
uv tool list

# Test shell loading
exec zsh  # Or open new terminal
```

### Integration Testing
- Open new terminal session to test shell loading
- Verify VS Code extensions and settings load properly
- Test custom aliases and functions
- Ensure Homebrew and mise tools are accessible

## Documentation Standards

### Structure
- **Project Documentation**: Store in `~/memory-bank/`
- **Knowledge Management**: Use Obsidian vault at iCloud location
- **README Files**: Include in relevant config directories
- **Code Comments**: Document complex aliases, functions, and scripts

### Documentation Types
1. **Configuration Documentation**: Explain purpose and usage of configs
2. **Workflow Documentation**: Document common tasks and procedures  
3. **Troubleshooting Guides**: Known issues and solutions
4. **Change Logs**: Track major configuration changes

### Format Standards
- Use Markdown for all documentation
- Include code examples with syntax highlighting
- Use consistent heading structure
- Add links to related documentation and external resources

## Preferred Command Aliases and Workflows

### Dotfiles Management
```bash
# Primary dotfiles alias
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Common workflows
dot status                    # Check repository status
dot add .config/tool/         # Add new tool config
dot commit -S -s -m "message" # Signed commit
dot push origin main          # Push changes
```

### Development Workflow
```bash
# Tool management
mise install                  # Install all tools from config
mise use -g node@latest      # Update global tool version
uv tool sync                 # Recreate UV symlinks

# System maintenance
brew bundle                  # Install/update Homebrew packages
topgrade                    # Update all package managers
```

### Git Workflow
```bash
# Enhanced git commands (git-extras available)
git summary                  # Repository summary
git effort                   # Contribution statistics
git changelog                # Generate changelog
```

### Custom Functions
- **Memory Management**: Use `basic-memory` uvx tool for vault access
- **Knowledge Queries**: Access Obsidian vault programmatically
- **Automated Backups**: Scripts for configuration backup and sync

### Shell Optimization
- **Plugin Loading**: Conditional loading based on terminal environment
- **Performance**: Use `exec zsh` to reload shell efficiently
- **Debugging**: Use `set -xiv` for shell script debugging

### VS Code Integration
- **Profiles**: Separate profiles for different development contexts
- **Extensions**: Managed through settings sync and configuration files
- **Custom Settings**: Stored in `~/.config/vscode/`

---

**Note**: Always test changes in a separate terminal session before committing. The bare repository pattern means changes affect your live environment immediately.
