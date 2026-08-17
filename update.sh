#!/usr/bin/env bash
# Update competitor-analysis to the latest version from GitHub.
# Works without npx or a git clone — only requires curl (or wget).
#
# Usage:
#   bash update.sh                                       # run from inside skill dir
#   bash update.sh /path/to/skill/competitor-analysis    # explicit path

set -e

SKILL_DIR="${1:-$(dirname "$0")}"
OWNER="jiguang9"
REPO="competitor-analysis"
TARBALL="https://github.com/${OWNER}/${REPO}/archive/refs/heads/main.tar.gz"

echo "competitor-analysis update starting..."
echo "  Skill directory: ${SKILL_DIR}"

# ── Option 1: git repo ────────────────────────────────────────────────────────
if [ -d "${SKILL_DIR}/.git" ]; then
  echo "  Method: git pull"
  git -C "${SKILL_DIR}" pull --ff-only
  echo "competitor-analysis updated via git."
  exit 0
fi

# ── Option 2: curl ────────────────────────────────────────────────────────────
if command -v curl &>/dev/null; then
  echo "  Method: curl (GitHub tarball)"
  TMP=$(mktemp -d)
  curl -fsSL "${TARBALL}" | tar -xz -C "${TMP}" --strip-components=1
  cp -r "${TMP}/." "${SKILL_DIR}/"
  rm -rf "${TMP}"
  echo "competitor-analysis updated via curl."
  exit 0
fi

# ── Option 3: wget ────────────────────────────────────────────────────────────
if command -v wget &>/dev/null; then
  echo "  Method: wget (GitHub tarball)"
  TMP=$(mktemp -d)
  wget -qO- "${TARBALL}" | tar -xz -C "${TMP}" --strip-components=1
  cp -r "${TMP}/." "${SKILL_DIR}/"
  rm -rf "${TMP}"
  echo "competitor-analysis updated via wget."
  exit 0
fi

# ── Fallback ─────────────────────────────────────────────────────────────────
echo "Error: curl, wget, and git are all unavailable."
echo "Update manually by downloading:"
echo "  ${TARBALL}"
echo "and extracting into: ${SKILL_DIR}"
exit 1
