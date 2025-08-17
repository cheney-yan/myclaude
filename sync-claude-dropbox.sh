#!/bin/bash

# Claude Configuration Sync Script
# Syncs personal Claude configuration to a target directory.
# Supports Dropbox linking or direct copy based on environment variables.

set -e # Exit on any error

# --- Configuration ---
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
# Excluded items for sync/comparison
EXCLUDED_ITEMS=("ide" "local" "projects" "shell-snapshots" "statsig" "todos" "~" .git .history .gitignore sync-claude-dropbox.sh)
DROPBOX_FOLDER=${DROPBOX_FOLDER:-"$HOME/Dropbox"}

# --- Colors and Logging ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}
success() {
    echo -e "${GREEN}✓${NC} $1"
}
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}
error() {
    echo -e "${RED}✗${NC} $1"
}
info() {
    echo -e "${PURPLE}ℹ${NC} $1"
}

# --- Environment and Mode Detection ---
SYNC_MODE="copy"
TARGET_DIR="$CLAUDE_DIR" # Default to local copy

if [[ -n "$DROPBOX_FOLDER" ]]; then
    # Expand tilde in DROPBOX_FOLDER, in case it's passed literally
    DROPBOX_FOLDER="${DROPBOX_FOLDER/#\~/$HOME}"
    
    SYNC_MODE="dropbox"
    TARGET_DIR="$DROPBOX_FOLDER/claude"
    info "DROPBOX_FOLDER is set. Using Dropbox sync mode."
    info "Target directory: $TARGET_DIR"
else
    info "DROPBOX_FOLDER not set or invalid. Using local copy mode."
    info "Target directory: $CLAUDE_DIR"
fi

# --- Command Functions ---

command_sync() {
    log "Executing 'sync' command..."
    
    # Ensure target directory exists
    mkdir -p "$TARGET_DIR"

    # Use rsync for efficient synchronization
    if ! command -v rsync &> /dev/null; then
        error "rsync command not found. Please install rsync to proceed."
        exit 1
    fi

    log "Syncing files from $SOURCE_DIR to $TARGET_DIR..."

    local rsync_opts="-av --backup --backup-dir=$TARGET_DIR/backup-$(date +%Y%m%d-%H%M%S) --suffix=.backup"
    
    # Construct exclude options for rsync
    local exclude_opts=""
    for item in "${EXCLUDED_ITEMS[@]}"; do
        exclude_opts+="--exclude=$item "
    done

    # Add an exclude for the backup files themselves
    exclude_opts+="--exclude='*.backup' --exclude='backup-*' "

    # Perform the sync
    rsync $rsync_opts $exclude_opts "$SOURCE_DIR/" "$TARGET_DIR/"

    success "'sync' command finished."
}

command_link_dropbox() {
    log "Executing 'link' command..."

    if [[ "$SYNC_MODE" != "dropbox" ]]; then
        warning "The 'link' command is only applicable in Dropbox sync mode."
        return
    fi

    if [[ ! -d "$TARGET_DIR" ]]; then
        error "Target directory $TARGET_DIR does not exist. Run 'sync' first."
        exit 1
    fi

    log "Linking $CLAUDE_DIR to $TARGET_DIR..."

    # Handle existing item at the destination
    if [[ -L "$CLAUDE_DIR" ]]; then
        if [[ "$(readlink "$CLAUDE_DIR")" == "$TARGET_DIR" ]]; then
            success "Symlink already correct: $CLAUDE_DIR -> $TARGET_DIR"
            return
        fi
        log "Removing incorrect symlink at $CLAUDE_DIR"
        rm -f "$CLAUDE_DIR"
    elif [[ -d "$CLAUDE_DIR" ]]; then
        local backup_path="${CLAUDE_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
        log "Backing up existing directory $CLAUDE_DIR to $backup_path"
        mv "$CLAUDE_DIR" "$backup_path"
    elif [[ -e "$CLAUDE_DIR" ]]; then
        error "$CLAUDE_DIR exists but is not a directory or a symlink. Please handle this manually."
        exit 1
    fi

    # Create the symlink
    ln -s "$TARGET_DIR" "$CLAUDE_DIR"
    success "Created symlink: $CLAUDE_DIR -> $TARGET_DIR"
}

