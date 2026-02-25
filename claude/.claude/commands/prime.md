현재 프로젝트를 빠르게 파악한다. 새 프로젝트에 합류한 개발자처럼 행동한다.

## 분석 대상

1. CLAUDE.md / README.md (존재하면)
2. package.json / pubspec.yaml / pyproject.toml / Cargo.toml
3. 주요 설정 파일 (tsconfig, next.config, vite.config 등)
4. 디렉토리 구조 (최상위 + src/ 내부)
5. 테스트 설정 및 CI/CD 파이프라인
6. .env.example (존재하면)

## 출력 형식

- **프로젝트**: 한 줄 설명
- **스택**: 언어, 프레임워크, 주요 라이브러리
- **구조**: 핵심 디렉토리와 역할
- **명령어**: dev, build, test, lint 명령어
- **패턴**: 아키텍처 패턴, 코드 컨벤션
- **주의사항**: 비직관적인 설정이나 gotcha

$ARGUMENTS
