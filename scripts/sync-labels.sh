#!/usr/bin/env bash
# labels.tsv 를 레포에 밀어넣는다. 없으면 만들고, 있으면 색·설명을 맞춘다.
# 삭제는 하지 않는다 — 라벨을 지우면 기존 이슈에서 떨어진다.
#
#   bash scripts/sync-labels.sh <repo> [스코프...]   common + 지정한 스코프
#   bash scripts/sync-labels.sh --all                repos.txt 의 전부 (스코프는 거기 적힌 대로)
#   bash scripts/sync-labels.sh --dry-run <repo> ...
#   bash scripts/sync-labels.sh --selftest
set -uo pipefail
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# 주석·빈 줄 제거
parse() { grep -v '^[[:space:]]*#' "$1" | grep -v '^[[:space:]]*$'; }

# want <스코프> <허용목록...> — common 은 항상 통과
want() {
  local s=$1; shift
  [[ "$s" == "common" ]] && return 0
  local a; for a in "$@"; do [[ "$a" == "$s" ]] && return 0; done
  return 1
}

sync_repo() {
  local repo=$1 dry=$2; shift 2
  local scopes=("$@") made=0 upd=0 skip=0
  while IFS=$'\t' read -r name color scope desc; do
    [[ -n "$name" ]] || continue
    if ! want "$scope" "${scopes[@]+"${scopes[@]}"}"; then skip=$((skip+1)); continue; fi
    if [[ "$dry" == "1" ]]; then printf '  [dry] %-18s #%s  (%s) %s\n' "$name" "$color" "$scope" "$desc"; continue; fi
    if gh label create "$name" -R "$repo" -c "$color" -d "$desc" >/dev/null 2>&1; then
      printf '  +    %-18s %s\n' "$name" "$desc"; made=$((made+1))
    elif gh label edit "$name" -R "$repo" -c "$color" -d "$desc" >/dev/null 2>&1; then
      upd=$((upd+1))
    else
      printf '  FAIL %-18s (생성·수정 둘 다 실패)\n' "$name"; return 1
    fi
  done < <(parse "$HERE/labels.tsv")
  [[ "$dry" == "1" ]] || printf '  생성 %d · 갱신 %d · 스코프 밖 %d\n' "$made" "$upd" "$skip"
}

selftest() {
  local rc=0 t; t=$(mktemp)
  printf '# 주석\n\n이름\tcolor\tcommon\t설명\n' > "$t"
  [[ "$(parse "$t" | wc -l | tr -d ' ')" == "1" ]] \
    && echo "  ok   주석·빈 줄 제거" || { echo "  FAIL 주석·빈 줄 제거"; rc=1; }

  # 탭이 스페이스로 바뀌면 조용히 망가진다 — 전 행이 4열인지
  local bad; bad=$(parse "$HERE/labels.tsv" | awk -F'\t' 'NF!=4{print NR": "$0}')
  [[ -z "$bad" ]] && echo "  ok   labels.tsv 전 행이 4열" || { echo "  FAIL 4열 아님:"; echo "$bad"; rc=1; }

  bad=$(parse "$HERE/labels.tsv" | awk -F'\t' '$2 !~ /^[0-9a-fA-F]{6}$/{print $1" → "$2}')
  [[ -z "$bad" ]] && echo "  ok   색이 전부 6자리 hex" || { echo "  FAIL 색 형식:"; echo "$bad"; rc=1; }

  bad=$(parse "$HERE/labels.tsv" | awk -F'\t' '$3 !~ /^(common|ai|public)$/{print $1" → "$3}')
  [[ -z "$bad" ]] && echo "  ok   스코프가 common|ai|public" || { echo "  FAIL 스코프:"; echo "$bad"; rc=1; }

  # repos.txt 가 가리키는 스코프가 labels.tsv 에 실재하는지 (오타 방지)
  local known; known=$(parse "$HERE/labels.tsv" | cut -f3 | sort -u)
  bad=$(parse "$HERE/repos.txt" | cut -s -f2 | tr ' ' '\n' | grep -v '^$' | sort -u \
        | grep -vxF "$known" || true)
  [[ -z "$bad" ]] && echo "  ok   repos.txt 스코프가 전부 실재" || { echo "  FAIL 없는 스코프:"; echo "$bad"; rc=1; }

  # want() 자체
  want common            && echo "  ok   common 은 스코프 없이 통과"      || { echo "  FAIL common"; rc=1; }
  want ai ai public      && echo "  ok   ai 는 허용목록에 있으면 통과"    || { echo "  FAIL ai 허용"; rc=1; }
  want ai public         && { echo "  FAIL ai 가 허용목록에 없는데 통과"; rc=1; } || echo "  ok   ai 는 허용목록에 없으면 제외"
  want public            && { echo "  FAIL public 이 인자 없이 통과";    rc=1; } || echo "  ok   public 은 인자 없으면 제외"

  rm -f "$t"
  (( rc == 0 )) && echo "전체 통과" || echo "실패한 케이스가 있습니다"
  return $rc
}

[[ "${1:-}" == "--selftest" ]] && { selftest; exit $?; }

DRY=0; [[ "${1:-}" == "--dry-run" ]] && { DRY=1; shift; }
FAIL=0

if [[ "${1:-}" == "--all" ]]; then
  while IFS=$'\t' read -r repo scopes; do
    [[ -n "$repo" ]] || continue
    echo "=== bae080311/$repo ${scopes:+[+$scopes]}"
    # shellcheck disable=SC2086
    sync_repo "bae080311/$repo" "$DRY" ${scopes:-} || FAIL=1
  done < <(parse "$HERE/repos.txt")
else
  repo=${1:-}; [[ -n "$repo" ]] || { echo "사용법: sync-labels.sh [--dry-run] <repo> [스코프...] | --all | --selftest" >&2; exit 1; }
  shift
  [[ "$repo" == */* ]] || repo="bae080311/$repo"
  echo "=== $repo"
  sync_repo "$repo" "$DRY" "$@" || FAIL=1
fi
exit $FAIL
