#!/bin/bash

# This script resolves the closest Git repository from the path passed as argument
# (or the current working directory if no argument is provided), and opens it into,
# either a VS Code window attached to the dev container, or a regular one if
# the directory contains a file named `.nocontainer`.

set -e

# If no arguments, use current directory
if [[ $# -eq 0 ]]; then
	# Find git root from current directory
	GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

	if [[ -z "$GIT_ROOT" ]]; then
			echo "Error: Not in a git repository"
			exit 1
	fi

	# Check if .nocontainer file exists
	if [[ -f "$GIT_ROOT/.nocontainer" ]]; then
			code "$GIT_ROOT"
	else
			CONTAINER_URI="vscode-remote://attached-container+7b22636f6e7461696e65724e616d65223a222f646576227d"
			code --folder-uri "${CONTAINER_URI}${GIT_ROOT}"
	fi
	exit 0
fi

# Check for correct usage with -g flag
if [[ "$1" != "-g" ]] || [[ -z "$2" ]]; then
	echo "Usage: $0 [-g <file-path>:<line-number>:<column-number>]"
	exit 1
fi

# Parse the file-path:line:column format
ARG="$2"
FILE_PATH="${ARG%%:*}"
TEMP="${ARG#*:}"
LINE_NUMBER="${TEMP%%:*}"
COLUMN_NUMBER="${TEMP#*:}"

# Convert to absolute path if needed
FILE_PATH=$(realpath "$FILE_PATH" 2>/dev/null)
if [[ $? -ne 0 ]] || [[ ! -f "$FILE_PATH" ]]; then
	echo "Error: File not found: $FILE_PATH"
	exit 1
fi

# Find the git root from the file's directory
FILE_DIR=$(dirname "$FILE_PATH")
GIT_ROOT=$(cd "$FILE_DIR" && git rev-parse --show-toplevel 2>/dev/null)

if [[ -z "$GIT_ROOT" ]]; then
	echo "Error: Not in a git repository"
	exit 1
fi

# Check if .nocontainer file exists in the git root
if [[ -f "$GIT_ROOT/.nocontainer" ]]; then
	# Use normal VS Code command
	code "$GIT_ROOT" -g "$FILE_PATH:$LINE_NUMBER:$COLUMN_NUMBER"
else
	# Use remote container format
	CONTAINER_URI="vscode-remote://attached-container+7b22636f6e7461696e65724e616d65223a222f646576227d"
	code --folder-uri "${CONTAINER_URI}${GIT_ROOT}" --file-uri "${CONTAINER_URI}${FILE_PATH}"
fi
