# TemplatePipeline

A template repository with one small program in many languages. Each version shows a
minimal, idiomatic pipeline with the standard tools of its language:

**build → test → document → package → install**

The same scripts run on your computer and on GitHub Actions. GitHub Pages hosts the
documentation. A tag `v*` attaches the packages and the binaries to a GitHub release.

## The program

`shapes-<lang>` prints the area and the perimeter of a circle, a rectangle, a square or a
triangle. Give the shape on the command line, or start the program without arguments
and it asks you for the shape and the dimensions. See [SPEC.md](SPEC.md).

```console
$ shapes-rust circle 2
circle: area = 12.566371, perimeter = 12.566371

$ shapes-python
shape (circle, rectangle, square, triangle; q to quit): triangle
  a: 3
  b: 4
  c: 5
triangle: area = 6.000000, perimeter = 12.000000
shape (circle, rectangle, square, triangle; q to quit): q
```

## Languages and tools

| Directory                    | Build and package             | Test                | Docs          | Distribution                         |
| ---------------------------- | ----------------------------- | ------------------- | ------------- | ------------------------------------ |
| [`c/`](c/)                   | CMake, CPack                  | CTest               | Doxygen       | binary `.tar.gz`, CMake package      |
| [`cpp/`](cpp/)               | CMake, CPack                  | GoogleTest, CTest   | Doxygen       | binary `.tar.gz`, CMake package      |
| [`python/`](python/)         | uv, `uv_build`                | pytest, ruff        | Sphinx        | wheel, sdist                         |
| [`rust/`](rust/)             | Cargo                         | `cargo test`, clippy| rustdoc       | binary `.tar.gz`, `.crate`           |
| [`julia/`](julia/)           | Pkg (apps)                    | `Test`              | Documenter.jl | source `.tar.gz`, JuliaC binary (releases) |
| [`fortran/`](fortran/)       | fpm                           | test-drive          | FORD          | binary `.tar.gz`                     |
| [`typescript/`](typescript/) | npm, tsc                      | `node:test`         | TypeDoc       | npm `.tgz`                           |
| [`go/`](go/)                 | Go modules                    | `go test`, `go vet` | doc2go        | binary `.tar.gz`                     |
| [`csharp/`](csharp/)         | .NET SDK                      | xUnit               | DocFX         | NuGet tool, single-file binary       |

Each directory has its own README with the commands to run each step by hand.

## Run the pipeline locally

Each language has a script `<lang>/pipeline.sh`. With no arguments it runs all stages.

```bash
./rust/pipeline.sh                 # build, test, docs, package, install
./rust/pipeline.sh test docs       # some stages, in this order
make rust                          # the same as ./rust/pipeline.sh
make rust-test                     # one stage
make -k                            # all languages; continue after a failure
make site                          # site/index.html with links to all docs
```

The stages:

| Stage     | Result                                                                          |
| --------- | ------------------------------------------------------------------------------- |
| `build`   | Compiles the library and the program. The other stages run it first.            |
| `test`    | Runs the unit tests (and the linters where the language has standard ones).     |
| `docs`    | Writes the HTML API documentation to `site/<lang>/`.                            |
| `package` | Writes the packages and the binaries to `dist/<lang>/`.                         |
| `install` | Installs the program below `$PREFIX`, then runs a smoke test on it. Where the language has a package format (wheel, npm, NuGet), it installs that package, so it runs `package` first. |
| `clean`   | Removes the build output of the language.                                       |

### Where the programs go

The `install` stage puts each language in `$PREFIX/<lang>/` and puts a link to each
program in `$PREFIX/bin/`. `PREFIX` is `/tmp/template-pipeline` by default, so the
operating system removes the files at the next restart. Nothing goes into your home
directory.

```bash
export PATH="/tmp/template-pipeline/bin:$PATH"
shapes-c                                   # interactive mode
PREFIX=$HOME/.local ./rust/pipeline.sh install   # a permanent install
```

### Tools that you need

You need only the tools of the languages that you run. The scripts stop with a clear
message when a tool is missing.

| Language   | Tools                                                    |
| ---------- | -------------------------------------------------------- |
| C, C++     | a C/C++ compiler, CMake ≥ 3.21, Doxygen (for the docs)   |
| Python     | [uv](https://docs.astral.sh/uv/)                         |
| Rust       | [rustup](https://rustup.rs/) (cargo, clippy, rustfmt)    |
| Julia      | Julia ≥ 1.12 ([juliaup](https://github.com/JuliaLang/juliaup)) |
| Fortran    | gfortran, [fpm](https://fpm.fortran-lang.org/), uv (for FORD) |
| TypeScript | Node.js ≥ 20 with npm                                    |
| Go         | Go ≥ 1.22                                                |
| C#         | .NET SDK 8                                               |

On Ubuntu 24.04:

```bash
sudo apt-get install -y build-essential cmake doxygen graphviz gfortran golang-go dotnet-sdk-8.0
uv tool install fpm
```

## Run the pipeline on GitHub

[`.github/workflows/pipeline.yml`](.github/workflows/pipeline.yml) runs
`<lang>/pipeline.sh` for each language on Linux and macOS.

| Event             | Jobs                                                               |
| ----------------- | ------------------------------------------------------------------ |
| pull request      | pipeline                                                           |
| push to `main`    | pipeline, then publish the docs to GitHub Pages                    |
| tag `v*`          | pipeline, then a GitHub release with all packages and binaries     |

Do these steps once after you make a repository from this template:

1. In **Settings → Pages**, set **Source** to **GitHub Actions**.
2. Change the Go module path in `go/go.mod` to your repository.

To make a release:

1. Change the version in `VERSION` and in each manifest. `make check-versions` finds the manifests that you did not change.
2. Commit, then push a tag: `git tag v0.2.0 && git push origin v0.2.0`.

The docs are then at `https://<owner>.github.io/<repository>/`.

## Layout

```text
VERSION                  the version of all languages
SPEC.md                  the behaviour that all versions share
Makefile                 shortcuts for the pipeline scripts
scripts/lib.sh           helpers for the pipeline scripts, and the smoke test
scripts/make-site.sh     the landing page of the docs
scripts/check-versions.sh
<lang>/pipeline.sh       the pipeline of one language
.github/workflows/       the GitHub Actions workflow
```

## Add a language

1. Make `<lang>/` with a library, a program `shapes-<lang>` that obeys [SPEC.md](SPEC.md), and unit tests.
2. Copy `c/pipeline.sh` and change the commands of each stage.
3. Add the language to `LANGS` in the `Makefile`, to `scripts/make-site.sh`, to `scripts/check-versions.sh` and to the matrix in the workflow.
