// Package shapes computes the area and perimeter of four plane shapes:
// circle, rectangle, square and triangle.
//
// Make a shape with New or with one of the constructors. Each constructor
// checks the dimensions and returns an error for bad input.
package shapes

import (
	"errors"
	"fmt"
	"math"
	"strings"
)

// Errors that the constructors return. Test them with errors.Is.
var (
	// ErrUnknownShape means that the shape name is not known.
	ErrUnknownShape = errors.New("unknown shape")
	// ErrDimensionCount means that the shape got the wrong number of dimensions.
	ErrDimensionCount = errors.New("wrong number of dimensions")
	// ErrNotPositive means that a dimension is not a finite number above zero.
	ErrNotPositive = errors.New("dimensions must be positive numbers")
	// ErrNotTriangle means that the sides do not obey the strict triangle inequality.
	ErrNotTriangle = errors.New("sides do not form a triangle")
)

// DimensionCountError is the error that New returns for the wrong number of
// dimensions. It matches ErrDimensionCount with errors.Is.
type DimensionCountError struct {
	Shape string   // name of the shape
	Names []string // names of the dimensions that the shape needs
}

// Error describes the dimensions that the shape needs.
func (e *DimensionCountError) Error() string {
	return fmt.Sprintf("%s needs %d dimension(s): %s", e.Shape, len(e.Names), strings.Join(e.Names, " "))
}

// Is reports whether target is ErrDimensionCount.
func (e *DimensionCountError) Is(target error) bool { return target == ErrDimensionCount }

// Shape is a plane shape.
type Shape interface {
	// Name returns the name of the shape, for example "circle".
	Name() string
	// Area returns the area of the shape.
	Area() float64
	// Perimeter returns the perimeter of the shape.
	Perimeter() float64
}

// Names lists the names of all shapes.
var Names = []string{"circle", "rectangle", "square", "triangle"}

var dimensionNames = map[string][]string{
	"circle":    {"radius"},
	"rectangle": {"width", "height"},
	"square":    {"side"},
	"triangle":  {"a", "b", "c"},
}

// DimensionNames returns the names of the dimensions of the named shape, in
// order. The second result is false if the shape is not known.
func DimensionNames(name string) ([]string, bool) {
	names, ok := dimensionNames[name]
	if !ok {
		return nil, false
	}
	return append([]string(nil), names...), true
}

func checkPositive(dims ...float64) error {
	for _, d := range dims {
		if !(d > 0) || math.IsInf(d, 0) {
			return ErrNotPositive
		}
	}
	return nil
}

type circle struct{ radius float64 }

func (circle) Name() string         { return "circle" }
func (c circle) Area() float64      { return math.Pi * c.radius * c.radius }
func (c circle) Perimeter() float64 { return 2 * math.Pi * c.radius }

type rectangle struct{ width, height float64 }

func (rectangle) Name() string         { return "rectangle" }
func (r rectangle) Area() float64      { return r.width * r.height }
func (r rectangle) Perimeter() float64 { return 2 * (r.width + r.height) }

type square struct{ side float64 }

func (square) Name() string         { return "square" }
func (s square) Area() float64      { return s.side * s.side }
func (s square) Perimeter() float64 { return 4 * s.side }

type triangle struct{ a, b, c float64 }

func (triangle) Name() string { return "triangle" }
func (t triangle) Area() float64 {
	p := (t.a + t.b + t.c) / 2
	return math.Sqrt(p * (p - t.a) * (p - t.b) * (p - t.c))
}
func (t triangle) Perimeter() float64 { return t.a + t.b + t.c }

// NewCircle returns a circle with the given radius.
func NewCircle(radius float64) (Shape, error) {
	if err := checkPositive(radius); err != nil {
		return nil, err
	}
	return circle{radius}, nil
}

// NewRectangle returns a rectangle with the given width and height.
func NewRectangle(width, height float64) (Shape, error) {
	if err := checkPositive(width, height); err != nil {
		return nil, err
	}
	return rectangle{width, height}, nil
}

// NewSquare returns a square with the given side.
func NewSquare(side float64) (Shape, error) {
	if err := checkPositive(side); err != nil {
		return nil, err
	}
	return square{side}, nil
}

// NewTriangle returns a triangle with the given sides. Each side must be
// shorter than the sum of the other two.
func NewTriangle(a, b, c float64) (Shape, error) {
	if err := checkPositive(a, b, c); err != nil {
		return nil, err
	}
	if a+b <= c || a+c <= b || b+c <= a {
		return nil, ErrNotTriangle
	}
	return triangle{a, b, c}, nil
}

// New returns the named shape. The dimensions follow the order that
// DimensionNames reports.
func New(name string, dims ...float64) (Shape, error) {
	names, ok := dimensionNames[name]
	if !ok {
		return nil, fmt.Errorf("%w '%s'", ErrUnknownShape, name)
	}
	if len(dims) != len(names) {
		return nil, &DimensionCountError{Shape: name, Names: append([]string(nil), names...)}
	}
	switch name {
	case "circle":
		return NewCircle(dims[0])
	case "rectangle":
		return NewRectangle(dims[0], dims[1])
	case "square":
		return NewSquare(dims[0])
	default:
		return NewTriangle(dims[0], dims[1], dims[2])
	}
}
