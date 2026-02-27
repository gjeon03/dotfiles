# ─── OS-specific setup ────────────────────────────────────
case "$(uname)" in
  Darwin)
    # Homebrew (Apple Silicon / Intel)
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    alias ibrew="arch -x86_64 /usr/local/bin/brew"
    alias abrew="arch -arm64 /opt/homebrew/bin/brew"

    # VS Code CLI
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
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

# ─── PATH ─────────────────────────────────────────────────
export PATH="$PATH:/usr/local/bin"
