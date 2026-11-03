# shapes-go

The Go version of the `shapes` program. See the [spec](../SPEC.md).

| Part          | Tool                                      |
| ------------- | ----------------------------------------- |
| Build         | `go build`                                |
| Test          | `go test` and `go vet`                    |
| Coverage      | `go test -coverprofile`, `go tool cover` |
| Documentation | doc2go (static HTML)                      |
| Package       | release binary (`.tar.gz`)                |

The module path in `go.mod` is `github.com/OWNER/TemplatePipeline/go`.
The owner must change `OWNER` to the real GitHub name. Change it in `go.mod`
and in the imports of `shapes_test.go` and `cmd/shapes-go/main.go`.

The version comes from the `VERSION` file in the repository root.
The pipeline passes it to the linker with `-ldflags "-X main.version=..."`.

## Use the library

```go
import shapes "github.com/OWNER/TemplatePipeline/go"

t, err := shapes.New("triangle", 3, 4, 5)
if err == nil {
	fmt.Println(t.Area()) // 6
}
```

The errors are `ErrUnknownShape`, `ErrDimensionCount`, `ErrNotPositive` and
`ErrNotTriangle`. Test them with `errors.Is`.

## Pipeline

```bash
./pipeline.sh            # build, test, docs, package, install
./pipeline.sh test       # one stage
```

The install stage sets `GOBIN` to `$PREFIX/go/bin`. It does not use `~/go/bin`.

By hand:

```bash
go build -ldflags "-X main.version=0.1.0" -o bin/shapes-go ./cmd/shapes-go
go vet ./...
go test ./...
GOTOOLCHAIN=auto go run go.abhg.dev/doc2go@v0.12.2 -out docs-out ./...
GOBIN=/tmp/template-pipeline/go/bin go install -ldflags "-X main.version=0.1.0" ./cmd/shapes-go
```
