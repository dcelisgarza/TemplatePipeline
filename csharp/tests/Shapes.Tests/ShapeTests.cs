using Shapes;

namespace Shapes.Tests;

public class ShapeTests
{
    [Theory]
    [InlineData("circle", new[] { 2.0 }, 4 * Math.PI, 4 * Math.PI)]
    [InlineData("rectangle", new[] { 2.0, 3.0 }, 6.0, 10.0)]
    [InlineData("square", new[] { 3.0 }, 9.0, 12.0)]
    [InlineData("triangle", new[] { 3.0, 4.0, 5.0 }, 6.0, 12.0)]
    public void Values(string name, double[] dims, double area, double perimeter)
    {
        var shape = ShapeFactory.Create(name, dims);
        Assert.Equal(name, shape.Name);
        Assert.Equal(area, shape.Area, 9);
        Assert.Equal(perimeter, shape.Perimeter, 9);
    }

    [Theory]
    [InlineData(0.0)]
    [InlineData(-1.0)]
    [InlineData(double.PositiveInfinity)]
    [InlineData(double.NegativeInfinity)]
    [InlineData(double.NaN)]
    public void BadDimensionsAreRejected(double bad)
    {
        Assert.Throws<ArgumentException>(() => new Circle(bad));
        Assert.Throws<ArgumentException>(() => new Square(bad));
        Assert.Throws<ArgumentException>(() => new Rectangle(1, bad));
        var e = Assert.Throws<ArgumentException>(() => ShapeFactory.Create("triangle", 3, 4, bad));
        Assert.Equal("dimensions must be positive numbers", e.Message);
    }

    [Theory]
    [InlineData(1.0, 1.0, 5.0)]
    [InlineData(1.0, 2.0, 3.0)]
    [InlineData(5.0, 1.0, 1.0)]
    [InlineData(1.0, 5.0, 1.0)]
    public void TriangleInequalityIsStrict(double a, double b, double c)
    {
        var e = Assert.Throws<ArgumentException>(() => new Triangle(a, b, c));
        Assert.Equal("sides do not form a triangle", e.Message);
    }

    [Fact]
    public void UnknownShape()
    {
        var e = Assert.Throws<ArgumentException>(() => ShapeFactory.Create("hexagon", 1));
        Assert.Equal("unknown shape 'hexagon'", e.Message);
    }

    [Fact]
    public void WrongNumberOfDimensions()
    {
        var e = Assert.Throws<ArgumentException>(() => ShapeFactory.Create("rectangle", 1));
        Assert.Equal("rectangle needs 2 dimension(s): width height", e.Message);
    }
}
