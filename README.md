# dotfiles

GNU Stow로 관리하는 개인 설정 파일. 새 머신에서 한 번에 환경을 복원한다.

## Quick Start

```bash
# 1. 클론
git clone https://github.com/<username>/dotfiles ~/dotfiles
cd ~/dotfiles

# 2. 설치 (stow 없으면 자동 설치 안내)
./install.sh
```

## Structure

각 최상위 디렉토리가 하나의 **Stow 패키지**다. 내부 구조가 `$HOME`을 미러링하므로 `stow <패키지>`하면 해당 위치에 심링크가 생성된다.

```
dotfiles/
├── claude/                        # Claude Code 설정
│   └── .claude/
│       ├── CLAUDE.md              # → ~/.claude/CLAUDE.md
│       ├── settings.json          # → ~/.claude/settings.json
│       └── commands/              # → ~/.claude/commands/
│           ├── branch.md
│           ├── catchup.md
│           ├── cleanup.md
│           ├── commit.md
│           ├── git-convention.md
│           ├── explain.md
│           ├── fix-issue.md
│           ├── pr.md
│           ├── prime.md
│           ├── reflection.md
│           ├── setup-project.md
│           ├── task.md
│           ├── test.md
│           └── think.md
├── install.sh                     # 멱등성 부트스트랩 스크립트
├── CLAUDE.md                      # 이 레포 자체의 Claude Code 지시 파일
├── README.md
└── .gitignore
```

향후 추가 예정: `git/`, `zsh/`, `nvim/` 등.

---

## Claude Code 설정

### CLAUDE.md (글로벌 지시 파일)

`~/.claude/CLAUDE.md`에 심링크되며, **모든 프로젝트에서** Claude Code가 읽는다.

포함 내용:
- **언어**: 한국어 대화, 영어 코드/커밋
- **코드 스타일**: TypeScript strict, named exports, indent 규칙
- **패키지 매니저**: lock 파일 기반 자동 감지 (없으면 pnpm 기본)
- **프레임워크**: 기존 프로젝트 설정 우선, 새 프로젝트는 App Router + Tailwind v4
- **Git**: Conventional Commits, `--no-verify`/force push 금지
- **의사결정 프레임워크**: 자율 실행 / 제안 후 진행 / 반드시 물어보기 3단계

> 프로젝트별 설정은 글로벌에 넣지 않는다. `/setup-project` 커맨드로 각 프로젝트에 맞는 CLAUDE.md를 생성한다.

### settings.json

