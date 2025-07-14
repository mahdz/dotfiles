#!/usr/bin/env bash

# ai-commit-msg.sh
# Generate a commit message for a local Git repository using OpenAI GPT-4o API.
# Requires OpenAI API key, which should be set in the OPENAI_API_KEY environment variable.

set -e

# Check for required dependencies: curl, git, and jq.
for cmd in curl git jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not installed." >&2
        exit 1
    fi
done

# Validate that the OpenAI API key is set
if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "Error: The OPENAI_API_KEY environment variable is not set." >&2
    exit 1
fi

# Function to get recent commit messages
get_recent_commits() {
    git log -3 --pretty=format:"%B" | sed 's/"/\\"/g'
}

# Function to get Git diff
get_git_diff() {
    git diff --cached
}

# Function to call OpenAI GPT-4o API
call_openai_api() {
    local prompt="$1"
    local api_response

    # Construct the OpenAI API payload
    local payload=$(jq -n \
        --arg model "gpt-4o" \
        --arg system_content "You are a helpful assistant that writes git commit messages." \
        --arg user_content "$prompt" \
        '{
            model: $model,
            messages: [
                {role: "system", content: $system_content},
                {role: "user", content: $user_content}
            ],
            temperature: 0.7,
            max_tokens: 200
        }')

    # Send the request to the OpenAI API
    api_response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$payload")

    # Extract the generated commit message using jq
    echo "$api_response" | jq -r '.choices[0].message.content' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Main script
main() {
    echo "Generating commit message using OpenAI GPT-4o..."

    # Fetch recent commit messages
    recent_commits=$(get_recent_commits)

    # Fetch the staged Git diff
    diff_context=$(get_git_diff)

    if [[ -z "$diff_context" ]]; then
        echo "Error: No changes staged for commit. Stage changes before running this script." >&2
        exit 1
    fi

    # Construct the full prompt
    full_prompt="Generate a git commit message following this structure:
1. First line: conventional commit format (type: concise description) (remember to use semantic types like feat, fix, docs, style, refactor, perf, test, chore, etc.)
2. Optional bullet points if more context helps:
   - Keep the second line blank
   - Keep them short and direct
   - Focus on what changed
   - Always be terse
   - Don't overly explain
   - Drop any fluffy or formal language

Return ONLY the commit message - no introduction, no explanation, no quotes around it.

Examples:
feat: add user auth system

- Add JWT tokens for API auth
- Handle token refresh for long sessions

fix: resolve memory leak in worker pool

- Clean up idle connections
- Add timeout for stale workers

Simple change example:
fix: typo in README.md

Very important: Do not respond with any of the examples. Your message must be based off the diff that is about to be provided, with a little bit of styling informed by the recent commits you're about to see.

Recent commits from this repo (for style reference):
$recent_commits

Here's the diff:

$diff_context"

    # Generate the commit message
    commit_message=$(call_openai_api "$full_prompt")

    if [[ -z "$commit_message" ]]; then
        echo "Error: Failed to generate commit message." >&2
        exit 1
    fi

    echo "Generated commit message:"
    echo "----------------------------------------"
    echo "$commit_message"
    echo "----------------------------------------"

    # Prompt user for confirmation
    read -p "Do you want to use this commit message? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        git commit -m "$commit_message"
        echo "Commit created successfully!"
    else
        echo "Commit aborted."
    fi
}

main "$@"
