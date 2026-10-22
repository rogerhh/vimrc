#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
if [[ -L "$config_dir" && "$(readlink "$config_dir")" == "$repo_dir/nvim" ]]; then
    echo "Already configured: $config_dir"
    exit 0
fi
mkdir -p "$(dirname -- "$config_dir")"
if [[ -e "$config_dir" || -L "$config_dir" ]]; then
    backup="${config_dir}.backup.$(date +%Y%m%d-%H%M%S).$$"
    mv -- "$config_dir" "$backup"
    echo "Previous configuration backed up to $backup"
fi
ln -s -- "$repo_dir/nvim" "$config_dir"
echo "Configured Neovim: $config_dir -> $repo_dir/nvim"
echo "Launch nvim to install plugins, then use :Mason to install language servers."
