# Plugin Audit Report
**Date:** 2026-01-26  
**Baseline:** 0.133s startup (already 3.7x below 500ms target)

---

## Plugin Inventory & Usage Analysis

### ✅ **CRITICAL (No Defer) - Actually Used**
| Plugin | Purpose | Evidence | Action |
|--------|---------|----------|--------|
| `mattmc3/zephyr:environment` | Core env setup | Loaded first | KEEP |
| `mattmc3/zephyr:color` | Color codes | Used in shellrc | KEEP |
| `mattmc3/zephyr:history` | History settings | Zephyr foundation | KEEP |
| `ohmyzsh/lib/completion.zsh` | OMZ completions | Critical | KEEP |
| `ohmyzsh/lib/key-bindings.zsh` | Key bindings | Essential | KEEP |
| `ohmyzsh/lib/termsupport.zsh` | Terminal support | Essential | KEEP |

---

### ⚠️ **QUESTIONABLE - No Custom Usage Found**

#### `marlonrichert/zsh-hist` (deferred)
- **What it does:** Enhanced history command with `hist` alias + functions
- **Your usage:** Alias `h=' hist'` defined in `~/.config/zsh/lib/history.zsh:40`
- **Finding:** Alias exists but no evidence of custom `hist` function usage in plugins
- **Verdict:** MARGINAL — Keep if you use `h` command; otherwise remove to save ~2KB load + lazy evaluation

#### `agkozak/zhooks` (deferred)
- **What it does:** Zsh hook utilities library (precmd, chpwd, etc.)
- **Your usage:** **NO MATCHES FOUND** in custom plugins or functions
- **Last update:** Check `/Users/mh/.cache/repos/agkozak/zhooks/.git/refs/heads/master` for staleness
- **Verdict:** **REMOVE** — Unused utility; saves ~5KB + defer overhead

#### `romkatv/zsh-no-ps2` (deferred)
- **What it does:** Removes PS2 prompt in certain scenarios (vi-mode related)
- **Your usage:** **NO MATCHES FOUND** in custom config
- **Verdict:** **AUDIT:** Do you use vi-mode? Check `bindkey -L | grep -i vi`

#### `romkatv/zsh-bench` (commented out ✅)
- **Status:** Already excluded from loading — good call

---

### ⚠️ **OHMYZSH LIBRARIES - Defer Strategy**
**Early load (no defer):**
- `lib/async_prompt.zsh` — Async prompt framework (essential if using async themes)
- `lib/completion.zsh` — Completion system
- `lib/key-bindings.zsh` — Key bindings
- `lib/termsupport.zsh` — Terminal features (title, etc.)

**Deferred (lazy-load):**
- `lib/functions.zsh` — OMZ function library
- `lib/git.zsh` — Git helper functions
- `lib/grep.zsh` — Grep aliases
- `lib/history.zsh` — History functions (OMZ version, separate from your custom)
- `lib/misc.zsh` — Miscellaneous utilities
- `lib/prompt_info_functions.zsh` — Prompt info (not used if not using OMZ theme)
- `lib/spectrum.zsh` — Color spectrum utilities
- `lib/theme-and-appearance.zsh` — Theme utilities (deferred — good)
- `lib/vcs_info.zsh` — VCS info functions

**Verdict:** Defer strategy is solid. Question: Are you using an OMZ theme or custom theme?

---

### ✅ **CUSTOM PLUGINS - Detailed Analysis**

