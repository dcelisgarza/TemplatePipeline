# shapes-csharp

The C# version of the `shapes` program. It has a library and a command-line tool.

Make a shape with `ShapeFactory.Create` and read its `Area` and `Perimeter`:

```csharp
using Shapes;

var triangle = ShapeFactory.Create("triangle", 3, 4, 5);
Console.WriteLine(triangle.Area); // 6
```

See the [API reference](api/Shapes.yml).
