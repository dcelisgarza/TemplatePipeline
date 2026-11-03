namespace Shapes;

/// <summary>
/// A plane shape with an area and a perimeter.
/// </summary>
/// <remarks>
/// Make shapes with <see cref="ShapeFactory.Create"/> or with the constructors of the derived types.
/// Every constructor throws <see cref="ArgumentException"/> for bad dimensions.
/// </remarks>
public abstract record Shape
{
    /// <summary>The name of the shape, for example <c>circle</c>.</summary>
    public abstract string Name { get; }

    /// <summary>The area of the shape.</summary>
    public abstract double Area { get; }

    /// <summary>The perimeter of the shape.</summary>
    public abstract double Perimeter { get; }

    /// <summary>Checks that a dimension is a finite number above zero.</summary>
    /// <param name="value">The dimension.</param>
    /// <returns>The same value.</returns>
    /// <exception cref="ArgumentException">The value is zero, negative, infinite or NaN.</exception>
    protected static double Positive(double value)
    {
        if (!double.IsFinite(value) || value <= 0)
        {
            throw new ArgumentException(ShapeFactory.NotPositiveMessage);
        }
        return value;
    }
}

/// <summary>A circle.</summary>
public sealed record Circle : Shape
{
    /// <summary>Makes a circle.</summary>
    /// <param name="radius">The radius.</param>
    /// <exception cref="ArgumentException">The radius is not a finite number above zero.</exception>
    public Circle(double radius) => Radius = Positive(radius);

    /// <summary>The radius.</summary>
    public double Radius { get; }

    /// <inheritdoc/>
    public override string Name => "circle";

    /// <inheritdoc/>
    public override double Area => Math.PI * Radius * Radius;

    /// <inheritdoc/>
    public override double Perimeter => 2 * Math.PI * Radius;
}

/// <summary>A rectangle.</summary>
public sealed record Rectangle : Shape
{
    /// <summary>Makes a rectangle.</summary>
    /// <param name="width">The width.</param>
    /// <param name="height">The height.</param>
    /// <exception cref="ArgumentException">A dimension is not a finite number above zero.</exception>
    public Rectangle(double width, double height)
    {
        Width = Positive(width);
        Height = Positive(height);
    }

    /// <summary>The width.</summary>
    public double Width { get; }

    /// <summary>The height.</summary>
    public double Height { get; }

    /// <inheritdoc/>
    public override string Name => "rectangle";

    /// <inheritdoc/>
    public override double Area => Width * Height;

    /// <inheritdoc/>
    public override double Perimeter => 2 * (Width + Height);
}

/// <summary>A square.</summary>
public sealed record Square : Shape
{
    /// <summary>Makes a square.</summary>
    /// <param name="side">The side.</param>
    /// <exception cref="ArgumentException">The side is not a finite number above zero.</exception>
    public Square(double side) => Side = Positive(side);

    /// <summary>The side.</summary>
    public double Side { get; }

    /// <inheritdoc/>
    public override string Name => "square";

    /// <inheritdoc/>
    public override double Area => Side * Side;

    /// <inheritdoc/>
    public override double Perimeter => 4 * Side;
}

/// <summary>A triangle.</summary>
public sealed record Triangle : Shape
{
    /// <summary>Makes a triangle.</summary>
    /// <param name="a">The first side.</param>
    /// <param name="b">The second side.</param>
    /// <param name="c">The third side.</param>
    /// <exception cref="ArgumentException">
    /// A side is not a finite number above zero, or the sides break the strict triangle inequality.
    /// </exception>
    public Triangle(double a, double b, double c)
    {
        A = Positive(a);
        B = Positive(b);
        C = Positive(c);
        if (a + b <= c || a + c <= b || b + c <= a)
        {
            throw new ArgumentException(ShapeFactory.NotTriangleMessage);
        }
    }

    /// <summary>The first side.</summary>
    public double A { get; }

    /// <summary>The second side.</summary>
    public double B { get; }

    /// <summary>The third side.</summary>
    public double C { get; }

    /// <inheritdoc/>
    public override string Name => "triangle";

    /// <inheritdoc/>
    public override double Area
    {
        get
        {
            var p = (A + B + C) / 2;
            return Math.Sqrt(p * (p - A) * (p - B) * (p - C));
        }
    }

    /// <inheritdoc/>
    public override double Perimeter => A + B + C;
}
