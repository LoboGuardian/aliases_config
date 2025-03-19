# ~/.bash_aliases - Custom shell aliases and functions

# ------------------------------
# Git: Clone repositories using SSH or HTTPS
# ------------------------------
git_clone() {
  local repo="$1"
  
  # 1. Validate input
  if [ -z "$repo" ]; then
    echo "Usage: git_clone <user/repo>"
    return 1
  fi

  # 2. Validate repository format
  if [[ "$repo" != */* ]]; then
    echo "Invalid repository format. Use: user/repo"
    return 1
  fi

  # 3. Determine URL based on protocol
  local url=""
  if [[ "$USE_HTTPS" == "true" ]]; then
    url="https://github.com/$repo.git"
  else
    url="git@github.com:$repo.git"
  fi

  # 4. Check if directory exists
  local repo_name=$(basename "$repo")
  if [ -d "$repo_name" ]; then
    echo "Directory '$repo_name' already exists. Skipping clone."
    return 1
  fi

  # 5. Clone repository
  echo "Cloning $repo..."
  if git clone "$url" "$repo_name"; then
    echo "Successfully cloned $repo."
  else
    echo "Error cloning $repo. Check connection and repository name."
    return 1
  fi

  # 6. Auto change directory (if enabled)
  [[ "$AUTO_CD" == "true" ]] && cd "$repo_name"
}

alias gitc='git_clone'


# ------------------------------
# Git: Quick Commit & Push
# ------------------------------
git_quick_commit() {
  local message="${1:-'Quick commit'}"
  
  git add .
  git commit -m "$message"
  git push
  
  echo "✅ Changes committed and pushed: $message"
}

alias gitqc='git_quick_commit' # Usage: gitqc "Commit message"


# ------------------------------
# Git: Create and Switch Branch
# ------------------------------
git_new_branch() {
  local branch_name="$1"

  if [ -z "$branch_name" ]; then
    echo "Usage: git_new_branch <branch-name>"
    return 1
  fi

  git checkout -b "$branch_name"
  git push --set-upstream origin "$branch_name"
  
  echo "✅ New branch '$branch_name' created and set upstream."
}

alias gitnb='git_new_branch' # Usage: gitnb feature/new-feature


# ------------------------------
# Git: Delete Local and Remote Branch
# ------------------------------
git_delete_branch() {
  local branch_name="$1"

  if [ -z "$branch_name" ]; then
    echo "Usage: git_delete_branch <branch-name>"
    return 1
  fi

  git branch -d "$branch_name" && git push origin --delete "$branch_name"
  
  echo "✅ Branch '$branch_name' deleted locally and remotely."
}

alias gitdb='git_delete_branch' # Usage: gitdb feature/old-branch


# ------------------------------
# Git: Pull Latest Changes from Main Branch
# ------------------------------
git_update_main() {
  local main_branch="${1:-main}"

  git checkout "$main_branch"
  git pull
  git checkout -
  
  echo "✅ Updated branch '$main_branch' and returned to the previous branch."
}

alias gitup='git_update_main' # Usage: gitup (defaults to 'main'), or gitup develop


# ------------------------------
# Git: Clean Untracked Files and Folders
# ------------------------------
git_clean() {
  echo "⚠️ This will remove all untracked files and directories! Continue? (y/N)"
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git clean -fd
    echo "✅ Untracked files and directories removed."
  else
    echo "❌ Operation canceled."
  fi
}

alias gitcl='git_clean' # Usage: gitcl (removes untracked files after confirmation)


# ------------------------------
# Git: Reset Last Commit (Soft & Hard)
# ------------------------------
git_reset_soft() {
  git reset --soft HEAD~1
  echo "✅ Last commit undone (soft reset)."
}

git_reset_hard() {
  git reset --hard HEAD~1
  echo "⚠️ Last commit removed (hard reset)."
}

alias gitrs='git_reset_soft'  # Usage: gitrs (undo last commit but keep changes)
alias gitrh='git_reset_hard'  # Usage: gitrh (completely remove last commit)


# ------------------------------
# Git: Stash Changes and Apply Later
# ------------------------------
git_stash_save() {
  local message="${1:-'Quick stash'}"
  git stash push -m "$message"
  echo "✅ Changes stashed: $message"
}

git_stash_apply() {
  git stash pop
  echo "✅ Last stash applied."
}

alias gits='git_stash_save'  # Usage: gits "Fixing bug"
alias gitsa='git_stash_apply' # Usage: gitsa (applies last stash)


# ------------------------------
# Pipenv: Virtual environment management
# ------------------------------
pipenv_list() {
  for venv in ~/.local/share/virtualenvs/*; do
    venv_name=$(basename "$venv")
    venv_path="$venv"
    project_file="$venv/.project"
    
    python_version=$(find "$venv/bin" -name "python*" 2>/dev/null | head -n 1 | xargs -I {} readlink -f {} | xargs -I {} dirname {} | xargs -I {} dirname {} | xargs -I {} basename {} | sed 's/python//')

    if [ -f "$project_file" ]; then
      project_name=$(cat "$project_file")
      echo -e "$venv_name\t$project_name\tPython $python_version\t$venv_path"
    else
      echo -e "$venv_name\t(No project found)\tPython $python_version\t$venv_path"
    fi
  done | column -t -s $'\t'
}

alias pipenv-list='pipenv_list'

# Update all virtual environments
pipenv_update_all() {
  for venv in ~/.local/share/virtualenvs/*; do
    echo "Updating $(basename "$venv")..."
    (cd "$venv" && pipenv update) && echo "✅ Updated" || echo "❌ Update failed"
  done
}
alias pipenv-update-all='pipenv_update_all'

# Generate requirements.txt for all environments
pipenv_generate_requirements() {
  for venv in ~/.local/share/virtualenvs/*; do
    echo "Generating requirements.txt for $(basename "$venv")..."
    (cd "$venv" && pipenv requirements > requirements.txt) && echo "✅ Generated" || echo "❌ Failed"
  done
}
alias pipenv-requirements-all='pipenv_generate_requirements'


# ------------------------------
# Poetry: Virtual environment management
# ------------------------------
poetry_list() {
  poetry env list --full-path
}
alias poetry-list='poetry_list'

poetry_update_all() {
  for env in $(poetry env list | awk '{print $1}'); do
    echo "Updating Poetry environment: $env..."
    poetry update --no-interaction
    if [ $? -eq 0 ]; then
      echo "✅ Poetry environment '$env' updated successfully."
    else
      echo "❌ Failed to update Poetry environment '$env'."
    fi
  done
}
alias poetry-update-all='poetry_update_all'

poetry_generate_requirements() {
  echo "Generating requirements.txt from Poetry..."
  poetry export -f requirements.txt --output requirements.txt --without-hashes
  if [ $? -eq 0 ]; then
    echo "✅ requirements.txt generated successfully."
  else
    echo "❌ Failed to generate requirements.txt."
  fi
}
alias poetry-requirements='poetry_generate_requirements'

# Activate Poetry shell
alias penv='poetry shell'


# ------------------------------
# Virtual Environment Manager Selection (Pipenv or Poetry)
# ------------------------------
# Set VENV_MANAGER to pipenv (default) or poetry:
#
# To use Pipenv:
#     export VENV_MANAGER="pipenv"
#
# To use Poetry:
#     export VENV_MANAGER="poetry"
#
#
# Functions dynamically check VENV_MANAGER and use the correct tool (pipenv or poetry).
# Aliases remain unchanged (dj_migrate, venv, etc.), making it seamless to switch.
export VENV_MANAGER=${VENV_MANAGER:-pipenv}  # Default to pipenv


# ------------------------------
# Django: Useful Commands (Supports Pipenv & Poetry)
# ------------------------------
dj_runserver() {
  local python_version="$1"
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry run "$python_version" manage.py runserver
  else
    pipenv run "$python_version" manage.py runserver
  fi
}

alias dj='dj_runserver python3'
alias dj311='dj_runserver python3.11'
alias dj312='dj_runserver python3.12'

dj_makemigrations() {
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry run python manage.py makemigrations
  else
    pipenv run python manage.py makemigrations
  fi
}
alias dj_makemigrations='dj_makemigrations'

dj_migrate() {
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry run python manage.py migrate
  else
    pipenv run python manage.py migrate
  fi
}
alias dj_migrate='dj_migrate'

dj_sqlmigrate() {
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry run python manage.py sqlmigrate "$@"
  else
    pipenv run python manage.py sqlmigrate "$@"
  fi
}
alias dj_sqlmigrate='dj_sqlmigrate'

dj_flush() {
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry run python manage.py flush
  else
    pipenv run python manage.py flush
  fi
}
alias dj_flush='dj_flush'

# Create a new Django project
dj_create_project() {
  local project_name="$1"
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry run django-admin startproject "$project_name"
  else
    pipenv run django-admin startproject "$project_name"
  fi
}
alias dj_new='dj_create_project'

# Create a new Django app
dj_create_app() {
  local app_name="$1"
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry run python manage.py startapp "$app_name"
  else
    pipenv run python manage.py startapp "$app_name"
  fi
}
alias dj_app='dj_create_app'

# Activate virtual environment
venv_activate() {
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry shell
  else
    pipenv shell
  fi
}
alias venv='venv_activate'

# ------------------------------
# Virtual Environment Management
# ------------------------------
venv_list() {
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry env list --full-path
  else
    for venv in ~/.local/share/virtualenvs/*; do
      venv_name=$(basename "$venv")
      venv_path="$venv"
      project_file="$venv/.project"

      python_version=$(find "$venv/bin" -name "python*" 2>/dev/null | head -n 1 | xargs -I {} readlink -f {} | xargs -I {} dirname {} | xargs -I {} dirname {} | xargs -I {} basename {} | sed 's/python//')

      if [ -f "$project_file" ]; then
        project_name=$(cat "$project_file")
        echo -e "$venv_name\t$project_name\tPython $python_version\t$venv_path"
      else
        echo -e "$venv_name\t(No project found)\tPython $python_version\t$venv_path"
      fi
    done | column -t -s $'\t'
  fi
}
alias venv-list='venv_list'

venv_update_all() {
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry update --no-interaction
  else
    for venv in ~/.local/share/virtualenvs/*; do
      echo "Updating $(basename "$venv")..."
      (cd "$venv" && pipenv update) && echo "✅ Updated" || echo "❌ Update failed"
    done
  fi
}
alias venv-update-all='venv_update_all'

venv_generate_requirements() {
  if [[ "$VENV_MANAGER" == "poetry" ]]; then
    poetry export -f requirements.txt --output requirements.txt --without-hashes
  else
    for venv in ~/.local/share/virtualenvs/*; do
      echo "Generating requirements.txt for $(basename "$venv")..."
      (cd "$venv" && pipenv requirements > requirements.txt) && echo "✅ Generated" || echo "❌ Failed"
    done
  fi
}
alias venv-requirements='venv_generate_requirements'



# ------------------------------
# Python: Version control
# ------------------------------
py_version() {
  local python_version="$1"
  shift
  "$python_version" "$@"
}

alias py='py_version python3'
alias py311='py_version python3.11'
alias py312='py_version python3.12'
alias pym='py manage.py'


# ------------------------------
# Secure commands to prevent accidental deletion
# ------------------------------
alias rm='rm -iv --preserve-root'
alias cp='cp -iv'
alias mv='mv -iv'
alias ln='ln -iv'


# ------------------------------
# System utilities
# ------------------------------
alias mkdir='mkdir -pv'
alias which='type -a'

alias grep='grep --color=auto'
alias ping='ping -c 5' # Run ping 5 times and exit
alias wget='wget -c' # Continue download on error

# System update (Fedora/DNF)
alias sys_update='sudo dnf update -y && sudo dnf autoremove'
alias dnfu='sys_update'


# ------------------------------
# Bun (JavaScript runtime)
# ------------------------------
export BUN_INSTALL="$HOME/.local/share/reflex/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

