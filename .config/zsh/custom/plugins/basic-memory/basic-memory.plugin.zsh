# Basic Memory Helper Functions

export BASIC_MEMORY_FORCE_LOCAL=true
export BASIC_MEMORY_NO_ANALYTICS=1
export BASIC_MEMORY_PROJECT_ROOT="/Users/mh/Library/Mobile Documents/iCloud~md~obsidian/Documents"
export BASIC_MEMORY_LOG_LEVEL="DEBUG"


# Reset and reindex the "main" project
bm-reset-main() {
  local project="${1:-main}"
  
  echo "🔄 Resetting and reindexing project: $project"
  echo ""
  
  # Reset and reindex
  echo "Resetting database and reindexing..."
  basic-memory reset --reindex
  
  # Show project info
  echo ""
  echo "✅ Reset and reindex complete!"
  echo ""
  basic-memory project info "$project"
}

# Aliases for convenience
alias bmr='bm-reset-main'
alias bmi='basic-memory project info main'
