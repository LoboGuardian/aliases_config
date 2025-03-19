# Aliases Configuration for Shell

This repository contains a powerful set of **Bash aliases and functions** to improve your workflow with **Git, Django, Python, Poetry, and Pipenv**.

## **Setup Instructions**

Rename ```bash_aliases``` to ```.bash_aliases``` and move it to your home directory (```$HOME```).

Example commands: 

```bash
mv bash_aliases $HOME/.bash_aliases
```

To enable these aliases, add the following to your `~/.bashrc` (for Bash) or `~/.zshrc` (for Zsh):


```bash
# Add aliases
if [ -f ~/.bash_aliases ]; then
   source ~/.bash_aliases
fi
```

Then, reload your shell:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Git: Enhanced Workflow

- Clone repositories

```bash
gitc user/repo
```

Clones a GitHub repository via SSH or HTTPS based on your configuration.

- Quick commit & push

```bash
gitqc "Your commit message"
```

Stages all changes, commits, and pushes with a message.

- Create & switch to a new branch

```bash
gitnb feature/my-feature
```

Creates a new branch and sets the upstream.

- Delete local & remote branch

```bash
gitdb feature/old-branch
```

Deletes both local and remote branches.

- Pull latest changes from main

```bash
gitup  # Defaults to 'main'
gitup develop  # Update 'develop' branch
```

Switches to the branch, pulls the latest changes, and returns to the previous branch.

- Clean untracked files & folders

```bash
gitcl  # Prompts before removing untracked files
```

Removes untracked files after confirmation.

- Undo last commit (Soft & Hard)

```bash
gitrs  # Undo commit but keep changes staged
gitrh  # Completely remove last commit
```

- Stash changes

```bash
gits "Bugfix changes"
gitsa  # Apply last stash
```

Stashes and applies changes later.

## 🛠 Django Commands (Supports Pipenv & Poetry)
The system dynamically switches between Pipenv and Poetry based on:

```bash
export VENV_MANAGER="pipenv"  # Default
export VENV_MANAGER="poetry"
```

 Add to ~/.bashrc or ~/.zshrc for persistence.

- Start Django server

```bash
dj          # Default Python 3
dj311       # Python 3.11
dj312       # Python 3.12
```

- Manage Django Migrations

```bash
dj_makemigrations
dj_migrate
dj_sqlmigrate 0001_initial
dj_flush  # Reset database
```

- Create Django Project/App

```bash
dj_new myproject
dj_app myapp
```

## Python & Virtual Environment Management

- Activate virtual environment

```bash
venv
```

Automatically activates Pipenv or Poetry shell based on VENV_MANAGER.

- List virtual environments

```bash
venv-list
```

Shows all active Pipenv or Poetry environments.

- Update all dependencies

```bash
venv-update-all
```

Updates dependencies using Pipenv or Poetry.

- Generate requirements.txt

```bash
venv-requirements
```

Exports dependencies from Pipenv or Poetry.

- Run Python with a specific version

```bash
py311 my_script.py
py312 my_script.py
```

Runs Python scripts with specific versions.

### System Utilities

- Safer Commands

```bash
rm     # Asks for confirmation before deleting
cp     # Interactive copy
mv     # Interactive move
```

- Update system (Fedora/DNF)

```bash
sys_update
```

Runs dnf update and removes unnecessary packages.

## Why Use These Aliases?
- Faster development workflow
- Seamless Git & Django automation
- Prevention of accidental mistakes
- Works with both Pipenv & Poetry
- Improved productivity with a clean structure

## Contributing
Feel free to add more aliases or improve existing ones!