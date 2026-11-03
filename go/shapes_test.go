package shapes_test

import (
	"errors"
	"fmt"
	"math"
	"testing"

	shapes "github.com/OWNER/TemplatePipeline/go"
)

func TestValues(t *testing.T) {
	tests := []struct {
		name      string
		dims      []float64
		area      float64
		perimeter float64
	}{
		{"circle", []float64{2}, 4 * math.Pi, 4 * math.Pi},
		{"rectangle", []float64{2, 3}, 6, 10},
		{"square", []float64{3}, 9, 12},
		{"triangle", []float64{3, 4, 5}, 6, 12},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			s, err := shapes.New(tt.name, tt.dims...)
			if err != nil {
				t.Fatalf("New returned an error: %v", err)
			}
			if s.Name() != tt.name {
				t.Errorf("Name = %q, want %q", s.Name(), tt.name)
			}
			if math.Abs(s.Area()-tt.area) > 1e-9 {
				t.Errorf("Area = %v, want %v", s.Area(), tt.area)
			}
			if math.Abs(s.Perimeter()-tt.perimeter) > 1e-9 {
				t.Errorf("Perimeter = %v, want %v", s.Perimeter(), tt.perimeter)
			}
		})
	}
}

func TestBadDimensions(t *testing.T) {
	bad := []float64{0, -1, math.Inf(1), math.Inf(-1), math.NaN()}
	for _, d := range bad {
		t.Run(fmt.Sprint(d), func(t *testing.T) {
			for _, name := range []string{"circle", "square"} {
				if _, err := shapes.New(name, d); !errors.Is(err, shapes.ErrNotPositive) {
					t.Errorf("%s: err = %v, want ErrNotPositive", name, err)
				}
			}
			if _, err := shapes.New("rectangle", 1, d); !errors.Is(err, shapes.ErrNotPositive) {
				t.Errorf("rectangle: err = %v, want ErrNotPositive", err)
			}
			if _, err := shapes.New("triangle", 3, 4, d); !errors.Is(err, shapes.ErrNotPositive) {
				t.Errorf("triangle: err = %v, want ErrNotPositive", err)
			}
		})
	}
}

func TestTriangleInequality(t *testing.T) {
	tests := [][]float64{{1, 1, 5}, {1, 2, 3}, {5, 1, 1}, {1, 5, 1}}
	for _, dims := range tests {
		if _, err := shapes.New("triangle", dims...); !errors.Is(err, shapes.ErrNotTriangle) {
			t.Errorf("%v: err = %v, want ErrNotTriangle", dims, err)
		}
	}
}

func TestUnknownShape(t *testing.T) {
	_, err := shapes.New("hexagon", 1)
	if !errors.Is(err, shapes.ErrUnknownShape) {
		t.Fatalf("err = %v, want ErrUnknownShape", err)
	}
	if got, want := err.Error(), "unknown shape 'hexagon'"; got != want {
		t.Errorf("message = %q, want %q", got, want)
	}
}

func TestDimensionCount(t *testing.T) {
	_, err := shapes.New("rectangle", 1)
	if !errors.Is(err, shapes.ErrDimensionCount) {
		t.Fatalf("err = %v, want ErrDimensionCount", err)
	}
	if got, want := err.Error(), "rectangle needs 2 dimension(s): width height"; got != want {
		t.Errorf("message = %q, want %q", got, want)
	}
}

func ExampleNew() {
	s, err := shapes.New("triangle", 3, 4, 5)
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Printf("%s: area = %.6f, perimeter = %.6f\n", s.Name(), s.Area(), s.Perimeter())
	// Output: triangle: area = 6.000000, perimeter = 12.000000
}

func ExampleNewCircle() {
	c, _ := shapes.NewCircle(2)
	fmt.Printf("%.6f\n", c.Area())
	// Output: 12.566371
}
