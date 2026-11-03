"""Area and perimeter of simple plane shapes.

Example:
    >>> from shapes import Circle, make_shape
    >>> round(Circle(2.0).area(), 6)
    12.566371
    >>> make_shape("rectangle", [2.0, 3.0]).perimeter()
    10.0
"""

from importlib.metadata import PackageNotFoundError, version

from shapes.core import (
    SHAPES,
    Circle,
    Rectangle,
    Shape,
    ShapeError,
    Square,
    Triangle,
    make_shape,
)

try:
    __version__ = version("shapes-python")
except PackageNotFoundError:  # pragma: no cover - source tree without install
    __version__ = "unknown"

__all__ = [
    "SHAPES",
    "Circle",
    "Rectangle",
    "Shape",
    "ShapeError",
    "Square",
    "Triangle",
    "__version__",
    "make_shape",
]
