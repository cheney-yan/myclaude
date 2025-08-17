# Claude Configuration Dropbox Setup

This document explains how your Claude configuration is now synced via Dropbox.

## 🏗️ Architecture

```
Your Project Folder
├── sync-claude-dropbox.sh    ← Main sync script
├── update-claude             ← Quick wrapper script
└── [agents/, commands/, etc] ← Source configuration

                    ↓ sync

~/Dropbox/claude/
├── agents/                   ← 24 agent configurations
├── commands/                 ← 49 command configurations
├── CLAUDE.md                 ← Project instructions
└── [other config files]      ← Additional documentation

                    ↑ symlink

~/.claude/
├── agents → ~/Dropbox/claude/agents
├── commands → ~/Dropbox/claude/commands
└── CLAUDE.md → ~/Dropbox/claude/CLAUDE.md
```

## 🚀 Usage

### Quick Sync
```bash
./update-claude              # Full sync + setup
```

### Advanced Options
```bash
./sync-claude-dropbox.sh --help     # Show all options
./sync-claude-dropbox.sh --status   # Show current status
./sync-claude-dropbox.sh --verify   # Verify setup
./sync-claude-dropbox.sh --cleanup  # Clean old Google Drive setup
```

### Sync Options
```bash
./sync-claude-dropbox.sh --sync-only   # Only sync files to Dropbox
./sync-claude-dropbox.sh --link-only   # Only setup symlinks
./sync-claude-dropbox.sh --no-backup   # Skip backup creation
```

## 🔍 How Claude Code Finds Your Config

1. **Project Level**: Checks current directory for `CLAUDE.md` (highest priority)
2. **Global Level**: Falls back to `~/.claude/` for agents, commands, and global CLAUDE.md
3. **Dropbox Sync**: `~/.claude/` symlinks transparently point to `~/Dropbox/claude/`
4. **Multi-Device**: Dropbox automatically syncs changes across all your devices

## ✅ Benefits of Dropbox Setup

- **Direct Sync**: No intermediate Google Drive dependency
- **Faster Access**: Direct symlinks to Dropbox folder
- **Multi-Device**: Automatic sync across all devices with Dropbox
- **Backup Safe**: Automatic backups before changes
- **Transparent**: Claude Code doesn't know about Dropbox - it just works
- **Flexible**: Can easily switch back or use different cloud providers

## 🛠️ Troubleshooting

### Check Status
```bash
./update-claude --status
```

### Verify Setup
```bash
./sync-claude-dropbox.sh --verify
```

### Re-setup Everything
```bash
./sync-claude-dropbox.sh --cleanup  # Clean old setup
./sync-claude-dropbox.sh            # Full setup
```

### Manual Verification
```bash
ls -la ~/.claude/                   # Check symlinks
ls -la ~/Dropbox/claude/            # Check Dropbox contents
```

## 📁 What Gets Synced

- ✅ `CLAUDE.md` - Main project instructions
- ✅ `agents/` - All agent configurations (24 files)
- ✅ `commands/` - All command configurations (49 files)  
- ✅ `README.md` - Documentation
- ✅ Additional `.md` files - Extra documentation

## 🔄 Migration from Google Drive

The script automatically handles migration:

1. **Cleanup**: `./sync-claude-dropbox.sh --cleanup` removes old Google Drive symlinks
2. **Setup**: `./sync-claude-dropbox.sh` creates new Dropbox-based setup
3. **Verify**: Built-in verification ensures everything works correctly

Your old Google Drive setup remains untouched - only the symlinks are changed.