#!/usr/bin/env bash
# Pipeline for the Julia version: Pkg, Test, Documenter.jl, Pkg Apps.
NAME=julia
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"
SRC="$ROOT/julia"
BUILD="$SRC/build"

jl() { julia --startup-file=no "$@"; }

stage_build() {
  need julia
  jl --project="$SRC" -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
}

stage_test() {
  jl --project="$SRC" -e 'using Pkg; Pkg.test()'
}

stage_docs() {
  jl --project="$SRC/docs" -e 'using Pkg; Pkg.instantiate()'
  jl --project="$SRC/docs" "$SRC/docs/make.jl"
  publish_docs "$SRC/docs/build"
}

stage_package() {
  local out="$DIST_DIR/$NAME" pkg="shapes-julia-$VERSION-src"
  rm -rf "$BUILD/package"
  mkdir -p "$BUILD/package/$pkg" "$out"
  cp -R "$SRC/Project.toml" "$SRC/README.md" "$SRC/src" "$SRC/test" "$BUILD/package/$pkg/"
  tar -C "$BUILD/package" -czf "$out/$pkg.tar.gz" "$pkg"
  log "wrote $out/$pkg.tar.gz"
  [ "${SHAPES_JULIA_BINARY:-0}" = 1 ] && package_binary
  return 0
}

# Compiled program with JuliaC.jl (Julia 1.12+). It takes minutes and the
# bundle is large (about 180 MB packed), so it runs only when asked:
#   SHAPES_JULIA_BINARY=1 ./pipeline.sh package
package_binary() {
  local out="$DIST_DIR/$NAME" bin="shapes-julia-$VERSION-$(platform)"
  local env="$BUILD/juliac-env" app="$BUILD/juliac-src"
  jl --project="$env" -e 'using Pkg; Pkg.add("JuliaC")'
  rm -rf "$app" "${BUILD:?}/$bin"
  mkdir -p "$app"
  cp -R "$SRC/Project.toml" "$SRC/src" "$app/"
  jl --project="$env" -m JuliaC --output-exe shapes-julia \
    --bundle "$BUILD/$bin" "$app"
  "$BUILD/$bin/bin/shapes-julia" --version
  tar -C "$BUILD" -czf "$out/$bin.tar.gz" "$bin"
  log "wrote $out/$bin.tar.gz"
}

stage_install() {
  local home="$PREFIX/julia"
  # Copy the package into the prefix, so that the install does not depend on this checkout.
  rm -rf "${home:?}/src" "${home:?}/depot"
  mkdir -p "$home/src/Shapes"
  cp -R "$SRC/Project.toml" "$SRC/src" "$home/src/Shapes/"
  # The trailing colon keeps the default depots (registries, stdlibs) visible.
  JULIA_DEPOT_PATH="$home/depot:" jl -e \
    'using Pkg; Pkg.Apps.develop(path = ARGS[1])' "$home/src/Shapes"
  link_bin "$home/depot/bin/shapes-julia"
  smoke_test "$PREFIX/bin/shapes-julia"
  installed shapes-julia
}

stage_clean() {
  rm -rf "$BUILD" "$SRC/docs/build" "$SRC/Manifest.toml" "$SRC/docs/Manifest.toml" \
    "${DIST_DIR:?}/$NAME" "${SITE_DIR:?}/$NAME"
}

run_stages "$@"
