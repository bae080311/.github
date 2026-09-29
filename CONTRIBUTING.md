# 기여 가이드

`bae080311` 레포 공통. 레포에 자체 `CONTRIBUTING.md` 가 있으면 그쪽이 우선한다.

## 브랜치

`main` 에 직접 push 하지 않는다. `main` `master` `develop` `release/**` 는 보호 브랜치다.

| 패턴 | 용도 |
| --- | --- |
| `feat/기능명` | 새 기능 |
| `fix/버그명` | 버그 수정 |
| `chore/작업명` | 빌드·설정·의존성 |
| `docs/주제` | 문서 |
| `ai/issue-{번호}-{설명}` | AI 자동 생성 |

## 커밋

`<type>: <한국어 설명>` — `feat` `fix` `docs` `refactor` `test` `chore`

- 한 커밋에 한 가지 관심사만. 각 커밋은 그 자체로 빌드·테스트가 통과해야 한다
- 로직을 바꿨으면 **같은 커밋에** 테스트가 들어간다
- `.env`·시크릿을 커밋하지 않는다
- 강제 푸시(`--force` `-f` `+refspec` `--mirror` `--all`)를 쓰지 않는다

## PR

- 제목은 커밋과 같은 형식, 70자 이내
- 한 PR 에 한 가지 관심사만
- 검증(빌드·타입체크·린트·테스트)이 통과한 상태로 올린다
- 이슈에 없는 설계 결정은 임의로 판단하지 말고 **PR 본문에 질문으로** 남긴다

AI 가 만든 PR 은 제목에 `[AI]`, `draft: true`, 본문 하단에 생성 표시를 단다.

## 라벨

| 라벨 | 언제 |
| --- | --- |
| `bug` `feature` `enhancement` `refactor` `test` `documentation` | 이슈의 종류 — 하나만 |
| `chore` | 제품 동작이 안 바뀌는 작업 |
| `setup` `api` `publishing` | 작업 영역 — 종류와 함께 붙인다 (예: `feature` + `api`) |
| `harness` | `.claude` 하네스·자동화 |
| `ai-proposal` `ai-implement` `gemini` | **붙이면 워크플로우가 돈다.** 해당 자동화가 있는 레포에만 존재 |

라벨 SSOT 는 이 레포의 [`labels.tsv`](labels.tsv) 다. 새 레포에 밀어넣으려면
`bash scripts/sync-labels.sh <repo> [스코프...]`.

## Claude Code 로 작업한다면

이 레포들은 `CLAUDE.md` 와 `.claude/` 하네스를 쓴다. 규칙 전문은
[`bae080311/claude-config`](https://github.com/bae080311/claude-config) 에 있다 (private).
clone 할 때 `--recurse-submodules` 를 빼면 `.claude` 가 깨진 심링크로 남는다.
