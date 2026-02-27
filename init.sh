#!/usr/bin/env bash
# init.sh — Idempotent dotfiles bootstrap (macOS + Linux)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname)"

# ─── Colors ───────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { printf "${GREEN}[✓]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[!]${NC} %s\n" "$1"; }
error() { printf "${RED}[✗]${NC} %s\n" "$1"; }

# ─── Prerequisites ────────────────────────────────────────
check_deps() {
  if [[ "$OS" == "Darwin" ]] && ! command -v brew &>/dev/null; then
    error "Homebrew not found. Install: https://brew.sh"
    exit 1
  fi

  if ! command -v stow &>/dev/null; then
    error "GNU Stow not found."
    if command -v brew &>/dev/null; then
      read -rp "Install via Homebrew? [y/N] " answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        brew install stow
        info "Stow installed"
      else
        exit 1
      fi
    elif command -v apt &>/dev/null; then
      read -rp "Install via apt? [y/N] " answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        sudo apt install -y stow
        info "Stow installed"
      else
        exit 1
      fi
    elif command -v dnf &>/dev/null; then
      read -rp "Install via dnf? [y/N] " answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        sudo dnf install -y stow
        info "Stow installed"
      else
        exit 1
      fi
    elif command -v pacman &>/dev/null; then
      read -rp "Install via pacman? [y/N] " answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        sudo pacman -S --needed stow
        info "Stow installed"
      else
        exit 1
      fi
    else
      echo "Install stow: https://www.gnu.org/software/stow/"
      exit 1
    fi
  fi
}

# ─── Package Installation ────────────────────────────────
install_packages() {
  echo ""
  echo "─── Package installation ───"

  # Homebrew available (macOS or Linuxbrew)
  if command -v brew &>/dev/null; then
    if [[ ! -f "$DOTFILES_DIR/Brewfile" ]]; then
      warn "Brewfile not found. Skipping."
      return
    fi

    read -rp "[?] Install packages from Brewfile? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      brew bundle --file="$DOTFILES_DIR/Brewfile"
      info "Brew packages installed"
    else
      info "Skipped Brew packages"
    fi
    return
  fi

  # Linux without Homebrew — use native package manager
  local pkg_file=""
  local pkg_cmd=""

  if command -v apt &>/dev/null; then
    pkg_file="$DOTFILES_DIR/packages.apt"
    pkg_cmd="sudo apt install -y"
  elif command -v dnf &>/dev/null; then
    pkg_file="$DOTFILES_DIR/packages.dnf"
    pkg_cmd="sudo dnf install -y"
  elif command -v pacman &>/dev/null; then
    pkg_file="$DOTFILES_DIR/packages.pacman"
    pkg_cmd="sudo pacman -S --needed"
  fi

  if [[ -z "$pkg_file" ]]; then
    warn "No supported package manager found. Install packages manually."
    return
  fi

  if [[ ! -f "$pkg_file" ]]; then
    warn "Package list not found: $pkg_file. Skipping."
    return
  fi

  read -rp "[?] Install packages from $(basename "$pkg_file")? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    # Read non-comment, non-empty lines
    grep -v '^\s*#' "$pkg_file" | grep -v '^\s*$' | xargs $pkg_cmd
    info "System packages installed"
  else
    info "Skipped system packages"
  fi
}

# ─── Shell Selection ─────────────────────────────────────
CHOSEN_SHELL=""

choose_shell() {
  echo ""
  echo "─── Shell selection ───"

  if command -v zsh &>/dev/null && command -v bash &>/dev/null; then
    read -rp "[?] Which shell to configure? [zsh/bash] (default: zsh) " answer
    case "$answer" in
      [Bb]ash) CHOSEN_SHELL="bash" ;;
      *)       CHOSEN_SHELL="zsh" ;;
    esac
  elif command -v zsh &>/dev/null; then
    CHOSEN_SHELL="zsh"
  else
    CHOSEN_SHELL="bash"
  fi

  info "Selected shell: $CHOSEN_SHELL"
}

# ─── Shell & Plugin Setup ────────────────────────────────
setup_shell() {
  echo ""
  echo "─── Shell setup ───"

  if [[ "$CHOSEN_SHELL" == "zsh" ]]; then
    setup_zsh
  else
    info "bash requires no extra setup (stow only)"
  fi

  # tmux TPM (shared)
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    info "tmux TPM installed (run prefix + I inside tmux to install plugins)"
  else
    info "tmux TPM (already installed)"
  fi
}

setup_zsh() {
  # oh-my-zsh
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    read -rp "[?] Install oh-my-zsh? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
      info "oh-my-zsh installed"
    fi
  else
    info "oh-my-zsh (already installed)"
  fi

  # zsh plugins
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
      info "zsh-syntax-highlighting installed"
    else
      info "zsh-syntax-highlighting (already installed)"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
      git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
      info "zsh-autosuggestions installed"
    else
      info "zsh-autosuggestions (already installed)"
    fi

    # Powerlevel10k theme
    if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
      info "Powerlevel10k installed"
    else
      info "Powerlevel10k (already installed)"
    fi
  fi
}

