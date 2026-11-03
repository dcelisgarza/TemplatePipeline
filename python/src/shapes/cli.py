"""The ``shapes-python`` command-line program. See SPEC.md."""

from __future__ import annotations

import sys
from collections.abc import Sequence

from shapes import SHAPES, Shape, ShapeError, __version__, make_shape

USAGE = """\
Usage: shapes-python [SHAPE DIMENSION...]

Print the area and perimeter of a plane shape.

Shapes and their dimensions:
  circle     RADIUS
  rectangle  WIDTH HEIGHT
  square     SIDE
  triangle   A B C

Without arguments, shapes-python asks for the shape and its dimensions.

Options:
  -h, --help     Print this help and exit.
  -V, --version  Print the version and exit.
"""

SHAPE_PROMPT = "shape (circle, rectangle, square, triangle; q to quit): "


def _parse_number(text: str) -> float:
    try:
        return float(text)
    except ValueError:
        raise ShapeError(f"'{text}' is not a number") from None


def _build(name: str, args: Sequence[str]) -> Shape:
    if name not in SHAPES:
        raise ShapeError(f"unknown shape '{name}'")
    names = SHAPES[name].dimensions()
    if len(args) != len(names):
        raise ShapeError(f"{name} needs {len(names)} dimension(s): {' '.join(names)}")
    return make_shape(name, [_parse_number(a) for a in args])


def _report(shape: Shape) -> None:
    print(f"{shape.name}: area = {shape.area():.6f}, perimeter = {shape.perimeter():.6f}")


def _ask(prompt: str) -> str | None:
    print(prompt, end="", flush=True)
    line = sys.stdin.readline()
    return line.strip() if line else None


def interactive() -> int:
    """Ask for shapes until the user types ``q`` or the input ends."""
    while True:
        name = _ask(SHAPE_PROMPT)
        if name is None:
            print()
            return 0
        if not name:
            continue
        if name in ("q", "quit"):
            return 0
        if name not in SHAPES:
            print(f"error: unknown shape '{name}'", file=sys.stderr)
            continue
        answers = []
        for dim in SHAPES[name].dimensions():
            answer = _ask(f"  {dim}: ")
            if answer is None:
                print()
                return 0
            answers.append(answer)
        try:
            _report(_build(name, answers))
        except ShapeError as err:
            print(f"error: {err}", file=sys.stderr)


def main(argv: Sequence[str] | None = None) -> int:
    """Run the program with ``argv`` (default: ``sys.argv[1:]``)."""
    args = list(sys.argv[1:] if argv is None else argv)
    if not args:
        return interactive()
    if args[0] in ("-h", "--help"):
        print(USAGE, end="")
        return 0
    if args[0] in ("-V", "--version"):
        print(f"shapes-python {__version__}")
        return 0
    try:
        _report(_build(args[0], args[1:]))
    except ShapeError as err:
        print(f"error: {err}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
