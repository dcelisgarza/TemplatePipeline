#!/usr/bin/env bash
# Pipeline for the Fortran version: fpm, test-drive, FORD, fpm install.
NAME=fortran
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"
SRC="$ROOT/fortran"
BUILD="$SRC/build"
FORD_VERSION=7.0.13

stage_build() {
  need fpm gfortran
  # The version lives in fpm.toml and in src/shapes.f90. Both must match VERSION.
  grep -q "^version = \"$VERSION\"" "$SRC/fpm.toml" || die "version in fpm.toml is not $VERSION"
  grep -q "shapes_version = \"$VERSION\"" "$SRC/src/shapes.f90" ||
    die "version in src/shapes.f90 is not $VERSION"
  (cd "$SRC" && fpm build --profile release)
}

stage_test() {
  (cd "$SRC" && fpm test --profile release)
}

stage_docs() {
  need uvx
  (cd "$SRC" && uvx "ford==$FORD_VERSION" ford.md)
  publish_docs "$BUILD/ford"
}

stage_coverage() {
  local pct
  # fpm keeps a build with other flags in its own directory below build/.
  find "$BUILD" -name '*.gcda' -delete
  (cd "$SRC" && fpm test --profile debug --flag --coverage --link-flag --coverage)
  pct="$(gcovr_report "$SRC" "$BUILD" "$BUILD/coverage" "$SRC/src/")"
  publish_coverage "$BUILD/coverage/coverage.xml" "$BUILD/coverage/html" "$pct"
}

stage_package() {
  need tar
  local stage="$BUILD/package/shapes-fortran-$VERSION-$(platform)"
  rm -rf "$stage"
  mkdir -p "$stage"
  (cd "$SRC" && fpm install --profile release --prefix "$stage")
  tarball "$stage"
}

stage_install() {
  (cd "$SRC" && fpm install --profile release --prefix "$PREFIX/fortran")
  link_bin "$PREFIX/fortran/bin/shapes-fortran"
  smoke_test "$PREFIX/bin/shapes-fortran"
  installed shapes-fortran
}

stage_clean() {
  rm -rf "$BUILD" "${DIST_DIR:?}/$NAME" "${COVERAGE_DIR:?}/$NAME" "${SITE_DIR:?}/$NAME"
}

run_stages "$@"
