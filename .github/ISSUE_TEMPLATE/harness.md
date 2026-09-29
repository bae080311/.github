---
name: .claude 하네스 표준 정리
about: .claude/ 레이아웃을 6계층 표준에 맞춘다
title: 'chore(harness): .claude 하네스 표준 정리'
labels: documentation
---

표준은 [claude-config `shared/conventions/architecture.md`](https://github.com/bae080311/claude-config/blob/main/shared/conventions/architecture.md) 가 SSOT다.

## 🧱 6계층

| 계층 | 위치 | 역할 |
| --- | --- | --- |
| Rule (지도) | `CLAUDE.md` | 프로젝트 요약 + 어떤 작업에 어떤 rule 을 읽을지 라우팅 |
| Rule (본문) | `.claude/rules/*.md` | 작업 종류별 실제 규칙 |
| Skill | `.claude/skills/<name>/SKILL.md` | 재사용 가능한 절차 |
| Agent | `.claude/agents/<name>.md` | 도구 권한을 좁혀 격리 실행 |
| Hook | `.claude/hooks/*.sh` + `settings.json` | 도구 사용 전후 자동 검증 |
| Flywheel | `.claude/flywheel/learnings.md` | 피드백을 규칙으로 되먹임 |

## ⚠️ 편차

<!-- 표준과 어긋난 것을 여기에 나열한다 -->

- [ ]

## ✅ 공통 체크리스트

- [ ] `.claude/commands/` 없음 — 절차는 Skill, 격리 실행은 Agent
- [ ] 훅 스크립트가 `hooks/` 에 있음 (`scripts/` 아님)
- [ ] 6계층 밖 디렉터리 없음 — 계획 문서는 `docs/`, 디자인 토큰은 `rules/`
- [ ] `CLAUDE.md` 가 150줄 넘으면 본문이 `rules/` 로 빠져 있음
- [ ] `.claude/flywheel/learnings.md` 존재
- [ ] 테스트 규칙이 `rules/testing.md` 또는 `CLAUDE.md` 에 있음 (에이전트 파일 안에 묻혀 있지 않음)
- [ ] `claude-config` 서브모듈 편입 + 심링크 연결
- [ ] `shared/conventions/` 와 겹치는 규칙 문장을 참조로 대체 (규칙을 두 벌 두지 않는다)
- [ ] `bash .claude-config/shared/scripts/check-layout.sh` 통과
