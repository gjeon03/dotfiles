# ─── OS-specific setup ────────────────────────────────────
case "$(uname)" in
  Darwin)
    # Homebrew (Apple Silicon / Intel)
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    ;;
  Linux)
    # Linuxbrew (if installed)
    if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -f "$HOME/.linuxbrew/bin/brew" ]]; then
      eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
    fi
    ;;
esac

# ─── Source .bashrc ───────────────────────────────────────
[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc"

# ─── Local overrides (not tracked) ───────────────────────
[[ -f "$HOME/.bash_profile.local" ]] && source "$HOME/.bash_profile.local"
