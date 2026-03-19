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
    # Install packages one by one so individual failures don't block the rest
    local failed=()
    while IFS= read -r pkg; do
      if ! $pkg_cmd "$pkg" 2>/dev/null; then
        failed+=("$pkg")
      fi
    done < <(grep -v '^\s*#' "$pkg_file" | grep -v '^\s*$')

    if [[ ${#failed[@]} -gt 0 ]]; then
      warn "Failed to install: ${failed[*]}"
    fi
    info "System packages installed"
  else
    info "Skipped system packages"
  fi

  # Tools not in standard repos — install from GitHub releases
  install_github_tools
}

# ─── GitHub Release Tools (Linux only) ───────────────────
install_github_tools() {
  # Homebrew handles everything; only needed for native pkg manager installs
  if command -v brew &>/dev/null; then
    return
  fi

  local arch
  arch="$(uname -m)"

  # ── lazygit ──
  if ! command -v lazygit &>/dev/null; then
    local lg_arch
    case "$arch" in
      x86_64)  lg_arch="x86_64" ;;
      aarch64) lg_arch="arm64" ;;
      *)       lg_arch="" ;;
    esac

    if [[ -n "$lg_arch" ]]; then
      local lg_version
      lg_version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
        | grep -Po '"tag_name":\s*"v\K[^"]*' 2>/dev/null) || true

      if [[ -n "$lg_version" ]]; then
        local tmp_dir
        tmp_dir=$(mktemp -d)
        if curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lg_version}_Linux_${lg_arch}.tar.gz" \
          | tar xz -C "$tmp_dir" lazygit 2>/dev/null; then
          sudo install "$tmp_dir/lazygit" /usr/local/bin/lazygit
          info "lazygit $lg_version installed (GitHub release)"
        else
          warn "lazygit: failed to download (check network)"
        fi
        rm -rf "$tmp_dir"
      else
        warn "lazygit: failed to fetch latest version"
      fi
    else
      warn "lazygit: unsupported architecture $arch"
    fi
  else
    info "lazygit (already installed)"
  fi

  # ── cloudflared ──
  if ! command -v cloudflared &>/dev/null; then
    local cf_arch
    case "$arch" in
      x86_64)  cf_arch="amd64" ;;
      aarch64) cf_arch="arm64" ;;
      *)       cf_arch="" ;;
    esac

    if [[ -n "$cf_arch" ]]; then
      if curl -fsSL -o /tmp/cloudflared "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${cf_arch}" 2>/dev/null; then
        sudo install /tmp/cloudflared /usr/local/bin/cloudflared
        rm -f /tmp/cloudflared
        info "cloudflared installed (GitHub release)"
      else
        warn "cloudflared: failed to download (check network)"
      fi
    else
      warn "cloudflared: unsupported architecture $arch"
    fi
  else
    info "cloudflared (already installed)"
  fi

  # ── yazi ──
  if ! command -v yazi &>/dev/null; then
    local yz_arch
    case "$arch" in
      x86_64)  yz_arch="x86_64" ;;
      aarch64) yz_arch="aarch64" ;;
      *)       yz_arch="" ;;
    esac

    if [[ -n "$yz_arch" ]]; then
      # yazi release is a .zip — ensure unzip is available
      if ! command -v unzip &>/dev/null; then
        if command -v apt &>/dev/null; then
          sudo apt install -y unzip 2>/dev/null
        elif command -v dnf &>/dev/null; then
          sudo dnf install -y unzip 2>/dev/null
        fi
      fi
      if ! command -v unzip &>/dev/null; then
        warn "yazi: unzip not found, skipping"
        return
      fi

      local tmp_dir
      tmp_dir=$(mktemp -d)
      if curl -fsSL -o "$tmp_dir/yazi.zip" \
        "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${yz_arch}-unknown-linux-gnu.zip" 2>/dev/null \
        && unzip -q "$tmp_dir/yazi.zip" -d "$tmp_dir" 2>/dev/null; then
        sudo install "$tmp_dir"/yazi-*/yazi /usr/local/bin/yazi
        # ya (yazi helper)
        if compgen -G "$tmp_dir"/yazi-*/ya >/dev/null 2>&1; then
          sudo install "$tmp_dir"/yazi-*/ya /usr/local/bin/ya
        fi
        info "yazi installed (GitHub release)"
      else
        warn "yazi: failed to download (check network)"
      fi
      rm -rf "$tmp_dir"
    else
      warn "yazi: unsupported architecture $arch"
    fi
  else
    info "yazi (already installed)"
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
    if git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null; then
      info "tmux TPM installed (run prefix + I inside tmux to install plugins)"
    else
      warn "tmux TPM failed to install (check network)"
    fi
  else
    info "tmux TPM (already installed)"
  fi
}