# ─── Backup & Stow ───────────────────────────────────────
backup_existing() {
  local dest="$1"
  local src="$2"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    # No diff = remove silently
    if diff -q "$dest" "$src" &>/dev/null; then
      rm "$dest"
      return
    fi
    # Show diff for conflicting files
    echo ""
    warn "Conflict: $dest (existing file differs from dotfiles)"
    echo "─── diff (existing → dotfiles) ───"
    diff --color=auto -u "$dest" "$src" || true
    echo "───────────────────────────────────"
    local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    warn "Backed up: $dest → $backup"
  fi
}

stow_package() {
  local pkg="$1"
  if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
    return
  fi

  # Backup existing real files that would conflict
  while IFS= read -r -d '' target; do
    local rel="${target#"$DOTFILES_DIR/$pkg/"}"
    local dest="$HOME/$rel"
    backup_existing "$dest" "$target"
  done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)

  cd "$DOTFILES_DIR"
  stow --restow --no-folding -t "$HOME" "$pkg"
  info "Stowed: $pkg"
}

# ─── Claude Code: Plugins ────────────────────────────────
setup_claude_plugins() {
  echo ""
  echo "─── Claude Code plugins ───"
  info "Plugins are managed via settings.json (applied on Claude Code restart)"
  info "  Enabled: oh-my-claudecode, context7, security-guidance, frontend-design, playwright"
}

# ─── Claude Code: MCP Servers ────────────────────────────
setup_claude_mcp() {
  if ! command -v claude &>/dev/null; then
    return
  fi

  echo ""
  echo "─── Claude Code MCP servers ───"

  # ── stdio MCP servers ──
  local mcp_servers=(
    "playwright|npx|@playwright/mcp@latest"
    "sequential-thinking|npx|-y @modelcontextprotocol/server-sequential-thinking"
    "memory|npx|-y @modelcontextprotocol/server-memory"
  )

  for entry in "${mcp_servers[@]}"; do
    IFS='|' read -r name cmd args <<< "$entry"

    if claude mcp list 2>/dev/null | grep -q "$name"; then
      info "MCP: $name (already configured)"
    else
      if claude mcp add --scope user "$name" -- "$cmd" $args 2>/dev/null; then
        info "MCP: $name (added)"
      else
        warn "MCP: $name (failed to add — run manually: claude mcp add --scope user $name $cmd $args)"
      fi
    fi
  done

  # ── HTTP transport MCP servers ──
  local mcp_http_servers=(
    "context7|https://mcp.context7.com/mcp"
  )

  for entry in "${mcp_http_servers[@]}"; do
    IFS='|' read -r name url <<< "$entry"

    if claude mcp list 2>/dev/null | grep -q "$name"; then
      info "MCP: $name (already configured)"
    else
      if claude mcp add --scope user --transport http "$name" "$url" 2>/dev/null; then
        info "MCP: $name (added via HTTP)"
      else
        warn "MCP: $name (failed — run manually: claude mcp add --scope user --transport http $name $url)"
      fi
    fi
  done

  # ── API key required (info only) ──
  if ! claude mcp list 2>/dev/null | grep -q "supabase"; then
    echo ""
    warn "MCP: supabase requires an access token."
    warn "  Run manually: claude mcp add --scope user supabase \\"
    warn "    npx -y @supabase/mcp-server-supabase@latest \\"
    warn "    --access-token <YOUR_SUPABASE_TOKEN>"
  else
    info "MCP: supabase (already configured)"
  fi
}

# ─── Profile: System ─────────────────────────────────────
run_system() {
  install_packages
  choose_shell
  setup_shell

  echo ""
  echo "─── Stow packages (system) ───"

  local packages=(git tmux nvim yazi)

  if [[ "$CHOSEN_SHELL" == "zsh" ]]; then
    packages+=(zsh)
  else
    packages+=(bash)
  fi

  if [[ "$OS" == "Darwin" ]]; then
    packages+=(karabiner)
  fi

  for pkg in "${packages[@]}"; do
    stow_package "$pkg"
  done
}

# ─── Profile: Claude Code ───────────────────────────────
run_claude() {
  echo ""
  echo "─── Stow packages (claude) ───"
  stow_package claude

  setup_claude_plugins
  setup_claude_mcp
}

# ─── Main ─────────────────────────────────────────────────
PROFILE=""

usage() {
  echo "Usage: ./init.sh [--system|--claude|--all]"
  echo ""
  echo "  --system   Shell, packages, and tool configs only"
  echo "  --claude   Claude Code settings only"
  echo "  --all      Both (no prompt)"
  echo "  (none)     Interactive selection"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --system) PROFILE="system" ;;
      --claude) PROFILE="claude" ;;
      --all)    PROFILE="all" ;;
      -h|--help) usage; exit 0 ;;
      *) error "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  echo "─── dotfiles install ───"
  echo "  OS: $OS"
  echo ""

  check_deps

  # Interactive profile selection
  if [[ -z "$PROFILE" ]]; then
    echo "What to set up?"
    echo "  1) All        — system + Claude Code"
    echo "  2) System     — shell, packages, tools"
    echo "  3) Claude     — Claude Code settings"
    read -rp "[?] Choose [1/2/3] (default: 1) " answer
    case "$answer" in
      2) PROFILE="system" ;;
      3) PROFILE="claude" ;;
      *) PROFILE="all" ;;
    esac
    echo ""
  fi

  case "$PROFILE" in
    system)
      run_system
      ;;
    claude)
      run_claude
      ;;
    all)
      run_system
      run_claude
      ;;
  esac

  echo ""
  info "Done. Restart your shell if needed."
}

main "$@"
