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
  rm -rf "$BUILD" "$DOCS" "$SRC/node_modules" "${DIST_DIR:?}/$NAME" "${SITE_DIR:?}/$NAME"
}

run_stages "$@"
