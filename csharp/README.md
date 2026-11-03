# shapes-csharp

The C# version of the `shapes` program. See the [spec](../SPEC.md).

| Part          | Tool                                                    |
| ------------- | ------------------------------------------------------- |
| Build         | .NET 8 SDK, `dotnet build` (solution `Shapes.sln`)      |
| Test          | xUnit, `dotnet test`                                    |
| Documentation | docfx (local tool, see `.config/dotnet-tools.json`)     |
| Package       | `dotnet pack` (`.nupkg`) and `dotnet publish` (binary)  |

The version lives in `Directory.Build.props`.

The solution has three projects:

- `src/Shapes` is the library.
- `src/Shapes.Cli` is the command-line program. It is a .NET tool named `shapes-csharp`.
- `tests/Shapes.Tests` holds the tests.

## Use the library

```csharp
using Shapes;

var t = ShapeFactory.Create("triangle", 3, 4, 5);
Console.WriteLine(t.Area); // 6
```

Bad input throws `ArgumentException`.

## Pipeline

```bash
./pipeline.sh            # build, test, docs, package, install
./pipeline.sh test       # one stage
```

The package stage writes two `.nupkg` files and a self-contained binary
(`shapes-csharp-<version>-<platform>.tar.gz`) to `dist/csharp`.
The install stage uses `dotnet tool install --tool-path "$PREFIX/csharp/bin"`.
It does not use `~/.dotnet/tools`.

By hand:

```bash
dotnet build Shapes.sln -c Release
dotnet test Shapes.sln -c Release --no-build
dotnet tool restore
dotnet docfx docs/docfx.json
dotnet pack src/Shapes.Cli -c Release -o ../../dist/csharp
dotnet tool install --tool-path /tmp/template-pipeline/csharp/bin \
  --add-source ../dist/csharp shapes-csharp --version 0.1.0
```
