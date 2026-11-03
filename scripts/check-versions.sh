#!/usr/bin/env bash
# Check that each language manifest has the version in the VERSION file.
# C, C++ and the Python docs read the version at build time, so they are not in this list.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"

# file : pattern that must match a line of the file
checks=(
  "python/pyproject.toml:^version = \"$VERSION\""
  "rust/Cargo.toml:^version = \"$VERSION\""
  "julia/Project.toml:^version = \"$VERSION\""
  "fortran/fpm.toml:^version = \"$VERSION\""
  "typescript/package.json:\"version\": \"$VERSION\""
  "csharp/Directory.Build.props:<Version>$VERSION</Version>"
)

status=0
for check in "${checks[@]}"; do
  file="${check%%:*}"
  pattern="${check#*:}"
  [ -f "$ROOT/$file" ] || continue
  if ! grep -Eq "$pattern" "$ROOT/$file"; then
    echo "error: $file does not have version $VERSION" >&2
    status=1
  fi
done
[ $status -eq 0 ] && echo "all manifests have version $VERSION"
exit $status
