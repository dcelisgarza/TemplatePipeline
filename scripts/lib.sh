#!/usr/bin/env bash
# Shared helpers for the per-language pipeline scripts.
#
# A language script sets NAME, sources this file, defines the functions
# stage_build, stage_test, stage_docs, stage_package, stage_install and
# stage_clean, and then calls: run_stages "$@"
#
# Environment variables (all optional):
#   PREFIX    install root (default: ${TMPDIR:-/tmp}/template-pipeline)
#   DIST_DIR  where packages and binaries go (default: <repo>/dist)
#   SITE_DIR  where HTML documentation goes (default: <repo>/site)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"
DIST_DIR="${DIST_DIR:-$ROOT/dist}"
SITE_DIR="${SITE_DIR:-$ROOT/site}"
PREFIX="${PREFIX:-${TMPDIR:-/tmp}/template-pipeline}"
STAGES=(build test docs package install)

log() { printf '\033[1;34m==> [%s] %s\033[0m\n' "${NAME:-?}" "$*" >&2; }
die() { printf '\033[1;31merror: [%s] %s\033[0m\n' "${NAME:-?}" "$*" >&2; exit 1; }

# need TOOL... : stop with a clear message if a tool is not on PATH.
need() {
  local t
  for t in "$@"; do
    command -v "$t" >/dev/null 2>&1 || die "'$t' is not on PATH. Install it to run this stage."
  done
}

# platform: prints <os>-<arch>, for example linux-x86_64 or macos-arm64.
platform() {
  local os arch
  case "$(uname -s)" in
    Linux) os=linux ;;
    Darwin) os=macos ;;
    MINGW* | MSYS* | CYGWIN*) os=windows ;;
    *) os="$(uname -s | tr '[:upper:]' '[:lower:]')" ;;
  esac
  arch="$(uname -m)"
  case "$arch" in aarch64) arch=arm64 ;; amd64) arch=x86_64 ;; esac
  echo "$os-$arch"
}

# tarball DIR NAME : packs DIR into $DIST_DIR/$NAME/<NAME-of-dir>.tar.gz.
tarball() {
  local dir=$1 out="$DIST_DIR/$NAME"
  mkdir -p "$out"
  tar -C "$(dirname "$dir")" -czf "$out/$(basename "$dir").tar.gz" "$(basename "$dir")"
  log "wrote $out/$(basename "$dir").tar.gz"
}

# publish_docs DIR : copies the HTML documentation in DIR to $SITE_DIR/$NAME.
publish_docs() {
  rm -rf "${SITE_DIR:?}/$NAME"
  mkdir -p "$SITE_DIR"
  cp -R "$1" "$SITE_DIR/$NAME"
  log "documentation in $SITE_DIR/$NAME/index.html"
}

# link_bin EXE : puts a link to EXE in $PREFIX/bin.
link_bin() {
  mkdir -p "$PREFIX/bin"
  ln -sf "$1" "$PREFIX/bin/$(basename "$1")"
}

# smoke_test EXE : runs the installed program the same way for every language.
smoke_test() {
  local exe=$1 out
  log "smoke test of $exe"
  out="$("$exe" circle 2)" || die "'$exe circle 2' failed"
  [[ "$out" == "circle: area = 12.566371, perimeter = 12.566371" ]] ||
    die "unexpected output of '$exe circle 2': $out"
  out="$(printf 'square\n3\nq\n' | "$exe")" || die "interactive mode of $exe failed"
  [[ "$out" == *"square: area = 9.000000, perimeter = 12.000000"* ]] ||
    die "unexpected output of the interactive mode: $out"
  if "$exe" triangle 1 1 5 >/dev/null 2>&1; then
    die "'$exe triangle 1 1 5' did not fail"
  fi
  out="$("$exe" --version)"
  [[ "$out" == *"$VERSION"* ]] || die "'$exe --version' does not show $VERSION: $out"
  log "smoke test passed"
}

# installed EXE : tells the user how to run the installed program.
installed() {
  log "installed $PREFIX/bin/$1"
  log "run it with:  $PREFIX/bin/$1    or:  export PATH=\"$PREFIX/bin:\$PATH\""
}

# run_stages [STAGE...] : runs the stages in the given order.
# The stages test, docs, package and install run the build first when the
# build did not run yet. Builds are incremental, so this is fast.
# The install stage installs the packages, so it runs the package stage
# first when that stage did not run yet.
run_stages() {
  local args=("$@") s done_list=" "
  [ ${#args[@]} -eq 0 ] && args=(all)
  [ "${args[*]}" = all ] && args=("${STAGES[@]}")
  for s in "${args[@]}"; do
    case "$s" in
      build | clean) ;;
      test | docs | package) _run_once build ;;
      install) _run_once build && _run_once package ;;
      *) die "unknown stage '$s'. Use: build test docs package install clean all" ;;
    esac
    _run_once "$s"
  done
  return 0
}

# _run_once STAGE : runs STAGE if it did not run yet in this call of run_stages.
_run_once() {
  case "$done_list" in *" $1 "*) return 0 ;; esac
  log "$1"
  "stage_$1"
  done_list+="$1 "
}
