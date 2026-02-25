프로젝트의 테스트를 실행한다.

## 절차

1. 프로젝트 루트에서 테스트 러너를 자동 감지:
   - `vitest.config.*` 또는 `vite.config.*`(test 섹션) → `vitest`
   - `jest.config.*` 또는 `package.json`의 `jest` 키 → `jest`
   - `pytest.ini`, `pyproject.toml`(pytest 섹션), `setup.cfg`(tool:pytest) → `pytest`
   - `Cargo.toml` → `cargo test`
   - `go.mod` → `go test ./...`
   - `*.test.*` 또는 `*.spec.*` 파일만 있고 설정 없음 → `npx vitest`
2. 패키지 매니저를 lock 파일로 판단하여 적절한 실행 명령 구성
3. 인자가 있으면 해당 파일/패턴만 테스트, 없으면 전체 테스트 실행
4. 실패한 테스트가 있으면:
   - 실패 원인 분석
   - 코드 버그인지 테스트 버그인지 판단
   - 수정 제안 (바로 수정하지 않고 확인 후 진행)

## 규칙

- 테스트 러너를 찾지 못하면 사용자에게 확인
- watch 모드로 실행하지 않음 (단발 실행)
- 테스트 코드 자체를 수정할 때는 반드시 확인 후 진행

$ARGUMENTS
