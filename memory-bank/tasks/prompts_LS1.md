# Prompts for fzf Configuration Review (LS1)

## Prompt [LS1_1]

### Context

The initial logic to determine `FZF_PATH` in [`fzf.zsh`](.config/zsh/zshrc.d/fzf.zsh:7) uses a multi-line `if/elif` block. A commented-out, less readable one-liner is also present. This can be simplified for better readability and conciseness.

### Task

Refactor the `FZF_PATH` detection logic to be more concise and readable.

### Requirements

- Check for the existence of the `fzf` directory in a prioritized order.
- Assign the path to `FZF_PATH` if found.
- The new logic should be a single, clear conditional block.
- Remove the commented-out one-liner.

### Previous Issues

N/A (Initial review)

### Expected Output

A refactored `zsh` script with improved logic for setting `FZF_PATH`.

---

## Prompt [LS1_2]

### Context

The `FZF_DEFAULT_OPTS` variable is initialized on [line 18](.config/zsh/zshrc.d/fzf.zsh:18) and then has color options appended on [line 32](.config/zsh/zshrc.d/fzf.zsh:32). This separation can make it harder to see the final set of options at a glance.

### Task

Consolidate the definition of `FZF_DEFAULT_OPTS` to improve readability.

### Requirements

- Combine the initial definition and the color options into a single assignment.
- Ensure that the conditional logic for `--height` when not in `TMUX` is preserved.

### Previous Issues

N/A (Initial review)

### Expected Output

A refactored `zsh` script where `FZF_DEFAULT_OPTS` and its color settings are defined in a single, coherent block.

---

## Prompt [LS1_3]

### Context

The `FZF_CTRL_R_OPTS` variable is defined on [line 45](.config/zsh/zshrc.d/fzf.zsh:45) to add a `ctrl-y` binding, but it is immediately overwritten on [line 50](.config/zsh/zshrc.d/fzf.zsh:50) with different options for a preview. This means the `ctrl-y` binding is never actually set.

### Task

Merge the two `FZF_CTRL_R_OPTS` definitions to combine their functionality.

### Requirements

- The final `FZF_CTRL_R_OPTS` should include both the `ctrl-y` binding for copying the command and the preview configuration.
- Both sets of options should be applied correctly to the CTRL-R widget.

### Previous Issues

N/A (Initial review)

### Expected Output

An updated `FZF_CTRL_R_OPTS` variable that correctly combines the intended functionalities from both original definitions.

---

## Prompt [LS1_4]

### Context

On [line 54](.config/zsh/zshrc.d/fzf.zsh:54), several variables including `FZF_CTRL_R_OPTS` and `FZF_DEFAULT_OPTS` are unset. This is immediately followed by a conditional block on [line 58](.config/zsh/zshrc.d/fzf.zsh:58) that sets `FZF_ALT_C_OPTS`. The comment suggests this is to prevent variables from being appended on nested shell startups, but its placement nullifies some of the configurations defined just before it.

### Task

Review and correct the `unset` logic to ensure configurations are not prematurely discarded.

### Requirements

- The primary configurations for `fzf` should persist.
- If the goal is to prevent re-sourcing issues, implement a more robust check (e.g., checking if a variable is already set before defining it).
- The `FZF_ALT_C_OPTS` logic should work as intended.

### Previous Issues

N/A (Initial review)

### Expected Output

A refactored script with a corrected approach to defining and unsetting configuration variables, ensuring that all settings are applied correctly.

---

## Prompt [LS1_5]

### Context

The custom `cd` function on [line 95](.config/zsh/zshrc.d/fzf.zsh:95) is complex and contains non-portable `ls` flags (`--`). The preview logic is intricate and lacks comments, making it difficult to understand and maintain.

### Task

Refactor the `cd` function for clarity, portability, and maintainability.

### Requirements

- Replace non-portable `ls` flags with POSIX-compliant alternatives (e.g., remove `--` from `ls -d -- */`).
- Add comments to the function and the `fzf` preview logic to explain what each part does.
- Simplify the logic where possible without changing the core functionality.

### Previous Issues

N/A (Initial review)

### Expected Output

A refactored and well-documented `cd` function that is easier to read and maintain.

---

## Prompt [LS1_6]

### Context

The script uses different methods to check if a command exists. On [line 20](.config/zsh/zshrc.d/fzf.zsh:20), it uses `command -v fzf-tmux &>/dev/null`, while on [lines 58 and 70](.config/zsh/zshrc.d/fzf.zsh:58) it uses the `zsh`-native `(( $+commands[command_name] ))`.

### Task

Standardize the method used for checking if a command exists.

### Requirements

- Use the `zsh`-native `(( $+commands[command_name] ))` syntax for all command existence checks.
- This includes checking for `fzf-tmux`, `tree`, and `fzf`.

### Previous Issues

N/A (Initial review)

### Expected Output

A script that consistently uses `(( $+commands[...] ))` for all command checks.
