#!/usr/bin/env bash
# scripts/sync-agents-md.sh — keep AGENTS.md and CLAUDE.md byte-identical.
#
#   scripts/sync-agents-md.sh [--check]
#
# The two files must have the same content: AGENTS.md is what agent tooling
# reads, CLAUDE.md is what Claude Code reads, and they document the same
# project. AGENTS.md was historically a symlink, but git records symlinks as
# mode 120000 and a Windows checkout without symlink privilege cannot
# materialize one — it lands as a 9-byte text file holding the target path,
# which no tool can read. Two real files plus this script is the only form
# that works on every platform.
#
# Doctrine — bidirectional, newest-wins:
#   Either file may be edited. This script copies the one with the newer
#   mtime over the other. Identical files are a no-op.
#
# The mtime caveat, and why the both-dirty guard exists:
#   git rewrites mtimes on checkout, stash, and rebase without regard to
#   content age. After such an operation "newer" can name the STALE file,
#   and a blind copy would then destroy the fresh one. The tell is both
#   files differing from the index at once — real editing produces one
#   dirty file, not two. On that signature this script refuses to guess and
#   makes you resolve it by hand. That is the whole safety margin of
#   newest-wins; do not remove the guard to make the script quieter.
#
# --check reports drift without writing (used by the pre-push hook).
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SRC="CLAUDE.md"
DST="AGENTS.md"
CHECK_ONLY=false
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

for f in "${SRC}" "${DST}"; do
    if [[ ! -f "${f}" ]]; then
        printf "${RED}[ERROR]${NC} %s is missing or not a regular file.\n" "${f}"
        [[ -L "${f}" ]] && echo "  It is a symlink — replace it with a real file (see header)."
        exit 1
    fi
done

# --ignore-space-at-eol: a checkout that normalizes line endings must not
# read as content drift. Same reasoning as the plugin/ check in pre-push.
if git diff --no-index --ignore-space-at-eol --quiet "${SRC}" "${DST}"; then
    printf "${GREEN}[OK]${NC} %s matches %s\n" "${DST}" "${SRC}"
    exit 0
fi

if [[ "${CHECK_ONLY}" == true ]]; then
    printf "${RED}[BLOCKED]${NC} %s and %s have drifted.\n" "${SRC}" "${DST}"
    git --no-pager diff --no-index --ignore-space-at-eol --stat "${SRC}" "${DST}" || true
    echo
    echo "Run: bash scripts/sync-agents-md.sh   (copies whichever is newer over the other)"
    exit 1
fi

# Both dirty at once — the mtime-scramble signature described in the header.
src_dirty=false; dst_dirty=false
git diff --quiet -- "${SRC}" 2>/dev/null || src_dirty=true
git diff --quiet -- "${DST}" 2>/dev/null || dst_dirty=true
if [[ "${src_dirty}" == true && "${dst_dirty}" == true ]]; then
    printf "${RED}[BLOCKED]${NC} Both %s and %s differ from the index.\n" "${SRC}" "${DST}"
    echo "  mtimes are not trustworthy here (a checkout/stash/rebase can reorder them),"
    echo "  so newest-wins could overwrite the file you actually edited."
    echo
    echo "  Resolve by hand, then re-run:"
    echo "    git diff -- ${SRC} ${DST}          # see what changed on each side"
    echo "    cp ${SRC} ${DST}                   # keep ${SRC}"
    echo "    cp ${DST} ${SRC}                   # keep ${DST}"
    exit 1
fi

if [[ "${SRC}" -nt "${DST}" ]]; then
    newer="${SRC}"; older="${DST}"
else
    newer="${DST}"; older="${SRC}"
fi

cp "${newer}" "${older}"
printf "${GREEN}[OK]${NC} %s was newer — copied over %s\n" "${newer}" "${older}"
printf "${YELLOW}[NOTE]${NC} %s now matches %s. Stage both if committing.\n" "${older}" "${newer}"
