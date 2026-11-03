#!/usr/bin/env bash
# Pipeline for the TypeScript version: npm, tsc, node:test, TypeDoc, npm pack.
NAME=typescript
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"
SRC="$ROOT/typescript"
BUILD="$SRC/dist"
DOCS="$SRC/docs-out"

stage_build() {
  need node npm
  cd "$SRC"
  if [ -f package-lock.json ]; then npm ci; else npm install; fi
  npm run build
}

stage_test() {
  cd "$SRC"
  npm test
}

stage_docs() {
  cd "$SRC"
  rm -rf "$DOCS"
  npm run docs
  publish_docs "$DOCS"
}

stage_coverage() {
  cd "$SRC"
  rm -rf "$COVERAGE_WORK"
  # The tests import the compiled dist/ files. c8 uses the source maps to report on src/.
  npx c8 --all --src src --include 'src/**' --exclude-after-remap \
    --reporter=text --reporter=lcov --reporter=html --reporter=json-summary \
    --report-dir "$COVERAGE_WORK" --temp-directory "$COVERAGE_WORK/tmp" npm test
  publish_coverage "$COVERAGE_WORK/lcov.info" "$COVERAGE_WORK" \
    "$(node -p "require('$COVERAGE_WORK/coverage-summary.json').total.lines.pct")"
}

stage_package() {
  cd "$SRC"
  mkdir -p "$DIST_DIR/$NAME"
  npm pack --pack-destination "$DIST_DIR/$NAME"
  log "wrote $DIST_DIR/$NAME/shapes-typescript-$VERSION.tgz"
}

stage_install() {
  need node npm
  rm -rf "${PREFIX:?}/$NAME"
  npm install --global --prefix "$PREFIX/$NAME" "$DIST_DIR/$NAME/shapes-typescript-$VERSION.tgz"
  link_bin "$PREFIX/$NAME/bin/shapes-typescript"
  smoke_test "$PREFIX/bin/shapes-typescript"
  installed shapes-typescript
}

stage_clean() {
  rm -rf "$BUILD" "$DOCS" "$SRC/node_modules" "${DIST_DIR:?}/$NAME" "${COVERAGE_DIR:?}/$NAME" "${SITE_DIR:?}/$NAME"
}

run_stages "$@"
