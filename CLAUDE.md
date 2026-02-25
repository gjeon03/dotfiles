# dotfiles

GNU Stow로 관리하는 개인 dotfiles. macOS 기준.

전체 구조와 각 설정에 대한 설명은 @README.md 참고.

## Structure

각 최상위 디렉토리가 하나의 Stow 패키지. 내부 구조는 `$HOME`을 미러링한다.

```
claude/          → ~/.claude/ (CLAUDE.md, settings.json, commands/)
```

## Commands

- Install all: `./install.sh`
- Install one: `stow <package>`
- Remove: `stow -D <package>`
- Update: `stow --restow <package>`

## Conventions

- One directory per tool
- Mirror `$HOME` structure inside each package
- Machine-specific overrides use `.local` suffix (gitignored)
- 새 설정 추가 시 README.md에 설명을 반드시 기록할 것
