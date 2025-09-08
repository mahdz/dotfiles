#!/bin/bash

mdfind -onlyin /Applications 'kMDItemWhereFroms != ""' | xargs -I {} xattr -d com.apple.quarantine "{}"