| Plugin | Purpose | Size | **USED?** | Action |
|--------|---------|------|----------|--------|
| `custom/plugins/homebrew` | Brewfile management | ~2KB | Unknown | **AUDIT** |
| `custom/plugins/xdg` | XDG compliance | ~1KB | Yes (required) | KEEP |
| `custom/plugins/dotfiles` | Custom dotfiles setup | ~2KB | Yes (core) | KEEP |
| `custom/plugins/basic-memory` | Memory display function | ~1KB | Probably | **AUDIT** |
| `custom/plugins/mise` | Tool version mgmt | ~2KB | Yes | **FIXED** ✅ |
| `custom/plugins/python` | Py aliases (conda disabled) | ~1KB | Minimal | **CONSIDER REMOVING** |
| `custom/plugins/aliases` | Custom aliases | ? | Yes (core) | KEEP |
| `custom/plugins/otp` | One-time passwords via `otp` command | ~3KB | **AUDIT** (Do you use GPG OTP?) | **AUDIT** |
| `custom/plugins/prj` | Project jump wrapper (requires `prj` binary) | ~0.5KB | **AUDIT** (Is `prj` binary installed?) | **AUDIT** |
| `custom/plugins/ruby` | Ruby PATH + bundler/gem XDG vars | ~1KB | **AUDIT** (Do you use Ruby via mise?) | **AUDIT** |
| `custom/plugins/globalias` | Global alias expansion on space | ~2KB | **AUDIT** (Do you use this UX feature?) | **AUDIT** |

---

## PATH Audit

**Current structure** (from `.zprofile`):
```
$HOME/{,s}bin
$HOME/.local/bin
$HOME/.local/share/mise/shims
/opt/{homebrew,local}/{,s}bin
/usr/local/{,s}bin
/Users/mh/.cache/lm-studio/bin (added by LM Studio)
$path (inherited system PATH = ~50 entries)
```

**Issues:**
- LM Studio adds to PATH at startup (minor)
- Inherited PATH likely has duplicates from old toolchain installations
- No evidence of active Go, Rust, Ruby, Node, Python via PATH (you use `mise`)

**Recommendation:** Run `echo $PATH | tr ':' '\n' | sort -u | wc -l` and audit entries >20 for dead installations

---

## Completions Audit

**25 completion files** (24KB total):
- Essential: `_mise`, `_gh-doctor`, `_git`, `_npm` → Keep
- Custom: `_basic-memory`, `_dots`, `_tdl` → Keep
- Utility: `_ffmpeg`, `_shellcheck`, `_sops`, `_uv` → Audit for active use
- Symlink: `git-completion.bash` → Can be removed if `_git` is sufficient

**No performance issue** — completion cache (.zcompdump) is 57KB and up-to-date

---

## Summary: Plugins to Remove (Conservative)

| Plugin | Reason | Est. Savings |
|--------|--------|---|
| `agkozak/zhooks` | Unused | ~5KB + defer |
| `romkatv/zsh-bench` | Already commented | Cleanup |

**Plugins to Audit (Your Decision):**
- `marlonrichert/zsh-hist` — Keep if you use `h` command
- `romkatv/zsh-no-ps2` — Keep if you use vi-mode
- Custom marginal plugins — Review for active use

**Not Recommended to Remove:**
- OMZ libraries — All have purpose in defer chain
- Zephyr plugins — Foundation of your setup
- Syntax highlighting, autosuggestions, etc. — Essential UX

---

## Next Steps

1. **Verify custom plugin usage:**
   - `otp`, `prj`, `ruby`, `globalias` — Are these actively used?
   - If not, remove from `.zsh_plugins.txt`

2. **Check if using vi-mode:**
   - If YES: keep `romkatv/zsh-no-ps2`
   - If NO: remove it

3. **Verify hist usage:**
   - Do you actually run `h` command?
   - If NO: remove `marlonrichert/zsh-hist`

4. **PATH cleanup (optional):**
   - Run `echo $PATH | tr ':' '\n' | sort -u | while read p; do [[ -d "$p" ]] || echo "DEAD: $p"; done`
   - Remove dead entries from `.zprofile`

---

## Performance Impact

**Estimated impact of removals:**
- Remove `agkozak/zhooks` → -5ms (negligible; already <150ms total)
- Remove unused custom plugins → -10ms (negligible)
- Re-enable ShellHistory → +? (depends on app running; may not notice)

**Verdict:** You're already fast. These are maintenance optimizations, not speed fixes.
