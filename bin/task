#!/usr/bin/env zsh
# Task Management CLI
# Unified task management system with project-specific directories

set -euo pipefail

# Set nullglob to handle case where no files match patterns
setopt nullglob 2>/dev/null || true

# Default locations
VAULT_TASKS="$VAULT_PATH/02-Projects/TaskManagement/tasks"
EDITOR="${EDITOR:-code}"

# Detect task directory based on context
get_tasks_directory() {
    local current_dir="$PWD"
    
    # Look for project tasks directory by walking up the directory tree
    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/tasks" ]]; then
            echo "$current_dir/tasks"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    # Fall back to vault tasks directory
    echo "$VAULT_TASKS"
}

# Get project name from directory context
get_project_name() {
    local tasks_dir="$1"
    
    if [[ "$tasks_dir" == "$VAULT_TASKS" ]]; then
        echo "General"
    else
        # Extract project name from parent directory
        local project_dir="$(dirname "$tasks_dir")"
        basename "$project_dir"
    fi
}

# Initialize variables
TASKS_DIR="$(get_tasks_directory)"
TEMPLATE_FILE="$TASKS_DIR/.template.md"
PROJECT_NAME="$(get_project_name "$TASKS_DIR")"
GLOBAL_ID_FILE="$VAULT_TASKS/.next_id"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Utility functions
error() { echo -e "${RED}Error: $*${NC}" >&2; exit 1; }
warn() { echo -e "${YELLOW}Warning: $*${NC}" >&2; }
info() { echo -e "${BLUE}Info: $*${NC}"; }
success() { echo -e "${GREEN}Success: $*${NC}"; }

# Get next task ID (globally unique across all projects)
get_next_id() {
    local max_id=0
    
    # Check all task directories for highest ID
    # 1. Current tasks directory
    for file in "$TASKS_DIR"/TASK-*.md; do
        [[ -f "$file" ]] || continue
        local id=$(basename "$file" | sed -n 's/TASK-\([0-9][0-9]*\)-.*/\1/p')
        [[ -n "$id" ]] && ((id > max_id)) && max_id=$id
    done
    
    # 2. Vault tasks directory (if different)
    if [[ "$TASKS_DIR" != "$VAULT_TASKS" ]]; then
        for file in "$VAULT_TASKS"/TASK-*.md; do
            [[ -f "$file" ]] || continue
            local id=$(basename "$file" | sed -n 's/TASK-\([0-9][0-9]*\)-.*/\1/p')
            [[ -n "$id" ]] && ((id > max_id)) && max_id=$id
        done
    fi
    
    # 3. Search common project locations
    for project_dir in ~/Developer/*/ ~/Developer/*/*/; do
        [[ -d "$project_dir/tasks" ]] || continue
        for file in "$project_dir/tasks"/TASK-*.md; do
            [[ -f "$file" ]] || continue
            local id=$(basename "$file" | sed -n 's/TASK-\([0-9][0-9]*\)-.*/\1/p')
            [[ -n "$id" ]] && ((id > max_id)) && max_id=$id
        done
    done
    
    printf "%03d" $((max_id + 1))
}

