#!/usr/bin/env bash
# Write site/index.html with a link to the documentation of each language in site/.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SITE_DIR="${SITE_DIR:-$ROOT/site}"
VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"

title() {
  case "$1" in
    c) echo "C — Doxygen" ;;
    cpp) echo "C++ — Doxygen" ;;
    python) echo "Python — Sphinx" ;;
    rust) echo "Rust — rustdoc" ;;
    julia) echo "Julia — Documenter.jl" ;;
    fortran) echo "Fortran — FORD" ;;
    typescript) echo "TypeScript — TypeDoc" ;;
    go) echo "Go — doc2go" ;;
    csharp) echo "C# — DocFX" ;;
  esac
}

mkdir -p "$SITE_DIR"
items=""
for lang in c cpp python rust julia fortran typescript go csharp; do
  [ -f "$SITE_DIR/$lang/index.html" ] || continue
  items+="      <li><a href=\"$lang/\">$(title "$lang")</a></li>"$'\n'
done

cat >"$SITE_DIR/index.html" <<HTML
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>shapes $VERSION documentation</title>
    <style>
      body { font-family: system-ui, sans-serif; max-width: 40rem; margin: 3rem auto; padding: 0 1rem; line-height: 1.6; }
      li { margin: 0.4rem 0; }
    </style>
  </head>
  <body>
    <h1>shapes $VERSION</h1>
    <p>The same small program in many languages. Each link opens the API documentation of one version.</p>
    <ul>
$items    </ul>
  </body>
</html>
HTML
touch "$SITE_DIR/.nojekyll"
echo "wrote $SITE_DIR/index.html"
