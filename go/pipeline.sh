#!/usr/bin/env bash
# Pipeline for the Go version: go build, go test, go vet, doc2go, go install.
NAME=go
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"
SRC="$ROOT/go"
BUILD="$SRC/bin"
DOCS="$SRC/docs-out"
DOC2GO=go.abhg.dev/doc2go@v0.12.2
LDFLAGS="-X main.version=$VERSION"

stage_build() {
  need go
  cd "$SRC"
  go build -ldflags "$LDFLAGS" -o "$BUILD/shapes-go" ./cmd/shapes-go
}

stage_test() {
  cd "$SRC"
  local unformatted
  unformatted="$(gofmt -l .)"
  [ -z "$unformatted" ] || die "gofmt must format these files: $unformatted"
  go vet ./...
  go test ./...
}

stage_docs() {
  need go
  cd "$SRC"
  rm -rf "$DOCS"
  go run "$DOC2GO" -out "$DOCS" ./...
  [ -f "$DOCS/index.html" ] || die "doc2go did not write $DOCS/index.html"
  publish_docs "$DOCS"
}

stage_package() {
  need go
  cd "$SRC"
  local pkg="shapes-go-$VERSION-$(platform)" stage="$BUILD/pkg"
  rm -rf "$stage"
  mkdir -p "$stage/$pkg"
  CGO_ENABLED=0 go build -trimpath -ldflags "$LDFLAGS -s -w" -o "$stage/$pkg/shapes-go" ./cmd/shapes-go
  cp "$SRC/README.md" "$stage/$pkg/"
  tarball "$stage/$pkg"
}

stage_install() {
  need go
  cd "$SRC"
  rm -rf "${PREFIX:?}/$NAME"
  GOBIN="$PREFIX/$NAME/bin" go install -ldflags "$LDFLAGS" ./cmd/shapes-go
  link_bin "$PREFIX/$NAME/bin/shapes-go"
  smoke_test "$PREFIX/bin/shapes-go"
  installed shapes-go
}

stage_clean() {
  rm -rf "$BUILD" "$DOCS" "${DIST_DIR:?}/$NAME" "${SITE_DIR:?}/$NAME"
}

run_stages "$@"