| 설정 | 값 | 설명 |
|------|-----|------|
| `alwaysThinkingEnabled` | `true` | 확장 사고(extended thinking) 항상 활성화 |
| `cleanupPeriodDays` | `365` | 세션 기록 1년 보존 (기본 30일) |
| `enableAllProjectMcpServers` | `false` | 프로젝트 MCP 서버 자동 승인 방지 (보안) |
| `worktree.symlinkDirectories` | `node_modules`, `.next`, `dist`, `build`, `.turbo`, `.dart_tool` | worktree 사용 시 대용량 디렉토리 심링크로 디스크 절약 |
| `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `"1"` | Agent Teams 실험 기능 활성화 |
| `skipDangerousModePermissionPrompt` | `true` | 위험 모드 진입 확인 스킵 |

**플러그인:**
- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) 활성화
- `extraKnownMarketplaces`로 OMC 마켓플레이스 소스 사전 등록 (새 머신에서 자동 발견)
- 공식 마켓플레이스 플러그인:
  - `context7` — 라이브러리 최신 문서 주입
  - `security-guidance` — 파일 수정 시 보안 취약점 자동 스캔
  - `frontend-design` — UI 디자인 판단 기준 적용
  - `playwright` — 브라우저 자동화

**차단된 명령어 (`permissions.deny`):**

| 패턴 | 이유 |
|-------|------|
| `Bash(rm -rf /)`, `Bash(rm -rf ~*)` | 시스템/홈 디렉토리 삭제 방지 |
| `Bash(sudo rm *)` | sudo 삭제 방지 |
| `Bash(git push --force*)` | force push 방지 |
| `Bash(git reset --hard*)` | 커밋되지 않은 변경 소실 방지 |
| `Bash(mkfs *)`, `Bash(dd if=*)` | 디스크 포맷/덮어쓰기 방지 |
| `Read(~/.ssh/*)`, `Read(~/.aws/*)`, `Read(~/.gnupg/*)` | 민감한 인증 정보 읽기 방지 |

**Hooks:**
- `Notification`: Claude Code가 입력 대기 상태일 때 macOS 데스크톱 알림 발송

**Status Line:**
- `user@host:dir (branch) | Model [style] | Cost: $0.00` 형식으로 표시

### 커스텀 슬래시 커맨드

`~/.claude/commands/`에 심링크되어 **어떤 프로젝트에서든** 사용 가능하다.

| 커맨드 | 용도 | 사용 예시 |
|--------|------|-----------|
| `/branch` | 이슈 분석 → 브랜치명 후보 제시 → 생성 | `/branch 42` |
| `/commit` | diff 분석 → 위험 검사 → Conventional Commit 생성 | `/commit` |
| `/git-convention` | Git 워크플로우 컨벤션 분석/설정 → 캐싱 (`~/.claude/git-conventions/`) | `/git-convention` |
| `/catchup` | `/clear` 후 작업 컨텍스트 복구 | `/catchup` |
| `/pr` | 브랜치 분석 → PR 생성 (제목+설명+테스트플랜) | `/pr` |
| `/prime` | 새 프로젝트 빠른 파악 (스택, 구조, 명령어 요약) | `/prime` |
| `/think` | 코드 작성 전 심층 분석 (3가지 접근법 비교) | `/think 인증 시스템 설계` |
| `/fix-issue` | GitHub 이슈 분석 → 수정 → 커밋 | `/fix-issue 42` |
| `/explain` | 코드 구조/동작 심층 설명 (읽기 전용) | `/explain src/auth/` |
| `/cleanup` | 미사용 import, 데드 코드, 주석 코드 정리 | `/cleanup src/utils/` |
| `/reflection` | 세션 분석 → CLAUDE.md 개선점 제안 | `/reflection` |
| `/setup-project` | 현재 프로젝트에 맞는 CLAUDE.md 자동 생성 | `/setup-project` |
| `/task` | 프로젝트별 태스크 관리 (추가/시작/완료/아카이브) | `/task`, `/task add 버그 수정`, `/task done 1` |
| `/test` | 테스트 러너 자동 감지 → 테스트 실행 → 실패 분석 | `/test`, `/test src/auth/` |

### MCP 서버

MCP 서버 설정은 `~/.claude.json`에 저장되며, 이 파일에는 OAuth 토큰 등도 포함되어 **심링크/버전관리가 불가**하다. 따라서 `install.sh`에서 `claude mcp add --scope user` 명령어로 등록한다.

| 서버 | 설명 | Transport | 등록 명령어 |
|------|------|-----------|-------------|
| Playwright | 브라우저 자동화/테스트 | stdio | `claude mcp add --scope user playwright npx @playwright/mcp@latest` |
| Sequential Thinking | 복잡한 문제 단계별 사고 | stdio | `claude mcp add --scope user sequential-thinking npx -y @modelcontextprotocol/server-sequential-thinking` |
| Memory | 세션 간 지식 그래프 유지 | stdio | `claude mcp add --scope user memory npx -y @modelcontextprotocol/server-memory` |
| Context7 | 라이브러리 최신 문서 주입 | HTTP | `claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp` |
| Supabase | DB 쿼리/마이그레이션 | stdio | `claude mcp add --scope user supabase npx -y @supabase/mcp-server-supabase@latest --access-token <TOKEN>` |

- stdio 서버를 추가하려면 `install.sh`의 `mcp_servers` 배열에 `"이름|명령어|인자"` 형식으로 추가한다.
- HTTP 서버를 추가하려면 `mcp_http_servers` 배열에 `"이름|URL"` 형식으로 추가한다.
- API 키가 필요한 서버는 `setup_claude_mcp()` 하단에 안내 메시지를 추가한다.

### 플러그인 vs MCP — 관리 방식 차이

| 항목 | 관리 파일 | Stow로 관리 | 설명 |
|------|-----------|-------------|------|
| 플러그인 활성화 | `settings.json` → `enabledPlugins` | O | 토글만 담당 (설치는 별도) |
| 마켓플레이스 소스 | `settings.json` → `extraKnownMarketplaces` | O | 새 머신에서 플러그인 소스 자동 발견 |
| 플러그인 설치 (OMC) | `~/.claude/plugins/` | X | `install.sh`에서 CLI로 설치 |
| 플러그인 설치 (공식) | `~/.claude/plugins/` | X | `install.sh`에서 `claude plugins install`로 설치 |
| MCP 서버 설정 | `~/.claude.json` | X | `install.sh`에서 CLI로 등록 |

---

## Stow 사용법

```bash
# 특정 패키지 설치 (심링크 생성)
cd ~/dotfiles
stow claude

# 패키지 제거 (심링크 삭제, 원본 유지)
stow -D claude

# 패키지 업데이트 (새 파일 추가 후)
stow --restow claude

# 전체 설치
./install.sh
```

### 새 패키지 추가하기

예시: git 설정 추가

```bash
# 1. 패키지 디렉토리 생성 ($HOME 구조 미러링)
mkdir -p git
cp ~/.gitconfig git/.gitconfig

# 2. install.sh의 packages 배열에 추가
# 3. stow git
```

### 충돌 처리

기존 파일이 심링크가 아닌 실제 파일이면 `install.sh`가 자동으로 `.backup.<timestamp>` 백업을 생성한다.

---

## Conventions

- **패키지 단위**: 도구 하나당 디렉토리 하나 (`claude/`, `git/`, `zsh/`)
- **머신별 설정**: `.local` 접미사 파일 사용 (`.gitignore`로 제외됨)
- **최소주의**: 기본값과 다른 설정만 포함
