package main

import (
	"bytes"
	"strings"
	"testing"
)

func TestRun(t *testing.T) {
	tests := []struct {
		name   string
		args   []string
		stdin  string
		code   int
		stdout string
		stderr string
	}{
		{"circle", []string{"circle", "2"}, "", 0, "circle: area = 12.566371, perimeter = 12.566371\n", ""},
		{"version", []string{"--version"}, "", 0, "shapes-go dev\n", ""},
		{"unknown", []string{"hexagon", "1"}, "", 1, "", "error: unknown shape 'hexagon'\n"},
		{"count", []string{"rectangle", "1"}, "", 1, "", "error: rectangle needs 2 dimension(s): width height\n"},
		{"nan text", []string{"square", "abc"}, "", 1, "", "error: 'abc' is not a number\n"},
		{"not positive", []string{"square", "-1"}, "", 1, "", "error: dimensions must be positive numbers\n"},
		{"not triangle", []string{"triangle", "1", "1", "5"}, "", 1, "", "error: sides do not form a triangle\n"},
		{
			"interactive", nil, "square\n 3 \nq\n", 0,
			"shape (circle, rectangle, square, triangle; q to quit):   side: " +
				"square: area = 9.000000, perimeter = 12.000000\n" +
				"shape (circle, rectangle, square, triangle; q to quit): ", "",
		},
		{
			"end of input", nil, "", 0,
			"shape (circle, rectangle, square, triangle; q to quit): \n", "",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var out, errOut bytes.Buffer
			code := run(tt.args, strings.NewReader(tt.stdin), &out, &errOut)
			if code != tt.code || out.String() != tt.stdout || errOut.String() != tt.stderr {
				t.Errorf("got (%d, %q, %q), want (%d, %q, %q)",
					code, out.String(), errOut.String(), tt.code, tt.stdout, tt.stderr)
			}
		})
	}
}
