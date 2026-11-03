"""The shapes and the factory :func:`make_shape`."""

from __future__ import annotations

import math
from abc import ABC, abstractmethod
from collections.abc import Sequence
from dataclasses import dataclass, fields


class ShapeError(ValueError):
    """The dimensions do not give a valid shape."""


def _check_positive(*values: float) -> None:
    for value in values:
        if not (value > 0 and math.isfinite(value)):
            raise ShapeError("dimensions must be positive numbers")


class Shape(ABC):
    """A plane shape with an area and a perimeter."""

    #: The name of the shape, for example ``"circle"``.
    name: str = ""

    @abstractmethod
    def area(self) -> float:
        """Return the area."""

    @abstractmethod
    def perimeter(self) -> float:
        """Return the perimeter."""

    @classmethod
    def dimensions(cls) -> tuple[str, ...]:
        """Return the names of the dimensions, in constructor order."""
        return tuple(f.name for f in fields(cls))  # type: ignore[arg-type]


@dataclass(frozen=True)
class Circle(Shape):
    """A circle with radius ``radius``."""

    radius: float
    name = "circle"

    def __post_init__(self) -> None:
        _check_positive(self.radius)

    def area(self) -> float:
        return math.pi * self.radius**2

    def perimeter(self) -> float:
        return 2 * math.pi * self.radius


@dataclass(frozen=True)
class Rectangle(Shape):
    """A rectangle with sides ``width`` and ``height``."""

    width: float
    height: float
    name = "rectangle"

    def __post_init__(self) -> None:
        _check_positive(self.width, self.height)

    def area(self) -> float:
        return self.width * self.height

    def perimeter(self) -> float:
        return 2 * (self.width + self.height)


@dataclass(frozen=True)
class Square(Shape):
    """A square with side ``side``."""

    side: float
    name = "square"

    def __post_init__(self) -> None:
        _check_positive(self.side)

    def area(self) -> float:
        return self.side**2

    def perimeter(self) -> float:
        return 4 * self.side


@dataclass(frozen=True)
class Triangle(Shape):
    """A triangle with sides ``a``, ``b`` and ``c``.

    Raises:
        ShapeError: if the sides do not obey the triangle inequality.
    """

    a: float
    b: float
    c: float
    name = "triangle"

    def __post_init__(self) -> None:
        _check_positive(self.a, self.b, self.c)
        a, b, c = self.a, self.b, self.c
        if a + b <= c or a + c <= b or b + c <= a:
            raise ShapeError("sides do not form a triangle")

    def area(self) -> float:
        """Return the area with Heron's formula."""
        p = self.perimeter() / 2
        return math.sqrt(p * (p - self.a) * (p - self.b) * (p - self.c))

    def perimeter(self) -> float:
        return self.a + self.b + self.c


#: The shape classes by name.
SHAPES: dict[str, type[Shape]] = {cls.name: cls for cls in (Circle, Rectangle, Square, Triangle)}


def make_shape(name: str, dims: Sequence[float]) -> Shape:
    """Make the shape called ``name`` from its dimensions.

    Raises:
        ShapeError: if the name is not known, the number of dimensions is
            wrong, or the dimensions are not valid.
    """
    try:
        cls = SHAPES[name]
    except KeyError:
        raise ShapeError(f"unknown shape '{name}'") from None
    names = cls.dimensions()
    if len(dims) != len(names):
        raise ShapeError(f"{name} needs {len(names)} dimension(s): {' '.join(names)}")
    return cls(*dims)
