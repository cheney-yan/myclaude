# Claude Code Complete Setup Guide

Your Claude Code configuration has been set up from scratch using best practices with full Dropbox integration.

## 🏗️ Complete Architecture

```
Repository (Source of Truth)
/Users/cheney/code/tools/myclaude/
├── settings.json             ← Global Claude settings (NEW!)
├── CLAUDE.md                 ← Project instructions
├── agents/                   ← 24 agent configurations
├── commands/                 ← 49 command configurations
├── sync-claude-dropbox.sh    ← Enhanced sync script
├── update-claude             ← Quick wrapper
└── [documentation files]

                    ↓ sync

Dropbox Cloud Storage
~/Dropbox/claude/
├── settings.json             ← Global settings (NEW!)
├── CLAUDE.md                 ← Project instructions
├── agents/                   ← 24 agent configurations
├── commands/                 ← 49 command configurations
└── [documentation files]

                    ↑ symlink

Claude Code Configuration
~/.claude/
├── settings.json → ~/Dropbox/claude/settings.json    ← NEW!
├── CLAUDE.md → ~/Dropbox/claude/CLAUDE.md
├── agents → ~/Dropbox/claude/agents
├── commands → ~/Dropbox/claude/commands
├── projects/                 ← Project-specific overrides
├── shell-snapshots/          ← Session history
├── todos/                    ← Todo tracking
├── ide/                      ← IDE integration
└── local/                    ← Local Claude installation
```

## ⚙️ Settings Configuration

Your `settings.json` includes Claude Code best practices:

### 🔒 Security Settings
- **Permissions**: Denies access to sensitive files (.env, secrets, .aws, .ssh, private)
- **Tool Control**: Explicit allowlist of safe tools
- **Environment Protection**: Prevents writing to sensitive locations

### 🎨 User Experience
- **Model**: Claude Opus 4.1 (latest)
- **Theme**: Dark mode
- **Output Style**: Explanatory (educational insights)
- **Auto Updates**: Enabled
- **Memory**: Enabled for context retention

### 🛠️ Development Features
- **Telemetry**: Enabled for improvements
- **Hooks**: Ready for custom pre/post-tool commands
- **Context Window**: Auto-sizing for optimal performance

## 🚀 Usage Commands

### Quick Operations
```bash
./update-claude                    # Full sync + setup
./update-claude --status          # Show current status
```

### Advanced Operations
```bash
./sync-claude-dropbox.sh --help   # Show all options
./sync-claude-dropbox.sh --verify # Verify setup integrity
./sync-claude-dropbox.sh --cleanup # Clean old configurations
```

### Granular Control
```bash
./sync-claude-dropbox.sh --sync-only   # Only sync files
./sync-claude-dropbox.sh --link-only   # Only setup symlinks
./sync-claude-dropbox.sh --no-backup   # Skip backup creation
```

### 🔄 Bidirectional Sync (NEW!)
```bash
# Check for live configuration changes
./update-claude --check           # Check if live config differs from repo
./update-claude --diff            # Show detailed differences

# Pull live changes back to repository
./update-claude --pull            # Pull changes from live config
./update-claude --pull --git-status  # Pull + show git status

# Git integration
./update-claude --git-status      # Show what needs to be committed
```

## 🔍 Configuration Discovery Sequence

Claude Code follows this hierarchy when loading configuration:

1. **Project Level** (Highest Priority)
   - `./CLAUDE.md` - Project-specific instructions
   - `./agents/` - Project-specific agents (if exists)
   - `./commands/` - Project-specific commands (if exists)

2. **Global Level** (Fallback)
   - `~/.claude/settings.json` → `~/Dropbox/claude/settings.json`
   - `~/.claude/CLAUDE.md` → `~/Dropbox/claude/CLAUDE.md`
   - `~/.claude/agents/` → `~/Dropbox/claude/agents/`
   - `~/.claude/commands/` → `~/Dropbox/claude/commands/`

3. **System Level** (Defaults)
   - Built-in Claude Code defaults

## ✅ Verification Checklist

Run this to verify your setup:

```bash
./sync-claude-dropbox.sh --verify
```

Expected results:
- ✅ Dropbox target directory exists
- ✅ All key files found in Dropbox
- ✅ All symlinks verified and pointing correctly
- ✅ Settings.json properly linked
- ✅ 24 agents available
- ✅ 49 commands available

## 🌐 Multi-Device Benefits

Your configuration now automatically syncs across all devices:

1. **Make changes** in this repository
2. **Run sync** with `./update-claude`
3. **Dropbox syncs** to all your devices
4. **Claude Code** uses updated config everywhere

## 🔄 Bidirectional Sync Workflow

The enhanced sync system now supports pulling live changes back to your repository:

### Typical Workflow
```bash
# 1. Check if live configuration has changes
./update-claude --check

# 2. If changes detected, see what changed
./update-claude --diff

# 3. Pull changes back to repository
./update-claude --pull

# 4. Review and commit changes
./update-claude --git-status
git add .
git commit -m "Update Claude configuration from live changes"
```

### Use Cases
- **Live Edits**: Pull back changes made directly to `~/.claude/` files
- **Multi-Device**: Sync changes from other devices via Dropbox
- **Collaboration**: Pull shared configuration updates
- **Recovery**: Restore repository from live configuration backup

## 🔧 Maintenance

### Regular Updates
```bash
./update-claude  # After making changes
```

### Health Checks
```bash
./sync-claude-dropbox.sh --status   # Check current state
./sync-claude-dropbox.sh --verify   # Verify integrity
```

### Troubleshooting
```bash
./sync-claude-dropbox.sh --cleanup  # Clean old setups
./sync-claude-dropbox.sh            # Full re-setup
```

## 📁 What's Managed

### Repository-Controlled (Version Controlled)
- ✅ `settings.json` - Global Claude settings
- ✅ `CLAUDE.md` - Project instructions
- ✅ `agents/` - Agent configurations
- ✅ `commands/` - Command configurations
- ✅ Documentation files

### Auto-Generated (Not Version Controlled)
- `~/.claude/projects/` - Project-specific data
- `~/.claude/shell-snapshots/` - Session history
- `~/.claude/todos/` - Todo tracking
- `~/.claude/local/` - Local installation files

## 🎯 Key Improvements

1. **Settings Management**: `settings.json` now lives in your repository
2. **Complete Setup**: Full `.claude` directory structure from scratch
3. **Enhanced Security**: Comprehensive permission controls
4. **Better Verification**: Multi-level integrity checks
5. **Dropbox Integration**: Direct cloud sync without intermediate layers
6. **Best Practices**: Following official Claude Code recommendations
7. **🆕 Bidirectional Sync**: Pull live changes back to repository for version control
8. **🆕 Change Detection**: Automatically detect differences between repo and live config
9. **🆕 Git Integration**: Smart git status and commit suggestions

Your Claude Code setup is now complete and production-ready!