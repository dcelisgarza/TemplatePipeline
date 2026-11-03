#!/usr/bin/env bash
# Pipeline for the Python version: uv, pytest, ruff, Sphinx.
NAME=python
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"
SRC="$ROOT/python"
cd "$SRC"

stage_build() {
  need uv
  uv sync --locked
}

stage_test() {
  uv run --locked ruff check
  uv run --locked ruff format --check
  uv run --locked pytest --doctest-modules src tests
}

stage_docs() {
  uv run --locked --group docs sphinx-build -W -b html docs docs/_build/html
  publish_docs docs/_build/html
}

stage_coverage() {
  rm -rf "$COVERAGE_WORK"
  COVERAGE_FILE="$COVERAGE_WORK/.coverage" uv run --locked pytest --cov=shapes \
    --cov-report=term --cov-report="xml:$COVERAGE_WORK/coverage.xml" \
    --cov-report="html:$COVERAGE_WORK/html" tests
  publish_coverage "$COVERAGE_WORK/coverage.xml" "$COVERAGE_WORK/html" \
    "$(COVERAGE_FILE="$COVERAGE_WORK/.coverage" uv run --locked coverage report --format=total --precision=1)"
}

stage_package() {
  uv build --out-dir "$DIST_DIR/$NAME"
}

stage_install() {
  # A uv tool gets its own virtual environment. Both live below $PREFIX.
  UV_TOOL_DIR="$PREFIX/python/tools" UV_TOOL_BIN_DIR="$PREFIX/python/bin" \
    uv tool install --force "$DIST_DIR/$NAME/shapes_python-$VERSION-py3-none-any.whl"
  link_bin "$PREFIX/python/bin/shapes-python"
  smoke_test "$PREFIX/bin/shapes-python"
  installed shapes-python
}

stage_clean() {
  rm -rf .venv docs/_build "${DIST_DIR:?}/$NAME" "${COVERAGE_DIR:?}/$NAME" "${SITE_DIR:?}/$NAME"
}

run_stages "$@"
