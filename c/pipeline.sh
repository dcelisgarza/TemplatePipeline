#!/usr/bin/env bash
# Pipeline for the C version: CMake, CTest, Doxygen, CPack.
NAME=c
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"
SRC="$ROOT/c"
BUILD="$SRC/build"

stage_build() {
  need cmake
  cmake -S "$SRC" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release
  cmake --build "$BUILD" --parallel
}

stage_test() {
  ctest --test-dir "$BUILD" --output-on-failure
}

stage_docs() {
  need doxygen
  cmake -S "$SRC" -B "$BUILD" -DSHAPES_BUILD_DOCS=ON
  rm -rf "${BUILD:?}/html"
  cmake --build "$BUILD" --target docs
  publish_docs "$BUILD/html"
}

stage_package() {
  need cpack
  mkdir -p "$DIST_DIR/$NAME"
  (cd "$BUILD" && cpack -D CPACK_PACKAGE_FILE_NAME="shapes-c-$VERSION-$(platform)" \
    -D CPACK_PACKAGE_DIRECTORY="$BUILD/cpack")
  cp "$BUILD"/cpack/*.tar.gz "$DIST_DIR/$NAME/"
  log "wrote $DIST_DIR/$NAME/shapes-c-$VERSION-$(platform).tar.gz"
}

stage_install() {
  cmake --install "$BUILD" --prefix "$PREFIX/c"
  link_bin "$PREFIX/c/bin/shapes-c"
  smoke_test "$PREFIX/bin/shapes-c"
  installed shapes-c
}

stage_clean() {
  rm -rf "$BUILD" "${DIST_DIR:?}/$NAME" "${SITE_DIR:?}/$NAME"
}

run_stages "$@"
