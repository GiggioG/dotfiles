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
        read -p "Backup existing $(basename "$target") to $(basename "$target").bak? [Y/n] " backup_answer
        if [[ ! "$backup_answer" =~ ^[Nn]$ ]]; then
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

read -p "Symlink bashrc? [Y/n] " answer
if [[ ! "$answer" =~ ^[Nn]$ ]]; then
    symlink_with_backup "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
    symlink_with_backup "$DOTFILES_DIR/bash/.bash_profile" "$HOME/.bash_profile"
    symlink_with_backup "$DOTFILES_DIR/bash/.bash_scripts" "$HOME/.bash_scripts" "dir"
fi

read -p "Symlink vim configuration? [Y/n] " answer
if [[ ! "$answer" =~ ^[Nn]$ ]]; then
    symlink_with_backup "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
    symlink_with_backup "$DOTFILES_DIR/vim/.vim" "$HOME/.vim" "dir"
fi

read -p "Symlink emacs configuration? [Y/n] " answer
if [[ ! "$answer" =~ ^[Nn]$ ]]; then
	symlink_with_backup "$DOTFILES_DIR/emacs" "$HOME/.emacs.d" "dir"
fi
