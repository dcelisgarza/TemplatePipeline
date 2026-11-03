#!/usr/bin/env bash
# Pipeline for the Rust version: Cargo, rustfmt, Clippy, rustdoc.
NAME=rust
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"
SRC="$ROOT/rust"
export CARGO_TARGET_DIR="$SRC/target"

stage_build() {
  need cargo
  (cd "$SRC" && cargo build --release --locked)
}

stage_test() {
  cd "$SRC"
  cargo test --locked
  if cargo fmt --version >/dev/null 2>&1; then
    cargo fmt --check
  else
    log "rustfmt is not installed: skipping cargo fmt --check"
  fi
  if cargo clippy --version >/dev/null 2>&1; then
    cargo clippy --locked --all-targets -- -D warnings
  else
    log "clippy is not installed: skipping cargo clippy"
  fi
}

stage_docs() {
  cd "$SRC"
  cargo doc --no-deps --locked
  rm -rf "$SRC/target/site"
  cp -R "$SRC/target/doc" "$SRC/target/site"
  cat >"$SRC/target/site/index.html" <<'HTML'
<!doctype html>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=shapes/index.html">
<title>shapes (Rust)</title>
<a href="shapes/index.html">shapes API documentation</a>
HTML
  publish_docs "$SRC/target/site"
}

stage_coverage() {
  need cargo-llvm-cov
  cd "$SRC"
  rm -rf "$COVERAGE_WORK"
  mkdir -p "$COVERAGE_WORK"
  cargo llvm-cov clean --workspace
  cargo llvm-cov --locked --no-report
  cargo llvm-cov report --lcov --output-path "$COVERAGE_WORK/lcov.info"
  cargo llvm-cov report --html --output-dir "$COVERAGE_WORK"
  publish_coverage "$COVERAGE_WORK/lcov.info" "$COVERAGE_WORK/html" \
    "$(cargo llvm-cov report --json --summary-only |
      python3 -c 'import json, sys; print(json.load(sys.stdin)["data"][0]["totals"]["lines"]["percent"])')"
}

stage_package() {
  local out="$DIST_DIR/$NAME" stage plat
  plat="$(platform)"
  mkdir -p "$out"
  stage="$SRC/target/package-stage/shapes-rust-$VERSION-$plat"
  rm -rf "$SRC/target/package-stage"
  mkdir -p "$stage"
  cp "$SRC/target/release/shapes-rust" "$SRC/README.md" "$stage/"
  tar -C "$SRC/target/package-stage" -czf "$out/shapes-rust-$VERSION-$plat.tar.gz" \
    "shapes-rust-$VERSION-$plat"
  log "wrote $out/shapes-rust-$VERSION-$plat.tar.gz"
  (cd "$SRC" && cargo package --locked --allow-dirty --no-verify)
  cp "$SRC/target/package/shapes-$VERSION.crate" "$out/"
  log "wrote $out/shapes-$VERSION.crate"
}

stage_install() {
  (cd "$SRC" && cargo install --path . --root "$PREFIX/rust" --locked --force)
  link_bin "$PREFIX/rust/bin/shapes-rust"
  smoke_test "$PREFIX/bin/shapes-rust"
  installed shapes-rust
}

stage_clean() {
  rm -rf "$SRC/target" "${DIST_DIR:?}/$NAME" "${COVERAGE_DIR:?}/$NAME" "${SITE_DIR:?}/$NAME"
}

run_stages "$@"