setup_zsh() {
  # oh-my-zsh
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    read -rp "[?] Install oh-my-zsh? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      if RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
        info "oh-my-zsh installed"
      else
        warn "oh-my-zsh failed to install (check network)"
      fi
    fi
  else
    info "oh-my-zsh (already installed)"
  fi

  # zsh plugins
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
      if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null; then
        info "zsh-syntax-highlighting installed"
      else
        warn "zsh-syntax-highlighting failed to install (check network)"
      fi
    else
      info "zsh-syntax-highlighting (already installed)"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
      if git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null; then
        info "zsh-autosuggestions installed"
      else
        warn "zsh-autosuggestions failed to install (check network)"
      fi
    else
      info "zsh-autosuggestions (already installed)"
    fi

    # Powerlevel10k theme
    if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
      if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" 2>/dev/null; then
        info "Powerlevel10k installed"
      else
        warn "Powerlevel10k failed to install (check network)"
      fi
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

# ─── Claude Code: Skills (npx skills) ────────────────────
setup_claude_skills() {
  if ! command -v npx &>/dev/null; then
    warn "npx not found. Skipping skills installation."
    return
  fi

  echo ""
  echo "─── Claude Code skills ───"

  local lock_file="$HOME/.agents/.skill-lock.json"

  # "source|skill1 skill2 ..." — install specific skills from each repo
  local skills=(
    "vercel-labs/skills|find-skills"
    "vercel-labs/agent-skills|vercel-react-best-practices vercel-composition-patterns web-design-guidelines"
    "obra/superpowers|systematic-debugging brainstorming"
    "anthropics/skills|pdf"
  )

  for entry in "${skills[@]}"; do
    IFS='|' read -r source skill_names <<< "$entry"

    local all_installed=true
    for s in $skill_names; do
      if [[ ! -d "$HOME/.agents/skills/$s" ]]; then
        all_installed=false
        break
      fi
    done

    if $all_installed; then
      info "Skill: $source (already installed)"
    else
      if npx -y skills add "$source" -g --skill $skill_names -y 2>/dev/null; then
        info "Skill: $source (installed: $skill_names)"
      else
        warn "Skill: $source (failed — run manually: npx skills add $source -g --skill $skill_names -y)"
      fi
    fi
  done
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

# ─── Git Local Config ────────────────────────────────────
setup_gitconfig_local() {
  if [[ -f "$HOME/.gitconfig.local" ]]; then
    info "Git user config (already exists: ~/.gitconfig.local)"
    return
  fi

  echo ""
  read -rp "[?] Set up git user config (~/.gitconfig.local)? [y/N] " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    warn "Skipped. Create ~/.gitconfig.local manually later:"
    warn '  git config --file ~/.gitconfig.local user.name "Your Name"'
    warn '  git config --file ~/.gitconfig.local user.email "you@example.com"'
    return
  fi

  read -rp "  user.name: " git_name
  read -rp "  user.email: " git_email

  if [[ -z "$git_name" || -z "$git_email" ]]; then
    warn "Skipped (empty input)"
    return
  fi

  cat > "$HOME/.gitconfig.local" <<EOF
[user]
    name = $git_name
    email = $git_email
EOF
  info "Git user config saved to ~/.gitconfig.local"
}

# ─── iTerm2 Setup (macOS only) ───────────────────────────
setup_iterm2() {
  if ! command -v defaults &>/dev/null; then
    return
  fi

  # Set dynamic profile as default for new windows/tabs
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "dotfiles-tokyo-night"
  info "iTerm2: dotfiles profile set as default"
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
    packages+=(karabiner wezterm iterm2 ghostty)
  fi

  for pkg in "${packages[@]}"; do
    stow_package "$pkg"
  done

  # macOS app settings
  if [[ "$OS" == "Darwin" ]]; then
    setup_iterm2
  fi

  # git user config
  setup_gitconfig_local
}

# ─── Profile: Claude Code ───────────────────────────────
run_claude() {
  echo ""
  echo "─── Stow packages (claude) ───"
  stow_package claude

  setup_claude_plugins
  setup_claude_skills
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
