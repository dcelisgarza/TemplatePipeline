#!/usr/bin/env bash
# Pipeline for the C# version: .NET 8 SDK, xUnit, docfx, dotnet pack and publish.
NAME=csharp
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"
SRC="$ROOT/csharp"
SLN="$SRC/Shapes.sln"
CLI="$SRC/src/Shapes.Cli/Shapes.Cli.csproj"
LIB="$SRC/src/Shapes/Shapes.csproj"
DOCS="$SRC/docs/_site"
PUBLISH="$SRC/publish"

# rid: the .NET runtime identifier of this machine.
rid() {
  case "$(uname -s)-$(uname -m)" in
    Linux-x86_64) echo linux-x64 ;;
    Linux-aarch64 | Linux-arm64) echo linux-arm64 ;;
    Darwin-arm64) echo osx-arm64 ;;
    Darwin-x86_64) echo osx-x64 ;;
    *) die "no .NET runtime identifier for $(uname -s)-$(uname -m)" ;;
  esac
}

stage_build() {
  need dotnet
  dotnet build "$SLN" -c Release
}

stage_test() {
  dotnet format "$SLN" --verify-no-changes
  dotnet test "$SLN" -c Release --no-build
}

stage_docs() {
  need dotnet
  cd "$SRC"
  rm -rf "${DOCS:?}" "${SRC:?}/docs/api"
  dotnet tool restore
  dotnet docfx docs/docfx.json
  [ -f "$DOCS/index.html" ] || die "docfx did not write $DOCS/index.html"
  publish_docs "$DOCS"
}

stage_coverage() {
  need dotnet
  cd "$SRC"
  rm -rf "$COVERAGE_WORK"
  dotnet tool restore
  # coverlet writes one Cobertura file per test project. ReportGenerator merges them.
  dotnet test "$SLN" -c Release --no-build --collect:"XPlat Code Coverage" \
    --results-directory "$COVERAGE_WORK/raw"
  dotnet reportgenerator -reports:"$COVERAGE_WORK/raw/*/coverage.cobertura.xml" \
    -targetdir:"$COVERAGE_WORK/html" -reporttypes:"Html;Cobertura;TextSummary"
  publish_coverage "$COVERAGE_WORK/html/Cobertura.xml" "$COVERAGE_WORK/html" \
    "$(sed -n 's/^ *Line coverage: *\([0-9.]*\)%.*/\1/p' "$COVERAGE_WORK/html/Summary.txt")"
}

stage_package() {
  need dotnet
  local out="$DIST_DIR/$NAME" pkg
  mkdir -p "$out"
  rm -f "${out:?}"/*.nupkg
  dotnet pack "$LIB" -c Release --no-build -o "$out"
  dotnet pack "$CLI" -c Release --no-build -o "$out"

  # A self-contained single-file binary for this machine.
  pkg="shapes-csharp-$VERSION-$(platform)"
  rm -rf "${PUBLISH:?}"
  mkdir -p "$PUBLISH/$pkg"
  dotnet publish "$CLI" -c Release -r "$(rid)" --self-contained \
    -p:PublishSingleFile=true -p:PackAsTool=false -p:DebugType=none \
    -o "$PUBLISH/$pkg"
  cp "$SRC/README.md" "$PUBLISH/$pkg/"
  tarball "$PUBLISH/$pkg"
}

stage_install() {
  need dotnet
  rm -rf "${PREFIX:?}/$NAME"
  dotnet tool install --tool-path "$PREFIX/$NAME/bin" \
    --add-source "$DIST_DIR/$NAME" --ignore-failed-sources \
    shapes-csharp --version "$VERSION"
  link_bin "$PREFIX/$NAME/bin/shapes-csharp"
  smoke_test "$PREFIX/bin/shapes-csharp"
  installed shapes-csharp
}

stage_clean() {
  rm -rf "${PUBLISH:?}" "${DOCS:?}" "${SRC:?}/docs/api" "${DIST_DIR:?}/$NAME" "${COVERAGE_DIR:?}/$NAME" "${SITE_DIR:?}/$NAME"
  find "$SRC/src" "$SRC/tests" -type d \( -name bin -o -name obj \) -prune -exec rm -rf {} +
}

run_stages "$@"
