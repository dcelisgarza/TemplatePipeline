namespace Shapes;

/// <summary>
/// Makes shapes from a name and a list of dimensions.
/// </summary>
public static class ShapeFactory
{
    /// <summary>The message for a dimension that is not a finite number above zero.</summary>
    public const string NotPositiveMessage = "dimensions must be positive numbers";

    /// <summary>The message for sides that do not form a triangle.</summary>
    public const string NotTriangleMessage = "sides do not form a triangle";

    private static readonly Dictionary<string, string[]> Dimensions = new()
    {
        ["circle"] = ["radius"],
        ["rectangle"] = ["width", "height"],
        ["square"] = ["side"],
        ["triangle"] = ["a", "b", "c"],
    };

    /// <summary>The names of all shapes.</summary>
    public static IReadOnlyList<string> Names { get; } = ["circle", "rectangle", "square", "triangle"];

    /// <summary>Tells if the name is the name of a shape.</summary>
    /// <param name="name">The shape name.</param>
    /// <returns><c>true</c> if the shape is known.</returns>
    public static bool IsKnown(string name) => Dimensions.ContainsKey(name);

    /// <summary>Returns the names of the dimensions of a shape, in order.</summary>
    /// <param name="name">The shape name.</param>
    /// <returns>The dimension names.</returns>
    /// <exception cref="ArgumentException">The shape is not known.</exception>
    public static IReadOnlyList<string> DimensionNames(string name) =>
        Dimensions.TryGetValue(name, out var names)
            ? names
            : throw new ArgumentException($"unknown shape '{name}'");

    /// <summary>Makes a shape.</summary>
    /// <param name="name">One of <see cref="Names"/>.</param>
    /// <param name="dimensions">The dimensions, in the order of <see cref="DimensionNames"/>.</param>
    /// <returns>The new shape.</returns>
    /// <exception cref="ArgumentException">
    /// The name is not known, the count of dimensions is wrong, or a dimension is not valid.
    /// </exception>
    public static Shape Create(string name, params double[] dimensions)
    {
        var names = DimensionNames(name);
        if (dimensions.Length != names.Count)
        {
            throw new ArgumentException(
                $"{name} needs {names.Count} dimension(s): {string.Join(' ', names)}");
        }
        return name switch
        {
            "circle" => new Circle(dimensions[0]),
            "rectangle" => new Rectangle(dimensions[0], dimensions[1]),
            "square" => new Square(dimensions[0]),
            _ => new Triangle(dimensions[0], dimensions[1], dimensions[2]),
        };
    }
}