# Create new task
task_new() {
    [[ $# -eq 0 ]] && error "Usage: task new \"Task Title\" [project] [priority]"
    
    local title="$1"
    local project="${2:-}"
    local priority="${3:-Medium}"
    local date=$(date +%Y-%m-%d)
    local task_id="TASK-$(get_next_id)"
    local slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    local filename="$task_id-$slug.md"
    local filepath="$TASKS_DIR/$filename"
    
    # Check if template exists
    [[ -f "$TEMPLATE_FILE" ]] || error "Template file not found: $TEMPLATE_FILE"
    
    # Create task file from template
    sed -e "s/TASK-XXX/$task_id/g" \
        -e "s/Task Title/$title/g" \
        -e "s/YYYY-MM-DD/$date/g" \
        -e "s/project: \"\"/project: \"$project\"/" \
        -e "s/priority: Medium/priority: $priority/" \
        "$TEMPLATE_FILE" > "$filepath"
    
    success "Created task: $task_id - $title"
    info "File: $filename"
    
    # Open in editor if available
    if command -v "$EDITOR" >/dev/null 2>&1; then
        "$EDITOR" "$filepath"
    fi
    
    # Update index
    task_index
}

# List tasks with optional status filter
task_list() {
    local status_filter="$1"
    local format="${2:-table}"
    
    info "Tasks in $TASKS_DIR:"
    echo
    
    if [[ "$format" == "table" ]]; then
        printf "%-10s %-8s %-10s %-50s %-15s\n" "ID" "Status" "Priority" "Title" "Updated"
        printf "%-10s %-8s %-10s %-50s %-15s\n" "----------" "--------" "----------" "--------------------------------------------------" "---------------"
    fi
    
    local found=0
    for file in "$TASKS_DIR"/TASK-*.md; do
        [[ -f "$file" ]] || continue
        
        local id=$(grep '^id:' "$file" | cut -d' ' -f2)
        local title=$(grep '^title:' "$file" | sed 's/^title: *//')
        local file_status=$(grep '^status:' "$file" | cut -d' ' -f2)
        local priority=$(grep '^priority:' "$file" | cut -d' ' -f2)
        local updated=$(grep '^updated:' "$file" | cut -d' ' -f2)
        
        # Apply status filter
        if [[ -n "$status_filter" && "$file_status" != "$status_filter" ]]; then
            continue
        fi
        
        found=1
        
        if [[ "$format" == "table" ]]; then
            printf "%-10s %-8s %-10s %-50s %-15s\n" "$id" "$file_status" "$priority" "$title" "$updated"
        else
            echo "• $id ($file_status) - $title"
        fi
    done
    
    [[ $found -eq 0 ]] && warn "No tasks found$([ -n "$status_filter" ] && echo " with status: $status_filter")"
}

# Update task status
task_update() {
    [[ $# -eq 0 ]] && error "Usage: task update TASK-ID [new-status]"
    
    local task_id="$1"
    local new_status="${2:-}"
    
    # Find task file
    local task_file
    for file in "$TASKS_DIR"/TASK-*.md; do
        [[ -f "$file" ]] || continue
        if grep -q "^id: $task_id$" "$file"; then
            task_file="$file"
            break
        fi
    done
    
    [[ -z "$task_file" ]] && error "Task not found: $task_id"
    
    # Update status if provided
    if [[ -n "$new_status" ]]; then
        local date=$(date +%Y-%m-%d)
        sed -i '' -e "s/^status: .*/status: $new_status/" \
                  -e "s/^updated: .*/updated: $date/" \
                  "$task_file"
        success "Updated $task_id status to: $new_status"
        task_index
    fi
    
    # Open in editor
    if command -v "$EDITOR" >/dev/null 2>&1; then
        "$EDITOR" "$task_file"
    fi
}

# Complete task shortcut
task_complete() {
    [[ $# -eq 0 ]] && error "Usage: task complete TASK-ID"
    task_update "$1" "Completed"
}

# Generate task index
task_index() {
    local index_file="$TASKS_DIR/_index.md"
    local date=$(date +%Y-%m-%d)
    
    cat > "$index_file" << 'EOF'
# Task Index

## Overview
This file is automatically generated. Do not edit manually.

EOF
    
    echo "**Last Updated**: $date" >> "$index_file"
    echo >> "$index_file"
    
    # Group tasks by status
    for task_status in "Active" "Planned" "Blocked" "Completed" "Abandoned"; do
        echo "## $task_status Tasks" >> "$index_file"
        echo >> "$index_file"
        
        local found=0
        for file in "$TASKS_DIR"/TASK-*.md; do
            [[ -f "$file" ]] || continue
            
            if grep -q "^status: $task_status" "$file"; then
                local id=$(grep '^id:' "$file" | cut -d' ' -f2)
                local title=$(grep '^title:' "$file" | sed 's/^title: *//')
                local updated=$(grep '^updated:' "$file" | cut -d' ' -f2)
                local priority=$(grep '^priority:' "$file" | cut -d' ' -f2)
                
                echo "- **$id** - $title (*$priority*, updated: $updated)" >> "$index_file"
                found=1
            fi
        done
        
        [[ $found -eq 0 ]] && echo "*No $task_status tasks*" >> "$index_file"
        echo >> "$index_file"
    done
    
    info "Updated task index: $index_file"
}

# Show task details
task_show() {
    [[ $# -eq 0 ]] && error "Usage: task show TASK-ID"
    
    local task_id="$1"
    
    # Find and display task
    for file in "$TASKS_DIR"/TASK-*.md; do
        [[ -f "$file" ]] || continue
        if grep -q "^id: $task_id$" "$file"; then
            cat "$file"
            return
        fi
    done
    
    error "Task not found: $task_id"
}

# Initialize project tasks directory
task_init() {
    local current_dir="$PWD"
    local tasks_dir="$current_dir/tasks"
    
    if [[ -d "$tasks_dir" ]]; then
        warn "Tasks directory already exists: $tasks_dir"
        return 1
    fi
    
    mkdir -p "$tasks_dir"
    
    # Copy template from vault if it exists
    if [[ -f "$VAULT_TASKS/.template.md" ]]; then
        cp "$VAULT_TASKS/.template.md" "$tasks_dir/"
    fi
    
    # Create initial index
    cat > "$tasks_dir/_index.md" << 'EOF'
# Task Index

## Overview
This file is automatically generated. Do not edit manually.

**Last Updated**: $(date +%Y-%m-%d)

## Active Tasks

*No Active tasks*

## Planned Tasks

*No Planned tasks*

## Blocked Tasks

*No Blocked tasks*

## Completed Tasks

*No Completed tasks*

## Abandoned Tasks

*No Abandoned tasks*

EOF
    
    success "Initialized tasks directory: $tasks_dir"
    info "Project: $(basename "$current_dir")"
}

# Show context information
task_context() {
    info "Task Management Context:"
    echo
    echo "Current Directory: $PWD"
    echo "Tasks Directory: $TASKS_DIR"
    echo "Project Name: $PROJECT_NAME"
    echo "Template File: $TEMPLATE_FILE"
    echo "Vault Location: $VAULT_TASKS"
    echo
    
    if [[ "$TASKS_DIR" == "$VAULT_TASKS" ]]; then
        echo "📁 Using global vault tasks"
    else
        echo "📁 Using project-specific tasks"
    fi
    
    echo "📊 Task counts:"
    for task_status in "Active" "Planned" "Blocked" "Completed" "Abandoned"; do
        local count=0
        for file in "$TASKS_DIR"/TASK-*.md; do
            [[ -f "$file" ]] || continue
            if grep -q "^status: $task_status" "$file" 2>/dev/null; then
                ((count++))
            fi
        done
        echo "   $task_status: $count"
    done
}

# Main command dispatcher
main() {
    [[ ! -d "$TASKS_DIR" ]] && mkdir -p "$TASKS_DIR"
    
    case "${1:-help}" in
        new|n)
            shift
            task_new "$@"
            ;;
        list|ls|l)
            task_list "${2:-}" "${3:-table}"
            ;;
        update|u)
            shift
            task_update "$@"
            ;;
        complete|done|c)
            shift
            task_complete "$@"
            ;;
        show|s)
            shift
            task_show "$@"
            ;;
        index|i)
            task_index
            ;;
        init)
            task_init
            ;;
        context|ctx)
            task_context
            ;;
        help|h|--help|-h)
            cat << 'EOF'
Task Management CLI

Usage: task <command> [arguments]

Commands:
  new <title> [project] [priority]  Create new task
  list [status] [format]           List tasks (optionally filtered)
  update <id> [status]             Update/edit task
  complete <id>                    Mark task as completed
  show <id>                        Display task details
  index                            Regenerate task index
  init                             Initialize project tasks directory
  context                          Show current context and statistics
  help                             Show this help

Status Values: Planned, Active, Blocked, Completed, Abandoned
Priority Values: Low, Medium, High, Critical
Format Values: table, simple

Examples:
  task new "Fix zsh startup performance" Dotfiles High
  task list Active
  task update TASK-001 Active
  task complete TASK-001
  task show TASK-001

EOF
            ;;
        *)
            error "Unknown command: $1. Use 'task help' for usage."
            ;;
    esac
}

main "$@"
