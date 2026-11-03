import math

import pytest

from shapes import Circle, Rectangle, ShapeError, Square, Triangle, make_shape
from shapes.cli import main


@pytest.mark.parametrize(
    ("shape", "area", "perimeter"),
    [
        (Circle(2.0), 4 * math.pi, 4 * math.pi),
        (Rectangle(2.0, 3.0), 6.0, 10.0),
        (Square(3.0), 9.0, 12.0),
        (Triangle(3.0, 4.0, 5.0), 6.0, 12.0),
    ],
)
def test_values(shape, area, perimeter):
    assert shape.area() == pytest.approx(area)
    assert shape.perimeter() == pytest.approx(perimeter)


@pytest.mark.parametrize("value", [0.0, -1.0, math.inf, math.nan])
def test_rejects_bad_dimension(value):
    with pytest.raises(ShapeError, match="positive"):
        Square(value)


@pytest.mark.parametrize("sides", [(1.0, 1.0, 5.0), (1.0, 2.0, 3.0)])
def test_rejects_bad_triangle(sides):
    with pytest.raises(ShapeError, match="triangle"):
        Triangle(*sides)


def test_factory():
    assert make_shape("triangle", [3, 4, 5]) == Triangle(3, 4, 5)
    with pytest.raises(ShapeError, match="unknown shape 'hexagon'"):
        make_shape("hexagon", [1])
    with pytest.raises(ShapeError, match="rectangle needs 2 dimension"):
        make_shape("rectangle", [1])


def test_cli(capsys):
    assert main(["circle", "2"]) == 0
    assert capsys.readouterr().out == "circle: area = 12.566371, perimeter = 12.566371\n"
    assert main(["square", "abc"]) == 1
    assert capsys.readouterr().err == "error: 'abc' is not a number\n"
