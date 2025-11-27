#!/bin/bash

# Host command execution service to watch for command requests from container and execute them.
# One command can be requested at a time, and is in the form of three lines:
#   - the current working directory,
#   - the command itself,
#   - the command's arguments.

set -e

COMMAND_FILE="$HOME/.docker-dev/command"
LOG_FILE="$HOME/.docker-dev/host-exec.log"
ALLOWED_PATH_PREFIX="$HOME/dev/"

# List of allowed commands and whether they accept arguments
declare -A ALLOWED_COMMANDS=(
	# Sublime Merge has an extremely frustrating bug where all your tabs are cleared
	# if you open it from the command line. The script `open-in-sublime-merge.sh`
	# prevents this. See https://github.com/sublimehq/sublime_merge/issues/309#issuecomment-1668019269
	["/home/alex/dev/config/misc/open-in-sublime-merge.sh"]="true"
	["gnome-terminal"]="false"
)

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

executeCommand() {
	command=$(cat "$COMMAND_FILE" 2>/dev/null)

	log "Received command:
$command"

	if [[ "$command" =~ [\&\|\;\$\`\<\>\(\)\{\}] ]]; then
		log "ERROR: Command contains forbidden characters"
		return
	fi

	rawPath=$(echo "$command" | head -n1)

	if [[ -z "$rawPath" ]]; then
		log "ERROR: Path is empty"
		return
	fi

	# Resolve symlinks, `/../`, etc.
	path=$(realpath "$rawPath")

	# Check the resolved path is under allowed directory
	if [[ "$path" != "$ALLOWED_PATH_PREFIX"* ]]; then
		log "ERROR: Resolved path is outside allowed directory: $path"
		return
	fi

	# Check resolved path is a directory
	if [[ ! -d "$path" ]]; then
		log "ERROR: Resolved path is not a directory: $path"
		return
	fi

	commandName=$(echo "$command" | sed -n '2p')

	if [[ ! -v ALLOWED_COMMANDS["$commandName"] ]]; then
		log "ERROR: Command not allowed: $commandName"
		return
	fi

	if [[ "$commandName" == "gnome-terminal" ]]; then
		log "Executing: gnome-terminal -- docker exec -it -w \"$path\" dev zsh"
		gnome-terminal --working-directory "$path" -- docker exec -it -w "$path" dev zsh &
		log "Command executed successfully"
		return
	fi

	argsAllowed="${ALLOWED_COMMANDS[$commandName]}"

	if [[ "$argsAllowed" == "false" ]]; then
		log "Executing: cd $path && $commandName"
		(cd "$path" && "$commandName") &
	else
		args=$(echo "$command" | sed -n '3p')
		IFS=$'\t' read -ra arg_array <<< "$args"
		log "Executing: cd $path && $commandName ${arg_array[*]}"
		(cd "$path" && "$commandName" "${arg_array[@]}") &
	fi

	log "Command executed successfully"
}

main() {
	log "Starting host-exec-service"

	# Create directory and file if it doesn't exist
	mkdir -p "$(dirname "$COMMAND_FILE")"
	touch "$COMMAND_FILE"

	while true; do
		inotifywait -e modify "$COMMAND_FILE" > /dev/null 2>&1
		sleep 0.1
		executeCommand
		true > "$COMMAND_FILE"
	done
}

trap 'log "Shutting down host-exec-service"; exit 0' SIGTERM SIGINT

main
