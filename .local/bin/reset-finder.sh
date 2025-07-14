#!/bin/sh

set -x

#================================================
# *           CLOSE SYSTEM PREFERENCES
#================================================

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

#================================================
# *           BACKUP
#================================================
# Backup Finder preferences
cp ~/Library/Preferences/com.apple.finder.plist ~/Desktop

#================================================
# *           CONFIGURE
#================================================

rm ~/Library/Preferences/com.apple.finder.plist
rm ~/Library/Preferences/com.apple.sidebarlists.plist

# Show hidden files. (default: false)
defaults write com.apple.finder AppleShowAllFiles -bool true

# Avoid creating .DS_Store files on network or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Automatically open a new Finder window when a volume is mounted.
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use list view in all Finder windows by default.
# Icon View:   "icnv"
# List View:   "Nlsv"
# Column View: "clmv"
# Cover Flow:  "Flwv"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# After configuring preferred view style, clear all `.DS_Store` files
# to ensure settings are applied for every directory
find . -name '.DS_Store' -type f -delete

# Status bar (default: false)
defaults write com.apple.finder ShowStatusBar -bool true

# Path bar
defaults write com.apple.finder ShowPathbar -bool true

# Allow quitting via ⌘ + Q; doing so will also hide desktop icons.
defaults write com.apple.finder QuitMenuItem -bool true

# Disable window animations and Get Info animations.
defaults write com.apple.finder DisableAllAnimations -bool true

# New Finder windows open at $HOME.
# Computer:       "PfCm"
# Volume:         "PfVo"
# $HOME:          "PfHm"
# Desktop:        "PfDe"
# Documents:      "PfDo"
# All My Files:   "PfAF"
# Other:          "PfLo"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"

# Don't show file icons in the desktop.
defaults write com.apple.finder CreateDesktop -bool false

# When performing a search, search the current folder by default.
# This Mac:       "SCev"
# Current Folder: "SCcf"
# Previous Scope: "SCsp"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Display full POSIX path as Finder window title.
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting files by name.
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Show expanded save panel by default.
# https://www.defaults-write.com/expand-save-panel-default/
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Show file extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

# Disable sound effects: trash emptying, screenshot taking, file moving, etc.
defaults write "Apple Global Domain" com.apple.sound.uiaudio.enabled -int 0

#Show The Library Folder
chflags nohidden ~/library/

#================================================
# *           RESTART
#================================================

killall cfprefsd
killall Finder >/dev/null 2>&1
