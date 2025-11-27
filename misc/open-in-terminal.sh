#!/bin/bash

# This script opens the path passed as argument into, either a terminal
# session inside the dev container, or a regular one if the directory
# contains a file named `.nocontainer`.

set -e

# Check if .nocontainer file exists in the git root
if [[ -f "$1/.nocontainer" ]]; then
	# Open regular terminal
	gnome-terminal
else
	# Open terminal in dev container
	gnome-terminal -- docker exec -it -w "$1" dev zsh
fi