command_pull() {
    log "Executing 'pull' command..."

    if [[ ! -d "$TARGET_DIR" ]]; then
        error "Target directory $TARGET_DIR does not exist. Nothing to pull."
        exit 1
    fi

    if ! command -v rsync &> /dev/null; then
        error "rsync command not found. Please install rsync to proceed."
        exit 1
    fi

    log "Pulling files from $TARGET_DIR to $SOURCE_DIR..."

    local rsync_opts="-av --delete"
    
    # Construct exclude options for rsync
    local exclude_opts=""
    for item in "${EXCLUDED_ITEMS[@]}"; do
        exclude_opts+="--exclude=$item "
    done
    
    # Also exclude backup files from being pulled
    exclude_opts+="--exclude='*.backup' --exclude='backup-*' "

    # Perform the pull (sync from target to source)
    rsync $rsync_opts $exclude_opts "$TARGET_DIR/" "$SOURCE_DIR/"

    success "'pull' command finished."
}

command_check() {
    log "Executing 'check' command..."
    
    if ! command -v diff &> /dev/null; then
        error "diff command not found. Please ensure you have standard Unix utilities."
        exit 1
    fi

    local exclude_opts=""
    for item in "${EXCLUDED_ITEMS[@]}"; do
        exclude_opts+="--exclude=$item "
    done
    
    # Also exclude backup files from being checked
    exclude_opts+="--exclude='*.backup' --exclude='backup-*' "

    if diff -qr $exclude_opts "$SOURCE_DIR" "$TARGET_DIR"; then
        success "Source and target are in sync."
    else
        warning "Differences detected. Use the 'diff' command to see details."
    fi
    
    success "'check' command finished."
}

command_diff() {
    log "Executing 'diff' command..."

    if ! command -v diff &> /dev/null; then
        error "diff command not found. Please ensure you have standard Unix utilities."
        exit 1
    fi

    local exclude_opts=""
    for item in "${EXCLUDED_ITEMS[@]}"; do
        exclude_opts+="--exclude=$item "
    done

    # Also exclude backup files from the diff
    exclude_opts+="--exclude='*.backup' --exclude='backup-*' "

    diff -urN $exclude_opts "$SOURCE_DIR" "$TARGET_DIR" || true
    
    success "'diff' command finished."
}

command_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Manages Claude configuration synchronization."
    echo ""
    echo "Commands:"
    echo "  sync (default)   Syncs configuration from the repository to the target."
    echo "  link             (Dropbox mode only) Links ~/.claude to the Dropbox target."
    echo "  pull             Pulls configuration from the target back to the repository."
    echo "  check            Checks for differences between the repository and the target."
    echo "  diff             Shows a detailed diff between the repository and the target."
    echo "  help             Shows this help message."
    echo ""
    echo "Environment Variables:"
    echo "  DROPBOX_FOLDER   If set to a valid directory, enables Dropbox sync mode."
    echo "                   Example: export DROPBOX_FOLDER=\"\$HOME/Dropbox\""
}

# --- Main Execution ---

auto_link_if_needed() {
    if [[ "$SYNC_MODE" != "dropbox" ]]; then
        return
    fi

    log "Verifying Dropbox link..."

    if [[ ! -d "$TARGET_DIR" ]]; then
        info "Target directory $TARGET_DIR does not exist. Run 'sync' to create it."
        return
    fi

    if [[ -L "$CLAUDE_DIR" ]] && [[ "$(readlink "$CLAUDE_DIR")" == "$TARGET_DIR" ]]; then
        success "Dropbox link is correctly set up."
    else
        warning "Dropbox link for $CLAUDE_DIR is incorrect or missing."
        info "Automatic setup of Dropbox link required."
        command_link_dropbox
    fi
}

main() {
    local command="${1:-sync}" # Default to 'sync' if no command is provided

    if [[ "$command" == "sync" ]]; then
        command_sync
        auto_link_if_needed
    else
        # For other commands, we still want to ensure the link is correct before running them
        auto_link_if_needed
        case "$command" in
            link)
                command_link_dropbox
                ;;
            pull)
                command_pull
                ;;
            check)
                command_check
                ;;
            diff)
                command_diff
                ;;
            help)
                command_help
                ;;
            *)
                error "Unknown command: $command"
                command_help
                exit 1
                ;;
        esac
    fi
}

# Run main function with all arguments
main "$@"