# shapes-julia

The Julia version of the `shapes` program. See the [spec](../SPEC.md).

| Part          | Tool                                          |
| ------------- | --------------------------------------------- |
| Build         | Pkg (`instantiate`, `precompile`)             |
| Test          | `Pkg.test()` with the Test standard library   |
| Coverage      | `Pkg.test(coverage=true)`, Coverage.jl, genhtml |
| Documentation | Documenter.jl (`docs/make.jl`)                |
| Package       | Source `.tar.gz`                              |
| Install       | Pkg Apps (`[apps.shapes-julia]`, Julia 1.12+) |

## Use the library

```julia
using Shapes

area(Triangle(3, 4, 5))   # 6.0
perimeter(Square(3))      # 12.0

s = shape("circle", [2.0])
area(s)                   # 12.566370614359172

Circle(-1)                # throws ShapeError
```

Bad input throws a `ShapeError`. Its `kind` field says what went wrong.

## Pipeline

```bash
./pipeline.sh            # build, test, docs, package, install
./pipeline.sh test       # one stage
```

By hand:

```bash
julia --project -e 'using Pkg; Pkg.instantiate(); Pkg.test()'
julia --project=docs -e 'using Pkg; Pkg.instantiate()'
julia --project=docs docs/make.jl
JULIA_DEPOT_PATH=/tmp/template-pipeline/julia/depot: \
  julia -e 'using Pkg; Pkg.Apps.develop(path = ".")'
```

The trailing colon in `JULIA_DEPOT_PATH` keeps the default depots. The app
launcher is then `/tmp/template-pipeline/julia/depot/bin/shapes-julia`.
