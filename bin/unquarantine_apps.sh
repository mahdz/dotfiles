#!/bin/bash
# macOS Application Unquarantine Script
#
# PURPOSE:
#   Removes macOS quarantine attributes from all applications in /Applications
#   that were downloaded from the internet, eliminating "unidentified developer" warnings.
#
# WHAT IT DOES:
#   1. Finds all apps in /Applications that have download origin metadata
#   2. Removes the com.apple.quarantine extended attribute from each app
#   3. Allows apps to run without security warnings (use with caution)
#
# USAGE:
#   ./unquarantine_apps.sh
#
# TECHNICAL DETAILS:
#   - Uses mdfind to search Spotlight metadata for apps with download origins
#   - kMDItemWhereFroms != "" finds files with non-empty download source info
#   - xattr -d removes the quarantine extended attribute per app
#   - Only processes apps in /Applications directory for safety
#
# SECURITY WARNING:
#   This script bypasses macOS security protections. Only run on trusted applications.
#   Consider reviewing each app individually if security is a primary concern.
#
# COMMON USE CASES:
#   - After mass app installations from trusted sources
#   - Setting up new development environments
#   - Batch processing of known-safe applications

set -euo pipefail

# Find all applications in /Applications that have download origin metadata
# and remove the quarantine attribute that causes security warnings
mdfind -onlyin /Applications 'kMDItemWhereFroms != ""' | xargs -I {} xattr -d com.apple.quarantine "{}"
