# BreezyRouter - Git, GitHub & Backup Setup Guide

## Table of Contents
1. [Setting Up Local Git in Cursor](#part-1-setting-up-local-git-in-cursor)
2. [Creating a GitHub Account and Repository](#part-2-creating-a-github-account-and-repository)
3. [Initialize Git Locally and Push to GitHub](#part-3-initialize-git-locally-and-push-to-github)
4. [Creating and Using .gitignore](#part-4-creating-and-using-gitignore)
5. [Essential Git Commands](#part-5-essential-git-commands)
6. [Backing Up to Google Drive](#part-6-backing-up-to-google-drive)
7. [Quick Reference Card](#quick-reference-card)

---

## Part 1: Setting Up Local Git in Cursor

### Install Git (if not already installed)

**Check if Git is installed:**

```bash
git --version
```

If Git is not installed, download and install from: https://git-scm.com/download/win

### Configure Git (First Time Setup)

```bash
# Set your name (replace with your actual name)
git config --global user.name "Your Name"

# Set your email (use the same email you'll use for GitHub)
git config --global user.email "your.email@example.com"

# Verify configuration
git config --list
```

---

## Part 2: Creating a GitHub Account and Repository

### Create GitHub Account

1. Go to https://github.com
2. Click **"Sign up"** in the top right
3. Follow the prompts to create your account:
   - Enter your email address
   - Create a password
   - Choose a username
   - Verify your account (solve the puzzle)
   - Check your email for verification code
4. Complete the onboarding process

### Create a Private Repository

1. Once logged into GitHub, click the **"+"** icon (top right) → **"New repository"**
2. Repository settings:
   - **Repository name:** `BreezyRouter` (or your preferred name)
   - **Description:** (optional) "Salesforce BreezyRouter App"
   - **Privacy:** Select **"Private"** ✓
   - **DON'T** initialize with README (since you already have files)
   - **DON'T** add .gitignore or license yet
3. Click **"Create repository"**
4. GitHub will show you a page with setup instructions - keep this open!

### Creating a GitHub Personal Access Token

Since GitHub no longer accepts passwords for Git operations, you need a Personal Access Token:

1. On GitHub, click your **profile picture** → **Settings**
2. Scroll down to **"Developer settings"** (bottom left sidebar)
3. Click **"Personal access tokens"** → **"Tokens (classic)"**
4. Click **"Generate new token"** → **"Generate new token (classic)"**
5. Configure the token:
   - **Note:** "BreezyRouter Access"
   - **Expiration:** Choose your preference (90 days recommended)
   - **Scopes:** Check **"repo"** (full control of private repositories)
6. Click **"Generate token"**
7. **⚠️ COPY THE TOKEN IMMEDIATELY** (you won't see it again!)
8. Save this token securely - you'll use it as your password when Git prompts you

---

## Part 3: Initialize Git Locally and Push to GitHub

### Step-by-Step Commands

Open the Cursor terminal and run these commands:

```bash
# Navigate to your project root (if not already there)
cd C:\Users\artof\BreezyRouter

# Initialize Git repository
git init

# Add all files (after creating .gitignore - see next section)
git add .

# Make your first commit
git commit -m "Initial commit: BreezyRouter Salesforce app"

# Add GitHub remote (replace YOUR_USERNAME with your actual GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/BreezyRouter.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub (first time)
git push -u origin main
```

**Authentication:** When prompted for credentials:
- **Username:** Your GitHub username
- **Password:** Paste your Personal Access Token (not your actual password!)

### Alternative: Using SSH (More Secure, No Token Needed Repeatedly)

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Start SSH agent
eval $(ssh-agent -s)

# Add SSH key
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard (Windows)
cat ~/.ssh/id_ed25519.pub | clip

# Add to GitHub: Settings → SSH and GPG keys → New SSH key
# Paste the key and save

# Use SSH URL instead
git remote add origin git@github.com:YOUR_USERNAME/BreezyRouter.git
```

---

## Part 4: Creating and Using .gitignore

### What is .gitignore?

The `.gitignore` file tells Git which files and directories to ignore (not track). This is essential for:
- Preventing sensitive data from being committed
- Excluding large or unnecessary files
- Keeping repository clean and focused

### Sample .gitignore for BreezyRouter

Create a `.gitignore` file in your project root:

```gitignore
# Salesforce specific
.sfdx/
.sf/
.localdevserver/
.vscode/settings.json
.project
.settings/
.classpath

# Logs
*.log
logs/
*.log.*

# OS Files
.DS_Store
Thumbs.db
desktop.ini

# Node modules (if using)
node_modules/
npm-debug.log*

# IDE
.idea/
*.sublime-project
*.sublime-workspace
.vscode/launch.json
.vscode/tasks.json

# Backup files
*.bak
*.backup
*~

# Test results
coverage/
test-results/

# Certificates and keys
*.key
*.pem
*.cert

# Environment files
.env
.env.local

# Build artifacts
dist/
build/
target/

# Metadata that changes frequently
**/profiles/*.xml
!**/profiles/Admin.profile-meta.xml

# Package files
*.zip
*.tar.gz

# Data files (optional - uncomment to exclude data)
# Data/
# *.csv
# *.xlsx

# Specific file extensions to ignore (examples)
# *.tmp
# *.cache
```

### How .gitignore Syntax Works

| Pattern | Description | Example |
|---------|-------------|---------|
| `file.txt` | Ignores specific file | `config.json` |
| `*.log` | Ignores all files with extension | `*.log`, `*.tmp` |
| `folder/` | Ignores entire folder | `logs/`, `temp/` |
| `**/folder/` | Ignores folder anywhere | `**/node_modules/` |
| `!file.txt` | Negates ignore (includes file) | `!important.log` |
| `#` | Comment | `# This is a comment` |

### Pushing Only force-app\main\default

If you want to version control ONLY the `force-app\main\default` directory:

**Option 1: Add only specific directory**
```bash
git add force-app/main/default
git commit -m "Add force-app/main/default"
git push
```

**Option 2: Modify .gitignore to exclude everything else**
```gitignore
# Ignore everything at root
/*

# But include force-app
!/force-app

# Ignore everything in force-app
/force-app/*

# But include main
!/force-app/main

# Ignore everything in main
/force-app/main/*

# But include default
!/force-app/main/default

# Also include these root files
!/.gitignore
!/README.md
!/sfdx-project.json
```

---

## Part 5: Essential Git Commands

### Basic Workflow Commands

#### Check Status
```bash
# See what files have changed
git status

# Short format
git status -s
```

#### Add Files (Staging)
```bash
# Add specific file
git add path/to/file.cls

# Add specific folder
git add path/to/folder/

# Add all changed files
git add .

# Add all files with specific extension
git add *.cls

# Add all Apex classes
git add force-app/main/default/classes/

# Add files interactively (choose what to stage)
git add -p
```

#### Remove from Staging
```bash
# Unstage file (keep changes in working directory)
git restore --staged filename

# Or using reset
git reset HEAD filename
```

#### Commit Changes
```bash
# Commit with message
git commit -m "Add new routing logic for BreezyRouter"

# Commit with detailed message (opens editor)
git commit

# Commit all tracked changes (skip git add)
git commit -am "Quick fix for user trigger"

# Amend last commit (add forgotten files or fix message)
git commit --amend -m "Updated commit message"
```

#### Push and Pull
```bash
# Push to GitHub
git push

# Push new branch first time
git push -u origin branch-name

# Pull latest changes
git pull

# Pull from specific remote and branch
git pull origin main

# Fetch changes without merging
git fetch origin
```

---

### Viewing History and Changes

#### View Commits
```bash
# View commit history
git log

# One line per commit
git log --oneline

# View last 5 commits
git log -5

# View commits with file changes
git log --stat

# View commits for specific file
git log -- filename

# View commits by author
git log --author="Your Name"

# View commits with graph
git log --graph --oneline --all
```

#### View Changes
```bash
# View changes in working directory (not staged)
git diff

# View changes that are staged
git diff --cached

# View changes for specific file
git diff filename

# View changes between commits
git diff commit1 commit2

# View changes between branches
git diff main feature-branch

# Show details of specific commit
git show commit_hash
```

---

### Branch Management

#### Create and Switch Branches
```bash
# List all branches (* shows current)
git branch

# List all branches including remote
git branch -a

# Create new branch
git branch feature-name

# Switch to existing branch
git checkout feature-name

# Create and switch to new branch (shortcut)
git checkout -b feature-name

# Modern way to switch branches
git switch feature-name

# Create and switch (modern syntax)
git switch -c feature-name
```

#### Merge and Delete Branches
```bash
# Merge branch into current branch
git merge feature-name

# Merge with no fast-forward (creates merge commit)
git merge --no-ff feature-name

# Delete branch locally
git branch -d feature-name

# Force delete (if not fully merged)
git branch -D feature-name

# Delete remote branch
git push origin --delete feature-name

# Show which branch you're on
git branch --show-current
```

---

### Undoing Changes

#### Discard Changes
```bash
# Discard changes in specific file (⚠️ CAREFUL!)
git checkout -- filename

# Modern syntax
git restore filename

# Discard all changes in working directory (⚠️ VERY CAREFUL!)
git restore .
```

#### Reset Commits
```bash
# Undo last commit, keep changes staged
git reset --soft HEAD~1

# Undo last commit, keep changes unstaged
git reset HEAD~1

# Undo last commit, discard all changes (⚠️ VERY CAREFUL!)
git reset --hard HEAD~1

# Undo last 3 commits
git reset --soft HEAD~3

# Reset to specific commit
git reset --hard commit_hash
```

#### Revert Commits (Safe Way)
```bash
# Create new commit that undoes a previous commit
git revert commit_hash

# Revert last commit
git revert HEAD

# Revert without auto-commit
git revert --no-commit commit_hash
```

---

### Remote Repository Management

```bash
# View remote repositories
git remote -v

# Add remote
git remote add origin https://github.com/username/repo.git

# Change remote URL (HTTPS to SSH or vice versa)
git remote set-url origin git@github.com:username/repo.git

# Remove remote
git remote remove origin

# Rename remote
git remote rename old-name new-name

# Show remote info
git remote show origin
```

---

### Stashing (Temporary Storage)

```bash
# Stash current changes
git stash

# Stash with message
git stash save "Work in progress on feature X"

# List all stashes
git stash list

# Apply most recent stash (keep stash)
git stash apply

# Apply specific stash
git stash apply stash@{2}

# Apply and remove stash
git stash pop

# Remove specific stash
git stash drop stash@{0}

# Clear all stashes
git stash clear

# View stash contents
git stash show -p stash@{0}
```

---

### Tagging (Version Releases)

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Version 1.0.0 release"

# Create lightweight tag
git tag v1.0.0

# List all tags
git tag

# List tags matching pattern
git tag -l "v1.*"

# Push tag to remote
git push origin v1.0.0

# Push all tags
git push --tags

# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0

# Checkout specific tag
git checkout v1.0.0
```

---

### Cleaning Up

```bash
# Show what would be removed (dry run)
git clean -n

# Remove untracked files
git clean -f

# Remove untracked files and directories
git clean -fd

# Remove untracked and ignored files
git clean -fdx
```

---

### Cloning Repositories

```bash
# Clone repository
git clone https://github.com/username/repo.git

# Clone to specific folder
git clone https://github.com/username/repo.git my-folder

# Clone specific branch
git clone -b branch-name https://github.com/username/repo.git

# Shallow clone (only recent history, faster)
git clone --depth 1 https://github.com/username/repo.git
```

---

### Advanced Commands

```bash
# Cherry-pick specific commit to current branch
git cherry-pick commit_hash

# Rebase current branch onto main
git rebase main

# Interactive rebase (edit, squash, reorder commits)
git rebase -i HEAD~5

# Search commits for string
git log --all --grep="search term"

# Find who changed a line
git blame filename

# Show file at specific commit
git show commit_hash:path/to/file

# List files in commit
git show --name-only commit_hash
```

---

## Part 6: Backing Up to Google Drive

### Method 1: Google Drive Desktop (Recommended)

#### Step 1: Install Google Drive for Desktop

1. Go to https://www.google.com/drive/download/
2. Click **"Download for desktop"**
3. Download and run the installer
4. Sign in with your Google Account
5. Choose sync options (default is fine)
6. After installation, you'll see Google Drive in File Explorer (usually `G:\My Drive`)

#### Step 2: Create Backup Script

A PowerShell script has been created: `backup-to-google-drive.ps1`

**Features:**
- Automatically creates timestamped backups
- Excludes unnecessary files (.sfdx, node_modules, logs)
- Keeps only last 5 backups (auto-cleanup)
- Uses Windows robocopy for efficient copying

**To customize the script, edit these lines:**
```powershell
$projectPath = "C:\Users\artof\BreezyRouter"
$googleDrivePath = "G:\My Drive\Backups\BreezyRouter"  # Change to your Google Drive path
```

#### Step 3: Enable PowerShell Script Execution (One-Time)

```powershell
# Allow local scripts to run
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Step 4: Run the Backup

```powershell
# From Cursor terminal
cd C:\Users\artof\BreezyRouter
.\backup-to-google-drive.ps1
```

---

### Method 2: Automated Scheduled Backups

#### Option A: Windows Task Scheduler

1. Press `Win + R`, type `taskschd.msc`, press Enter
2. Click **"Create Basic Task"** in right panel
3. **Name:** "BreezyRouter Backup"
4. **Trigger:** Daily (or your preference)
5. **Time:** Choose when to run
6. **Action:** Start a program
7. **Program/script:** `powershell.exe`
8. **Arguments:** `-ExecutionPolicy Bypass -File "C:\Users\artof\BreezyRouter\backup-to-google-drive.ps1"`
9. Finish and test by right-clicking task → Run

#### Option B: Simple Batch File for Quick Backup

Create `quick-backup.bat`:
```batch
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0backup-to-google-drive.ps1"
pause
```

Double-click this file anytime to run a backup.

---

### Method 3: Manual Zip and Upload

```powershell
# Create a zip file of your project
$date = Get-Date -Format "yyyy-MM-dd"
Compress-Archive -Path "C:\Users\artof\BreezyRouter\*" -DestinationPath "C:\Users\artof\Desktop\BreezyRouter_$date.zip" -Force

# Then manually upload to Google Drive via web browser (drive.google.com)
```

---

### Method 4: Continuous Sync (Advanced)

**Warning:** Only use if you understand the implications

1. In Google Drive Desktop settings
2. Go to **Preferences** → **Add folder**
3. Select your BreezyRouter folder
4. Choose **"Mirror files"**
5. Now any changes automatically sync to Google Drive

**Caution:** 
- Can cause conflicts with Git
- May sync large files unnecessarily
- Can consume bandwidth on constant changes

---

## Quick Reference Card

### Daily Git Workflow

```bash
# 1. Start your day - pull latest changes
git pull

# 2. Create a feature branch (optional but recommended)
git checkout -b feature/new-feature

# 3. Make your changes...

# 4. Check what changed
git status

# 5. Stage your changes
git add .

# 6. Commit with descriptive message
git commit -m "Add new BreezyRouter member assignment logic"

# 7. Push to GitHub
git push

# If first time pushing this branch:
git push -u origin feature/new-feature

# 8. Merge to main when ready
git checkout main
git merge feature/new-feature
git push
```

---

### Common Scenarios

#### Scenario 1: New Feature Development
```bash
# Create feature branch
git checkout -b feature/new-routing-logic

# Make changes, commit frequently
git add .
git commit -m "Add initial routing logic"

# More changes
git add .
git commit -m "Add validation for routing rules"

# Push to GitHub
git push -u origin feature/new-routing-logic

# When ready, merge to main
git checkout main
git pull  # Get latest
git merge feature/new-routing-logic
git push

# Delete feature branch
git branch -d feature/new-routing-logic
git push origin --delete feature/new-routing-logic
```

#### Scenario 2: Fix a Mistake in Last Commit
```bash
# Forgot to add a file
git add forgotten-file.cls
git commit --amend --no-edit

# Or change commit message
git commit --amend -m "Corrected commit message"

# ⚠️ Only amend if you haven't pushed yet!
# If already pushed, you'll need to force push (careful!)
git push --force-with-lease
```

#### Scenario 3: Undo Changes
```bash
# Discard changes in a file
git restore filename

# Undo last commit but keep changes
git reset --soft HEAD~1

# Completely undo last commit and discard changes
git reset --hard HEAD~1
```

#### Scenario 4: Work on Multiple Features
```bash
# Working on feature A
git checkout -b feature/feature-a
# Make some changes...

# Need to switch to feature B urgently
git stash save "WIP: feature A"
git checkout -b feature/feature-b
# Work on feature B, commit, push

# Go back to feature A
git checkout feature/feature-a
git stash pop
# Continue working
```

#### Scenario 5: Pull Latest from Collaborator
```bash
git pull origin main

# If conflicts occur
# Edit files to resolve conflicts
git add .
git commit -m "Resolve merge conflicts"
git push
```

#### Scenario 6: Create a Release
```bash
# Ensure main is clean
git checkout main
git pull

# Create and push tag
git tag -a v1.0.0 -m "Version 1.0.0 - Initial release"
git push origin v1.0.0

# Create release on GitHub
# Go to Releases → Draft new release → Choose tag → Add notes
```

---

### Git Commit Message Best Practices

**Format:**
```
Type: Brief description (50 chars or less)

More detailed explanation if needed (wrap at 72 characters).
Explain what and why, not how.

- Bullet points are okay
- Use present tense: "Add feature" not "Added feature"
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, no logic change)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

**Examples:**
```bash
git commit -m "feat: Add round-robin routing to BreezyRouter"
git commit -m "fix: Correct member assignment when queue is empty"
git commit -m "docs: Update README with installation instructions"
git commit -m "refactor: Simplify routing logic in BreezyRouter class"
```

---

## Initial Setup Checklist

Use this checklist to ensure everything is properly set up:

### Git and GitHub Setup

- [ ] Git is installed (`git --version`)
- [ ] Git user name configured (`git config user.name`)
- [ ] Git user email configured (`git config user.email`)
- [ ] GitHub account created
- [ ] GitHub email verified
- [ ] Personal Access Token created and saved securely
- [ ] Private repository created on GitHub
- [ ] Local repository initialized (`git init`)
- [ ] `.gitignore` file created and configured
- [ ] Initial commit made
- [ ] Remote repository added (`git remote add origin`)
- [ ] Code pushed to GitHub (`git push -u origin main`)
- [ ] Repository shows correctly on GitHub website

### Google Drive Backup Setup

- [ ] Google Drive for Desktop installed
- [ ] Signed into Google Account
- [ ] Google Drive folder accessible in File Explorer
- [ ] Backup script (`backup-to-google-drive.ps1`) created
- [ ] Backup script path configured correctly
- [ ] PowerShell execution policy set
- [ ] Test backup run successfully
- [ ] Backup folder appears in Google Drive
- [ ] (Optional) Scheduled task created for automatic backups

---

## Troubleshooting

### Git Issues

**Problem: "fatal: not a git repository"**
```bash
# Solution: Initialize Git
git init
```

**Problem: "Permission denied (publickey)"**
```bash
# Solution: Use HTTPS instead of SSH, or set up SSH keys
git remote set-url origin https://github.com/username/repo.git
```

**Problem: "Authentication failed"**
```bash
# Solution: Use Personal Access Token, not password
# Or update credentials in Windows Credential Manager
```

**Problem: "Refusing to merge unrelated histories"**
```bash
# Solution: Allow unrelated histories (when combining repos)
git pull origin main --allow-unrelated-histories
```

**Problem: Merge conflicts**
```bash
# Solution: Manually edit files, remove conflict markers, then:
git add .
git commit -m "Resolve merge conflicts"
```

### GitHub Issues

**Problem: Can't push to repository**
- Verify you have push access (for private repos)
- Check if repository name is correct
- Ensure you're authenticated properly

**Problem: Large files rejected**
- Remove large files from commit
- Use Git LFS for large files if needed
- Add large files to `.gitignore`

### Google Drive Issues

**Problem: Backup script fails**
- Check Google Drive Desktop is running
- Verify path in script matches your Google Drive location
- Ensure you have write permissions
- Check disk space

**Problem: Google Drive not syncing**
- Check internet connection
- Restart Google Drive Desktop
- Check Google Drive storage quota
- Pause and resume sync

---

## Additional Resources

### Git Documentation
- Official Git Documentation: https://git-scm.com/doc
- Git Cheat Sheet: https://education.github.com/git-cheat-sheet-education.pdf
- Git Book (Free): https://git-scm.com/book/en/v2

### GitHub Resources
- GitHub Docs: https://docs.github.com
- GitHub Learning Lab: https://lab.github.com
- GitHub Skills: https://skills.github.com

### Salesforce with Git
- Salesforce DX Developer Guide: https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/
- Salesforce CLI Setup Guide: https://developer.salesforce.com/tools/sfdxcli

---

## Tips for Success

### General Best Practices

1. **Commit Often:** Make small, frequent commits rather than large infrequent ones
2. **Write Clear Messages:** Future you will thank present you
3. **Pull Before Push:** Always `git pull` before starting work
4. **Use Branches:** Keep `main` branch stable, use feature branches
5. **Review Changes:** Use `git diff` before committing
6. **Backup Regularly:** Run backups at least weekly (or automate)
7. **Test Before Committing:** Ensure code works before committing
8. **Keep It Clean:** Regularly clean up merged branches

### Security Best Practices

1. **Never Commit:**
   - Passwords or API keys
   - Personal Access Tokens
   - Private certificates or keys
   - Sensitive customer data
   - Large binary files

2. **Use .gitignore:** Always set up before first commit

3. **Review Before Push:** Double-check what you're pushing:
   ```bash
   git diff --cached
   ```

4. **Enable 2FA:** On GitHub for extra security

5. **Rotate Tokens:** Regularly update Personal Access Tokens

### Collaboration Tips

1. **Communicate:** Let team know what you're working on
2. **Pull Requests:** Use for code review (even on your own)
3. **Branch Naming:** Use descriptive names (e.g., `feature/add-routing`, `fix/null-pointer`)
4. **Resolve Conflicts:** Address merge conflicts promptly
5. **Document:** Keep README updated with setup instructions

---

## Support and Help

If you encounter issues:

1. **Check Git Status:** `git status` often reveals the issue
2. **Read Error Messages:** Git error messages are usually helpful
3. **Search Online:** Most Git issues have been solved before
4. **GitHub Community:** https://github.community
5. **Stack Overflow:** Great resource for specific problems

---

*Last Updated: October 10, 2025*
*Document Version: 1.0*
*Project: BreezyRouter Salesforce Application*

