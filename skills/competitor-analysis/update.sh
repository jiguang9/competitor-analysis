#!/usr/bin/env bash
# Update the competitor-analysis skill files to the latest version from GitHub.
# Only ever writes files from skills/competitor-analysis/ in the source repo —
# safe to run from inside an installed skill directory (e.g.
# ~/.claude/skills/competitor-analysis/). Works without npx or a git clone,
# only requires curl (or wget).
#
# Usage:
#   bash update.sh                                          # run from inside the installed skill dir
#   bash update.sh /path/to/installed/competitor-analysis   # explicit path

set -e

SKILL_DIR="${1:-$(dirname "$0")}"
OWNER="jiguang9"
REPO="competitor-analysis"
SKILL_SUBDIR="skills/competitor-analysis"
TARBALL="https://github.com/${OWNER}/${REPO}/archive/refs/heads/main.tar.gz"

echo "competitor-analysis update starting..."
echo "  Skill directory: ${SKILL_DIR}"

# ── Option 1: git repo ──────────────────────────────────────────────────────
# Only applies if SKILL_DIR is itself a git checkout of this repo (unusual —
# most installs are plain file copies with no .git).
if [ -d "${SKILL_DIR}/.git" ]; then
  echo "  Method: git pull"
  git -C "${SKILL_DIR}" pull --ff-only
  echo "competitor-analysis updated via git."
  exit 0
fi

# Downloads the repo tarball, then copies only skills/competitor-analysis/
# (never the repo root) into SKILL_DIR.
update_from_tarball() {
  local fetch_cmd="$1"
  local tmp
  tmp=$(mktemp -d)
  eval "${fetch_cmd}" | tar -xz -C "${tmp}" --strip-components=1
  if [ ! -d "${tmp}/${SKILL_SUBDIR}" ]; then
    echo "Error: ${SKILL_SUBDIR} not found in the downloaded archive."
    rm -rf "${tmp}"
    exit 1
  fi
  cp -r "${tmp}/${SKILL_SUBDIR}/." "${SKILL_DIR}/"
  rm -rf "${tmp}"
}

# ── Option 2: curl ───────────────────────────────────────────────────────────
if command -v curl &>/dev/null; then
  echo "  Method: curl (GitHub tarball)"
  update_from_tarball "curl -fsSL '${TARBALL}'"
  echo "competitor-analysis updated via curl."
  exit 0
fi

# ── Option 3: wget ───────────────────────────────────────────────────────────
if command -v wget &>/dev/null; then
  echo "  Method: wget (GitHub tarball)"
  update_from_tarball "wget -qO- '${TARBALL}'"
  echo "competitor-analysis updated via wget."
  exit 0
fi

# ── Fallback ─────────────────────────────────────────────────────────────────
echo "Error: curl, wget, and git are all unavailable."
echo "Update manually by downloading:"
echo "  ${TARBALL}"
echo "and copying the '${SKILL_SUBDIR}/' folder's contents into: ${SKILL_DIR}"
exit 1
