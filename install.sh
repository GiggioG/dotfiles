#!/bin/bash

# WARNING: possible AI slop
# I will learn bash some day, but that day is not today.
# Copilot helped a lot with this script, and while i checked it,
# it is still possible that it contains bugs or inconsistencies.

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

symlink_with_backup() {
    local src="$1"
    local target="$2"
    local type="${3:-file}" # Default to file if not specified

    if [[ -e "$target" ]]; then
        read -p "Backup existing $(basename "$target") to $(basename "$target").bak? [y/N] " backup_answer
        if [[ "$backup_answer" =~ ^[Yy]$ ]]; then
            if [[ "$type" = "dir" ]]; then
                cp -r "$target" "$target.bak"
            else
                cp "$target" "$target.bak"
            fi
            echo "Backed up existing $(basename "$target") to $(basename "$target").bak"
        fi
        if [[ "$type" = "dir" ]]; then
            rm -rf "$target"
        else
            rm -f "$target"
        fi
        echo "Removed existing $(basename "$target")"
    fi
    ln -s "$src" "$target"
    echo "Symlinked $(basename "$src") to $target"
}

read -p "Symlink bashrc? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    symlink_with_backup "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    symlink_with_backup "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
    symlink_with_backup "$DOTFILES_DIR/.bash_scripts" "$HOME/.bash_scripts" "dir"
fi

read -p "Symlink vim configuration? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    symlink_with_backup "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
    symlink_with_backup "$DOTFILES_DIR/.vim" "$HOME/.vim" "dir"
fi

read -p "Symlink emacs configuration? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    create_symlink="true"
    if [[ ! -d "$HOME/.emacs.d" ]]; then
        read -p ".emacs.d directory does not exist. Create it? [y/N] " create_answer
        if [[ "$create_answer" =~ ^[Yy]$ ]]; then
            mkdir -p "$HOME/.emacs.d"
            echo "Created $HOME/.emacs.d directory"
        else
            create_symlink="false"
            echo "Skipping .emacs.d/init.el symlink as the directory .emacs.d does not exist."
        fi
    fi
    if [[ "$create_symlink" = "true" ]]; then
        symlink_with_backup "$DOTFILES_DIR/.emacs.d/init.el" "$HOME/.emacs.d/init.el"
    fi
fi