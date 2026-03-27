# Setup guide — claude-agent-mesh

Complete installation and configuration reference for macOS, Windows, and Linux.

---

## Contents

1. [Prerequisites](#prerequisites)
2. [Installation — macOS](#installation--macos)
3. [Installation — Windows](#installation--windows)
4. [Installation — Linux](#installation--linux)
5. [Verifying the install](#verifying-the-install)
6. [Project vs global install](#project-vs-global-install)
7. [Using the installer flags](#using-the-installer-flags)
8. [Manual install (no bash)](#manual-install-no-bash)
9. [First run](#first-run)
10. [Configuration](#configuration)
11. [Updating](#updating)
12. [Uninstalling](#uninstalling)
13. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### What you need

| Requirement | Notes |
|-------------|-------|
| **Claude Code** | The Anthropic CLI. Install from [claude.ai/code](https://claude.ai/code) |
| **Git** | For cloning the repo |
| **bash** | Comes with macOS and Linux; on Windows use Git Bash or WSL |

### What you do NOT need

- Node.js
- Python (only needed if you want to run the CI validation scripts locally)
- Any API keys beyond your existing Claude Code authentication
- Admin/root access (the installer only writes to your project directory)

---

## Installation — macOS

macOS ships with bash and git. No additional setup required.

### Step 1 — Install Claude Code

If you haven't already:
```bash
# Visit https://claude.ai/code and follow the installer
# Or if you have npm:
npm install -g @anthropic-ai/claude-code
```

Verify it's working:
```bash
claude --version
```

### Step 2 — Clone claude-agent-mesh

Clone it somewhere permanent — you'll reference it each time you install into a new project. A good location is your home directory or a tools folder.

```bash
# Recommended: keep it in ~/tools/ or ~/claude-tools/
mkdir -p ~/tools
cd ~/tools
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git
```

### Step 3 — Install into your project

```bash
# Navigate to your project
cd ~/Projects/my-project

# Run the installer
bash ~/tools/Claude-agent-mesh/install.sh
```

Or use the `--dir` flag to install into a specific location without cd-ing there:
```bash
bash ~/tools/Claude-agent-mesh/install.sh --dir=~/Projects/my-project
```

### Step 4 — Open Claude Code and run

```bash
cd ~/Projects/my-project
claude
```

Inside Claude Code:
```
/mesh describe your task here
```

---

## Installation — Windows

Windows requires a bash-compatible shell. There are three options, in order of recommendation.

---

### Option A — Git Bash (quickest setup)

Git Bash is included with [Git for Windows](https://git-scm.com/download/win). It gives you a bash shell without requiring WSL.

#### Install Git for Windows

1. Download from [git-scm.com/download/win](https://git-scm.com/download/win)
2. During installation:
   - Leave defaults unless you have a reason to change them
   - Ensure "Git Bash Here" is checked in the Windows Explorer integration step

#### Open Git Bash

Right-click any folder in Windows Explorer → **"Git Bash Here"**

Or launch from the Start Menu: **Git Bash**

#### Clone the repo

```bash
# Git Bash uses Unix paths. C:\ is /c/
mkdir -p /c/tools
cd /c/tools
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git
```

#### Install into your project

```bash
# Navigate to your project
cd /c/Users/YourName/Projects/my-project

# Run the installer
bash /c/tools/Claude-agent-mesh/install.sh
```

#### Open Claude Code

```bash
# In Git Bash:
claude
```

Or open Claude Code normally from Windows and navigate to your project directory.

---

### Option B — WSL2 (most compatible)

WSL2 (Windows Subsystem for Linux) runs a full Linux environment alongside Windows. It is the most compatible option for development tooling.

#### Install WSL2

Open **PowerShell as Administrator** and run:
```powershell
wsl --install
```

This installs WSL2 with Ubuntu by default. Restart when prompted.

After restart, open **Ubuntu** from the Start Menu and complete the initial setup (create a username and password).

Verify:
```bash
wsl --version
```

#### Install Claude Code in WSL

```bash
# In your WSL terminal:
npm install -g @anthropic-ai/claude-code
# Or follow the install instructions at claude.ai/code for Linux
```

#### Clone and install

```bash
# In WSL terminal:
mkdir -p ~/tools
cd ~/tools
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git

# Navigate to your project
# Windows drives are mounted at /mnt/c/, /mnt/d/, etc.
cd /mnt/c/Users/YourName/Projects/my-project

# Install
bash ~/tools/Claude-agent-mesh/install.sh
```

#### Open Claude Code from WSL

```bash
claude
```

**WSL path tip:** If your project lives on a Windows drive, access it at `/mnt/c/Users/YourName/...`. For best performance, keep projects inside WSL's filesystem at `~/Projects/` rather than on the Windows drive.

---

### Option C — PowerShell / Command Prompt (manual install)

If you cannot use bash, copy the files manually.

```powershell
# 1. Clone the repo
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git C:\tools\Claude-agent-mesh

# 2. Create the commands directory in your project
New-Item -ItemType Directory -Force -Path "C:\Projects\my-project\.claude\commands"

# 3. Copy all command files
Copy-Item "C:\tools\Claude-agent-mesh\.claude\commands\*.md" `
          "C:\Projects\my-project\.claude\commands\"

# 4. Add .mesh entries to .gitignore
$gitignore = "C:\Projects\my-project\.gitignore"
if (Test-Path $gitignore) {
    $content = Get-Content $gitignore
    if ($content -notcontains ".mesh/") {
        Add-Content $gitignore "`n.mesh/`n.mesh-archive/"
    }
} else {
    Set-Content $gitignore ".mesh/`n.mesh-archive/"
}

Write-Host "Done. Open Claude Code in C:\Projects\my-project and run /mesh"
```

---

## Installation — Linux

### Ubuntu / Debian

```bash
# Install Claude Code (follow instructions at claude.ai/code)
# Or via npm:
npm install -g @anthropic-ai/claude-code

# Clone
mkdir -p ~/tools
cd ~/tools
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git

# Install into your project
cd ~/Projects/my-project
bash ~/tools/Claude-agent-mesh/install.sh
```

### Fedora / RHEL / CentOS

```bash
# Same as Ubuntu — bash is pre-installed
mkdir -p ~/tools
cd ~/tools
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git
bash ~/tools/Claude-agent-mesh/install.sh --dir=~/Projects/my-project
```

### Arch Linux

```bash
# bash is available via pacman if not already present:
sudo pacman -S bash git

mkdir -p ~/tools && cd ~/tools
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git
bash ~/tools/Claude-agent-mesh/install.sh --dir=~/Projects/my-project
```

### Alpine Linux

Alpine uses `ash` by default, not bash. Install bash first:

```bash
apk add bash git
mkdir -p ~/tools && cd ~/tools
git clone https://github.com/JoeArmageddon/Claude-agent-mesh.git
bash ~/tools/Claude-agent-mesh/install.sh --dir=~/Projects/my-project
```

---

## Verifying the install

After running `install.sh`, verify these files exist in your project:

```bash
ls .claude/commands/
```

Expected output:
```
mesh-halt.md   mesh-review.md   mesh-roles.md   mesh-status.md   mesh.md
```

Also verify your `.gitignore` has the mesh entries:
```bash
grep -e ".mesh/" .gitignore
```

Expected output:
```
.mesh/
.mesh-archive/
```

Then open Claude Code and run:
```
/mesh-roles
```

If you see a table of 28 agents grouped by domain, the install is working correctly.

---

## Project vs global install

**claude-agent-mesh installs at the project level, not globally.**

This means:
- Each project you want to use the mesh in needs its own install
- The commands appear only when you open Claude Code in that project directory
- Your global `~/.claude/` is never modified
- Different projects can use different versions of the mesh

To install into multiple projects:
```bash
# Install into project A
bash ~/tools/Claude-agent-mesh/install.sh --dir=~/Projects/project-a

# Install into project B
bash ~/tools/Claude-agent-mesh/install.sh --dir=~/Projects/project-b
```

The installer is safe to re-run. Existing files are skipped, not overwritten.

---

## Using the installer flags

```bash
bash install.sh [options]
```

| Flag | Description |
|------|-------------|
| `--dir=/path` | Install into this directory instead of current working directory |
| `-h` or `--help` | Show usage information |

Examples:
```bash
# Install into current directory
bash ~/tools/Claude-agent-mesh/install.sh

# Install into a specific project
bash ~/tools/Claude-agent-mesh/install.sh --dir=/Users/joe/Projects/my-app

# Windows Git Bash
bash /c/tools/Claude-agent-mesh/install.sh --dir=/c/Users/Joe/Projects/my-app
```

---

## Manual install (no bash)

If you cannot run bash for any reason, here is what `install.sh` does — you can replicate it manually:

1. **Create directory:** Make `.claude/commands/` inside your project
2. **Copy files:** Copy all five `.md` files from `.claude/commands/` in this repo into that directory
3. **Update .gitignore:** Add `.mesh/` and `.mesh-archive/` as separate lines

The five files to copy:
- `mesh.md`
- `mesh-status.md`
- `mesh-halt.md`
- `mesh-roles.md`
- `mesh-review.md`

---

## First run

Once installed, open Claude Code in your project directory:

```bash
cd /path/to/your/project
claude
```

### Test the install
```
/mesh-roles
```
You should see a table of 28 agents. If not, see [Troubleshooting](#troubleshooting).

### Your first real mesh
Be descriptive. The more specific your task description, the better the Conductor assembles the team.

```
/mesh build a REST API for a todo list with authentication, rate limiting, and tests
```

```
/mesh design the onboarding flow for a B2B SaaS app where the primary user is an operations manager
```

```
/mesh audit our checkout flow for accessibility issues against WCAG 2.1 AA
```

```
/mesh research the market for AI-powered legal document review tools
```

### Watch the run
While the mesh runs, you can check progress:
```
/mesh-status
```

### View the output
The final deliverable is always at:
```
.mesh/final/output.md
```

---

## Configuration

`claude-agent-mesh` has no configuration files to edit. The system is configured by the AGENT.md files themselves.

**To customise agent behaviour:** edit the relevant `AGENT.md` in `agents/[domain]/[role]/`. The changes take effect immediately on the next mesh run.

**To add an agent:** see [docs/writing-agents.md](writing-agents.md).

**To change the quality threshold:** edit `core/quality-reviewer/AGENT.md`. The threshold is set in the Quality Reviewer's protocol.

**To add task-to-team mappings:** edit `core/conductor/AGENT.md`. The signal routing table maps keywords and task patterns to agent combinations.

---

## Updating

To get the latest version of claude-agent-mesh:

```bash
# Pull the latest changes
cd ~/tools/Claude-agent-mesh
git pull

# Re-run the installer in any project where you want the updated commands
bash ~/tools/Claude-agent-mesh/install.sh --dir=~/Projects/my-project
```

**Note:** The installer skips existing files by default. If you want to update command files that already exist, delete them first:

```bash
# Remove existing commands before re-installing to get updates
rm /path/to/project/.claude/commands/mesh*.md
bash ~/tools/Claude-agent-mesh/install.sh --dir=/path/to/project
```

---

## Uninstalling

### Remove from a project

```bash
# Remove the command files
rm /path/to/project/.claude/commands/mesh*.md

# Remove the .mesh workspace if present
rm -rf /path/to/project/.mesh
rm -rf /path/to/project/.mesh-archive

# Remove .gitignore entries (optional — they're harmless to leave)
# Edit .gitignore and remove the .mesh/ and .mesh-archive/ lines
```

### Remove from all projects

Run the above for each project you installed into.

### Remove the repo

```bash
rm -rf ~/tools/Claude-agent-mesh
```

---

## Troubleshooting

### "command not found: bash"

**Windows users:** You are in Command Prompt or PowerShell. Install [Git for Windows](https://git-scm.com/download/win) and use Git Bash, or use [WSL2](#option-b--wsl2-most-compatible).

### "/mesh is not a valid command"

The commands are installed at the project level. Check:

1. You opened Claude Code from inside the project where you ran `install.sh`
2. The command files exist: `ls .claude/commands/mesh*.md`
3. The files are not empty: `cat .claude/commands/mesh.md`

### "No active mesh run" from /mesh-status even during a run

The run may have failed before creating `.mesh/`. Check Claude Code's output for error messages. Common cause: the Conductor could not write to the current directory. Verify Claude Code has write permissions to your project directory.

### The mesh halts at the first agent

The Conductor may have set a very narrow team and the first agent encountered an error. Run `/mesh-halt` to archive, then inspect `.mesh/messages/` for `halt` or `escalate` type messages.

### Agent keeps failing quality review after 3 rounds

This means the task may be under-specified. The Quality Reviewer will escalate to the Conductor after 3 rounds. To diagnose: read the rejection messages in `.mesh/messages/` — they include per-dimension scores and specific feedback. Restart with a more detailed task description.

### Install.sh says "target directory does not exist"

The path you passed to `--dir=` doesn't exist. Create it first:
```bash
mkdir -p /path/to/my-project
bash install.sh --dir=/path/to/my-project
```

### On Windows, install.sh reports "permission denied"

Run Git Bash as Administrator, or check that the target directory is not read-only. Right-click the directory → Properties → Attributes → ensure "Read-only" is unchecked.

### Git Bash can't find the install.sh file

Windows paths in Git Bash use forward slashes and `C:\` becomes `/c/`. Example:
```bash
# This is wrong:
bash C:\tools\Claude-agent-mesh\install.sh

# This is correct:
bash /c/tools/Claude-agent-mesh/install.sh
```

### WSL2: Claude Code opens but doesn't see the commands

WSL and Windows have separate filesystems. If you installed the commands into a Windows path from WSL (e.g. `/mnt/c/Projects/my-project/.claude/commands/`) but opened Claude Code from the Windows side, it should work. If you opened Claude Code from the WSL side, make sure you ran `claude` from the same directory that contains `.claude/commands/`.

### The .mesh/ directory is not being deleted after runs

`claude-agent-mesh` instructs the Conductor to delete `.mesh/` after a clean run, but the deletion only happens if the Synthesizer completes successfully. If a run was interrupted (e.g. you closed Claude Code mid-run), `.mesh/` will remain. You can safely delete it manually:
```bash
rm -rf .mesh/
```

Or use `/mesh-halt` which archives it to `.mesh-archive/[timestamp]/` before removing it.
