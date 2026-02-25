# ─── Powerlevel10k instant prompt ─────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── Oh My Zsh ───────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  fzf
  asdf
)

source $ZSH/oh-my-zsh.sh

# ─── Editor ──────────────────────────────────────────────
export EDITOR="nvim"
alias vim="nvim"
alias vi="nvim"
alias vimdiff="nvim -d"

# ─── Modern CLI tools ───────────────────────────────────
# bat (cat replacement)
alias cat="bat"
export BAT_THEME="tokyonight_night"

# eza (ls replacement)
if command -v eza &>/dev/null; then
  alias ls="eza --icons"
  alias ll="eza -la --icons --git"
  alias lt="eza --tree --icons --level=2"
fi

# zoxide (cd replacement)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# fzf + fd
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
fi

# yazi wrapper (cd into dir on exit)
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ─── Safety aliases ──────────────────────────────────────
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# ─── Claude Code ─────────────────────────────────────────
alias cl="claude"
alias cls="claude --dangerously-skip-permissions"

# ─── asdf ────────────────────────────────────────────────
if [[ -f "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh" ]]; then
  . "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh"
fi
export PATH="$HOME/.asdf/shims:$PATH"

# ─── pnpm ────────────────────────────────────────────────
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ─── PATH ────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ─── Powerlevel10k ───────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─── Local overrides (not tracked) ──────────────────────
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
