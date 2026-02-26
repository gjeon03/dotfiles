# ─── Non-interactive bail out ─────────────────────────────
[[ $- != *i* ]] && return

# ─── Editor ──────────────────────────────────────────────
export EDITOR="nvim"
alias vim="nvim"
alias vi="nvim"
alias vimdiff="nvim -d"

# ─── Modern CLI tools ───────────────────────────────────
# bat (cat replacement)
if command -v bat &>/dev/null; then
  alias cat="bat"
  export BAT_THEME="tokyonight_night"
elif command -v batcat &>/dev/null; then
  alias cat="batcat"
  export BAT_THEME="tokyonight_night"
fi

# eza (ls replacement)
if command -v eza &>/dev/null; then
  alias ls="eza --icons"
  alias ll="eza -la --icons --git"
  alias lt="eza --tree --icons --level=2"
fi

# zoxide (cd replacement)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

# fzf
if command -v fzf &>/dev/null; then
  eval "$(fzf --bash 2>/dev/null)" || true
fi

# fzf + fd
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
elif command -v fdfind &>/dev/null; then
  export FZF_DEFAULT_COMMAND="fdfind --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fdfind --type=d --hidden --strip-cwd-prefix --exclude .git"
fi

# yazi wrapper (cd into dir on exit)
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd" || return
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
if [[ -n "$HOMEBREW_PREFIX" && -f "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh" ]]; then
  . "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh"
elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  . "$HOME/.asdf/asdf.sh"
fi
export PATH="$HOME/.asdf/shims:$PATH"

# ─── pnpm ────────────────────────────────────────────────
case "$(uname)" in
  Darwin) export PNPM_HOME="$HOME/Library/pnpm" ;;
  *)      export PNPM_HOME="$HOME/.local/share/pnpm" ;;
esac
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ─── PATH ────────────────────────────────────────────────
[[ -n "$HOMEBREW_PREFIX" ]] && export PATH="$HOMEBREW_PREFIX/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ─── Prompt (git-aware) ──────────────────────────────────
__git_branch() {
  local branch
  branch="$(git branch --show-current 2>/dev/null)"
  [[ -n "$branch" ]] && printf " (%s)" "$branch"
}

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(__git_branch)\[\033[00m\]\$ '

# ─── Local overrides (not tracked) ──────────────────────
[[ -f "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"
