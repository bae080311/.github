# .github

`bae080311` 계정 레포들의 **공통 설정**. 두 종류가 섞여 있다 — GitHub 이 자동으로 물려주는 것과,
스크립트로 밀어넣어야 하는 것.

> 이 레포는 GitHub 요구사항상 **public 이어야** 기본값으로 동작한다.
> 그래서 프로젝트 고유 정보(도메인 체크박스, 내부 URL, 특정 검증 명령)를 넣지 않는다.

## 자동으로 상속되는 것

자체 파일이 없는 모든 레포가 물려받는다. **public·private 둘 다.** 레포에 같은 종류의 파일이
있으면 그쪽이 이긴다.

| 파일 | 무엇 | 자체 파일을 둔 곳 |
| --- | --- | --- |
| `.github/ISSUE_TEMPLATE/bug_report.md` | 버그 | Eobom-fullstack |
| `.github/ISSUE_TEMPLATE/task.md` | 개발 작업 | Eobom-fullstack |
| `.github/ISSUE_TEMPLATE/harness.md` | `.claude` 하네스 표준 정리 | — |
| `.github/ISSUE_TEMPLATE/config.yml` | blank issue 허용 | — |
| `.github/pull_request_template.md` | PR | Eobom-fullstack · jump-section |
| `CONTRIBUTING.md` | 브랜치·커밋·PR·라벨 규칙 | — |
| `SECURITY.md` | 취약점 신고 경로, 토큰·가드 원칙 | — |

GitHub 이 기본값으로 지원하는 나머지(`CODE_OF_CONDUCT.md` `SUPPORT.md` `FUNDING.yml`,
Discussion 카테고리 폼)는 지금 쓸 데가 없어 두지 않았다. 필요해지면 여기 추가하면 전부에 닿는다.

## 상속되지 않는 것 — 스크립트로 민다

| 무엇 | 왜 안 되나 | 어떻게 |
| --- | --- | --- |
| **라벨** | 기본 라벨 설정은 org 전용 기능이고 개인 계정엔 없다 | [`labels.tsv`](labels.tsv) + [`scripts/sync-labels.sh`](scripts/sync-labels.sh) |
| **브랜치 보호** | 레포별 설정이고 API 로만 건다 | [`scripts/sync-branch-protection.sh`](scripts/sync-branch-protection.sh) |
| `LICENSE` | GitHub 이 명시적으로 제외한다 (clone·패키징에 포함되어야 하므로) | 레포마다 직접 |
| `CODEOWNERS` | 상속 안 됨. 1인 프로젝트라 지금은 무의미 | — |
| 워크플로우 | 상속 안 됨. 재사용 워크플로우는 가능하지만 실제 중복이 적어 안 한다 | 레포마다 직접 |

### 라벨

```bash
bash scripts/sync-labels.sh --dry-run --all   # 무엇이 바뀌는지 먼저 본다
bash scripts/sync-labels.sh --all             # repos.txt 전부
bash scripts/sync-labels.sh <repo> ai public  # 한 레포에 스코프 지정
bash scripts/sync-labels.sh --selftest        # 데이터 형식 검사
```

없으면 만들고 있으면 색·설명을 맞춘다. **삭제는 하지 않는다** — 라벨을 지우면 기존 이슈에서
떨어진다.

스코프가 세 가지다:

- `common` — 모든 레포
- `ai` — AI 파이프라인 워크플로우가 있는 레포만. `ai-implement` 는 붙이면 **실제로 구현이 돈다.**
  워크플로우 없는 곳에 두면 붙여도 아무 일이 안 일어나는 거짓 라벨이 된다
- `public` — 외부 기여가 가능한 공개 레포만

레포별 스코프는 [`repos.txt`](repos.txt) 에 있다. 새 레포를 만들면 거기 한 줄 추가한다.

### 브랜치 보호

지금 **어느 레포에도 서버 측 보호가 없다.** `block-protected-push.sh` 훅은 Claude Code 세션
안에서만 돈다 — 사람이 터미널에서 `git push origin main` 하면 그냥 들어간다.

```bash
bash scripts/sync-branch-protection.sh --dry-run --all
bash scripts/sync-branch-protection.sh --all
```

**PR 필수는 켜지 않는다.** jump-section `release.yml` 이 버전 bump 커밋을 `main` 에 직접
push 하기 때문이다. 켜려면 그 워크플로우를 먼저 고쳐야 한다 — 안 그러면 릴리스마다 버전 bump 가
조용히 사라진다.

## 관련

하네스(`CLAUDE.md` · `.claude/`) 표준은 [`claude-config`](https://github.com/bae080311/claude-config)
가 SSOT다 (private). 이 레포는 **사람이 GitHub 에서 보는 것**, 저 레포는 **Claude 가 읽는 것**을
담당한다.
