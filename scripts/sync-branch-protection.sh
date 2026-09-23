#!/usr/bin/env bash
# main 브랜치에 최소 보호를 건다: 강제 푸시 금지 + 삭제 금지.
#
# **PR 필수는 켜지 않는다.** jump-section release.yml 이 버전 bump 커밋을 main 에 직접
# push 하기 때문이다(그 워크플로우 주석에도 적혀 있다). PR 필수를 켜려면 그 워크플로우를
# 먼저 고쳐야 한다 — 안 그러면 릴리스마다 버전 bump 가 조용히 사라진다.
#
# 왜 필요한가: 지금 보호가 서버에 하나도 없다. block-protected-push.sh 훅은 Claude Code
# 세션 안에서만 돈다. 사람이 터미널에서 git push origin main 하면 그냥 들어간다.
# CLAUDE.md 가 "어떤 주체도 직접 push 할 수 없다"고 선언한 것과 실제가 다르다.
#
#   bash scripts/sync-branch-protection.sh --dry-run --all
#   bash scripts/sync-branch-protection.sh <repo>...
#   bash scripts/sync-branch-protection.sh --all
set -uo pipefail
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
parse() { grep -v '^[[:space:]]*#' "$1" | grep -v '^[[:space:]]*$'; }

protect() {
  local repo=$1 dry=$2
  local branch; branch=$(gh api "repos/$repo" --jq .default_branch 2>/dev/null) || {
    printf '  FAIL %-24s (레포 조회 실패)\n' "$repo"; return 1; }
  [[ -n "$branch" ]] || { printf '  skip %-24s (빈 레포)\n' "$repo"; return 0; }

  local now; now=$(gh api "repos/$repo/branches/$branch/protection" 2>&1)
  local had="없음"; echo "$now" | grep -q 'Branch not protected' || had="있음"

  if [[ "$dry" == "1" ]]; then
    printf '  [dry] %-24s %s → force-push·삭제 차단 (현재 보호: %s)\n' "$repo" "$branch" "$had"
    return 0
  fi

  gh api -X PUT "repos/$repo/branches/$branch/protection" \
    -H "Accept: application/vnd.github+json" \
    --input - >/dev/null 2>&1 <<JSON
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
  # shellcheck disable=SC2181
  if [[ $? -eq 0 ]]; then printf '  ok   %-24s %s 보호 적용 (이전: %s)\n' "$repo" "$branch" "$had"
  else printf '  FAIL %-24s %s\n' "$repo" "$branch"; return 1; fi
}

DRY=0; [[ "${1:-}" == "--dry-run" ]] && { DRY=1; shift; }
# mapfile 은 bash 4+ 다. macOS 기본 bash 는 3.2 라 while-read 로 읽는다.
REPOS=()
if [[ "${1:-}" == "--all" ]]; then
  while IFS= read -r line; do REPOS+=("$line"); done < <(parse "$HERE/repos.txt" | cut -f1)
else
  REPOS=("$@")
fi
[[ ${#REPOS[@]} -gt 0 ]] || { echo "사용법: sync-branch-protection.sh [--dry-run] <repo>... | --all" >&2; exit 1; }

FAIL=0
for r in "${REPOS[@]}"; do
  [[ "$r" == */* ]] || r="bae080311/$r"
  protect "$r" "$DRY" || FAIL=1
done
[[ "$DRY" == "1" ]] && echo && echo "적용하려면 --dry-run 을 빼고 다시 실행한다."
exit $FAIL
