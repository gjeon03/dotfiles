#!/usr/bin/env bash
# init.sh — Idempotent dotfiles bootstrap
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  if [[ "$(uname)" == "Darwin" ]] && ! command -v brew &>/dev/null; then
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
    else
      echo "Install stow: https://www.gnu.org/software/stow/"
      exit 1
    fi
  fi
}

# ─── Homebrew Packages ───────────────────────────────────
install_brew_packages() {
  if ! command -v brew &>/dev/null; then
    return
  fi

  echo ""
  echo "─── Homebrew packages ───"

  if [[ ! -f "$DOTFILES_DIR/Brewfile" ]]; then
    warn "Brewfile not found. Skipping."
    return
  fi

  read -rp "[?] Install Homebrew packages from Brewfile? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    info "Homebrew packages installed"
  else
    info "Skipped Homebrew packages"
  fi
}

# ─── Shell & Plugin Setup ────────────────────────────────
setup_shell() {
  echo ""
  echo "─── Shell setup ───"

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

  # tmux TPM
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    info "tmux TPM installed (run prefix + I inside tmux to install plugins)"
  else
    info "tmux TPM (already installed)"
  fi
}

# ─── Backup & Stow ───────────────────────────────────────
backup_existing() {
  local dest="$1"
  local src="$2"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    # 차이가 없으면 백업 없이 제거만
    if diff -q "$dest" "$src" &>/dev/null; then
      rm "$dest"
      return
    fi
    # 차이가 있으면 diff 표시
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
  stow --restow "$pkg"
  info "Stowed: $pkg"
}

# ─── Claude Code: Plugins ────────────────────────────────
# 플러그인은 settings.json의 enabledPlugins + extraKnownMarketplaces로 관리됨
# Stow로 settings.json이 심링크되면 Claude Code 재시작 시 자동 적용
setup_claude_plugins() {
  echo ""
  echo "─── Claude Code plugins ───"
  info "Plugins are managed via settings.json (applied on Claude Code restart)"
  info "  Enabled: oh-my-claudecode, context7, security-guidance, frontend-design, playwright"
}

# ─── Claude Code: MCP Servers ────────────────────────────
# MCP 서버 설정은 ~/.claude.json에 저장됨 (심링크/버전관리 불가)
# 따라서 CLI 명령어로 등록해야 함
setup_claude_mcp() {
  if ! command -v claude &>/dev/null; then
    return
  fi

  echo ""
  echo "─── Claude Code MCP servers ───"

  # ── stdio 기반 MCP 서버 ──
  # 형식: "이름|명령어|인자"
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

  # ── HTTP transport 기반 MCP 서버 ──
  # 형식: "이름|URL"
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

  # ── API 키가 필요한 MCP 서버 (안내만 출력) ──
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

# ─── Main ─────────────────────────────────────────────────
main() {
  echo "─── dotfiles install ───"
  echo ""

  check_deps
  install_brew_packages
  setup_shell

  echo ""
  echo "─── Stow packages ───"

  # Stow packages (add new packages here)
  local packages=(
    claude
    zsh
    tmux
    nvim
    karabiner
    yazi
  )

  for pkg in "${packages[@]}"; do
    stow_package "$pkg"
  done

  # Claude Code setup (plugins + MCP)
  setup_claude_plugins
  setup_claude_mcp

  echo ""
  info "Done. Restart your shell if needed."
}

main "$@"
