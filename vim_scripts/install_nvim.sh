#!/usr/bin/env bash
set -euo pipefail
if command -v nvim >/dev/null 2>&1 && nvim --headless -u NONE '+lua assert(vim.fn.has("nvim-0.11.3") == 1)' +qa >/dev/null 2>&1; then
    nvim --version | head -n 3
    exit 0
fi
case "$(uname -sm)" in
    "Linux x86_64") arch=x86_64 ;;
    "Linux aarch64") arch=arm64 ;;
    *) echo "Install Neovim 0.11.3+ from https://neovim.io/doc/install/" >&2; exit 1 ;;
esac
install_dir="${XDG_DATA_HOME:-$HOME/.local/share}/neovim"
if [[ -e "$install_dir" || -L "$install_dir" ]]; then
    echo "Existing install at $install_dir; move it aside before installing." >&2
    exit 1
fi
if [[ -e "$HOME/.local/bin/nvim" || -L "$HOME/.local/bin/nvim" ]]; then
    echo "Existing ~/.local/bin/nvim; move it aside before installing." >&2
    exit 1
fi
scratch="$(mktemp -d)"
trap 'rm -rf -- "$scratch"' EXIT
curl -fL --retry 2 "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" -o "$scratch/nvim.tar.gz"
mkdir -p "$install_dir" "$HOME/.local/bin"
tar -xzf "$scratch/nvim.tar.gz" --strip-components=1 -C "$install_dir"
ln -s -- "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
"$HOME/.local/bin/nvim" --version | head -n 3
echo 'Ensure $HOME/.local/bin is on PATH, then run vim_scripts/set_up_all.sh.'
