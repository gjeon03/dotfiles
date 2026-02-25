이슈를 분석하고 수정한다.

## 플랫폼 감지

`git remote get-url origin`으로 호스트를 확인하여 CLI를 선택한다:
- `github.com` → `gh` CLI
- `gitlab` → `glab` CLI

## 절차

1. 플랫폼 감지 (위 규칙)
2. 이슈 내용 확인:
   - GitHub: `gh issue view $ARGUMENTS`
   - GitLab: `glab issue view $ARGUMENTS`
3. 이슈의 댓글과 라벨도 확인
4. 관련 코드 탐색 및 근본 원인 분석
5. 수정 구현
6. 관련 테스트 작성 또는 수정
7. 변경 사항 요약 후 커밋: `fix: <description> (closes #$ARGUMENTS)`

## 규칙

- 수정 범위를 이슈에 명시된 내용으로 제한
- 관련 없는 리팩토링이나 개선은 하지 않음
- 테스트로 수정이 올바른지 검증

$ARGUMENTS
