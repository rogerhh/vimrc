#!/usr/bin/env bash
# Copy the active Neovim setup, installed tools, and vim alias to an SSH host.
set -Eeuo pipefail
usage() {
    printf 'Usage: %s [user@]hostname\n\nSSH aliases from ~/.ssh/config are supported.\nExample: %s horde\n\nCopies Neovim, plugins, language servers, Node/npm, and the vim alias.\nThe destination must be Linux x86_64 with Git and rsync installed.\nExisting remote settings are backed up.\n' "${0##*/}" "${0##*/}"
}
if [[ ${1:-} == -h || ${1:-} == --help ]]; then
    usage
    exit 0
fi
if [[ $# != 1 ]]; then
    usage >&2
    exit 2
fi
target=$1
if [[ ! $target =~ ^([a-zA-Z0-9_.-]+@)?[a-zA-Z0-9_][a-zA-Z0-9_.-]*$ ]]; then
    printf 'Invalid target: use a hostname, user@hostname, or SSH alias.\n' >&2
    exit 2
fi
source_config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
source_data="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
stamp="$(date +%Y%m%d-%H%M%S)-$$"
stage=".cache/codex-nvim-sync-$stamp"
ssh_opts=(-o ConnectTimeout=15 -o ServerAliveInterval=15 -o ServerAliveCountMax=3)
phase="local checks"
report_failure() {
    local status=$?
    printf '\nSync failed during %s (exit %s).\n' "$phase" "$status" >&2
    exit "$status"
}
trap report_failure ERR
trap 'printf "\nSync interrupted during %s. Rerun the script to try again.\n" "$phase" >&2; exit 130' INT
rsync_opts=(-az --human-readable --info=progress2 --timeout=120
    -e 'ssh -o ConnectTimeout=15 -o ServerAliveInterval=15 -o ServerAliveCountMax=3')
upload() {
    local label=$1 source=$2 destination=$3
    phase="uploading $label"
    printf '\nUploading %s...\n' "$label"
    rsync "${rsync_opts[@]}" "$source/" "$target:$stage/$destination/"
}
for executable in ssh rsync readlink; do
    command -v "$executable" >/dev/null || { echo "Missing local $executable" >&2; exit 1; }
done
nvim_root="$(dirname -- "$(dirname -- "$(readlink -f "$HOME/.local/bin/nvim")")")"
node_root="$(dirname -- "$(dirname -- "$(readlink -f "$HOME/.local/bin/node")")")"
unzip_root="$(dirname -- "$(dirname -- "$(readlink -f "$HOME/.local/bin/unzip")")")"
for directory in "$source_config" "$source_data/lazy" "$source_data/mason" "$nvim_root" "$node_root" "$unzip_root" "$HOME/.local/opt/icu"; do
    [[ -d "$directory" ]] || { echo "Missing local source: $directory" >&2; exit 1; }
done
phase="SSH connection and remote checks"
printf 'Checking %s and preparing upload...\n' "$target"
ssh "${ssh_opts[@]}" "$target" "bash -s -- '$stage'" <<'PREFLIGHT'
set -euo pipefail
[[ "$(uname -sm)" == 'Linux x86_64' ]] || { echo 'This payload requires Linux x86_64.' >&2; exit 1; }
command -v rsync >/dev/null || { echo 'Install rsync on the destination first.' >&2; exit 1; }
command -v git >/dev/null || { echo 'Install git on the destination first.' >&2; exit 1; }
for name in .bashrc .bash_aliases; do
    if [[ -L "$HOME/$name" ]]; then
        echo "Symlinked $name requires a host-specific alias destination; no changes made." >&2
        exit 1
    fi
done
mkdir -p "$HOME/$1"/{config,lazy,mason,nvim,node,unzip,icu}
PREFLIGHT
# Trailing slashes transfer directory contents. Relative Mason/npm links are retained.
printf 'Remote checks passed. Uploading config and tools; the first sync can take several minutes.\n'
upload 'Neovim configuration' "$source_config" config
upload 'Neovim plugins' "$source_data/lazy" lazy
upload 'language servers' "$source_data/mason" mason
upload 'Neovim runtime' "$nvim_root" nvim
upload 'Node.js and npm' "$node_root" node
upload 'unzip' "$unzip_root" unzip
upload 'ICU libraries' "$HOME/.local/opt/icu" icu
phase="remote installation and verification"
printf '\nUploads complete. Installing and verifying on %s...\n' "$target"
ssh "${ssh_opts[@]}" "$target" "bash -s -- '$stage' '$stamp'" <<'INSTALL'
set -euo pipefail
payload="$HOME/$1"
backup="$HOME/.local/share/nvim-sync-backups/$2"
config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
data="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
# Check binary compatibility before changing the active configuration.
"$payload/nvim/bin/nvim" --headless -u NONE -i NONE '+lua assert(vim.fn.has("nvim-0.11.3") == 1)' +qa
"$payload/node/bin/node" --version
PATH="$payload/node/bin:$PATH" "$payload/node/bin/npm" --version
"$payload/unzip/bin/unzip" -v >/dev/null
"$payload/mason/bin/clangd" --version
"$payload/mason/bin/starpls" version
"$payload/mason/bin/neocmakelsp" --version
"$payload/mason/bin/taplo" --version
LD_LIBRARY_PATH="$payload/icu/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" "$payload/mason/bin/marksman" --version
mkdir -p "$backup" "$(dirname -- "$config")" "$data" "$HOME/.local/bin" "$HOME/.local/opt"
backup_move() {
    local source="$1" name="$2"
    if [[ -e "$source" || -L "$source" ]]; then mv -- "$source" "$backup/$name"; fi
}
backup_move "$config" config
backup_move "$data/lazy" lazy
backup_move "$data/mason" mason
for name in nvim node npm npx unzip; do backup_move "$HOME/.local/bin/$name" "bin-$name"; done
backup_move "$HOME/.local/opt/icu" icu
# Versioned payload retains runtimes without touching the system installation.
install="$HOME/.local/opt/nvim-sync-$2"
mv -- "$payload" "$install"
mv -- "$install/config" "$config"
mv -- "$install/lazy" "$data/lazy"
mv -- "$install/mason" "$data/mason"
ln -s -- "$install/nvim/bin/nvim" "$HOME/.local/bin/nvim"
for name in node npm npx; do ln -s -- "$install/node/bin/$name" "$HOME/.local/bin/$name"; done
ln -s -- "$install/unzip/bin/unzip" "$HOME/.local/bin/unzip"
ln -s -- "$install/icu" "$HOME/.local/opt/icu"
# Preserve all existing Bash settings and aliases; the final alias takes precedence.
for name in .bashrc .bash_aliases; do
    if [[ -f "$HOME/$name" ]]; then cp -p -- "$HOME/$name" "$backup/$name"; fi
    if [[ -L "$HOME/$name" ]]; then
        echo "Refusing to change symlinked $name. Neovim synced; configure the alias manually." >&2
        exit 1
    fi
done
if [[ "$(tail -n 1 "$HOME/.bash_aliases" 2>/dev/null || true)" != "alias vim='nvim'" ]]; then
    printf "\nalias vim='nvim'\n" >> "$HOME/.bash_aliases"
fi
# Managed block is added once. Source the alias explicitly for shells lacking it.
if ! grep -Fxq '# BEGIN synced Neovim setup' "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'BASHRC'

# BEGIN synced Neovim setup
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi
# END synced Neovim setup
BASHRC
fi
export PATH="$HOME/.local/bin:$PATH"
# Use disposable cache/state paths so no old bytecode or session data is reused.
verify="$install/verify"
mkdir -p "$verify"/{cache,state}
XDG_CACHE_HOME="$verify/cache" XDG_STATE_HOME="$verify/state" nvim --headless -i NONE \
    '+lua assert(vim.g.copilot_enabled == false); assert(vim.fn.exists(":Mason") == 2); for _, name in ipairs({"clangd", "starpls", "bazelrc-lsp", "neocmakelsp", "marksman", "taplo", "pyright-langserver"}) do assert(vim.fn.executable(name) == 1, name) end; assert(vim.fn.maparg(",sv", "n") ~= ""); print("Neovim sync verified")' +qa
bash -ic 'alias vim' 2>/dev/null
printf '\nBackups: %s\nOpen a new Bash shell, or run: source ~/.bashrc\n' "$backup"
INSTALL
printf 'Sync to %s complete.\n' "$target"
