// Command shapes-go prints the area and perimeter of a plane shape.
//
// Run it without arguments to answer prompts instead. See SPEC.md.
package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"

	shapes "github.com/OWNER/TemplatePipeline/go"
)

// version is set at build time: -ldflags "-X main.version=0.1.0".
var version = "dev"

const usage = `Usage: shapes-go [SHAPE DIMENSION...]

Print the area and perimeter of a plane shape.

Shapes and their dimensions:
  circle     RADIUS
  rectangle  WIDTH HEIGHT
  square     SIDE
  triangle   A B C

Without arguments, shapes-go asks for the shape and its dimensions.

Options:
  -h, --help     Print this help and exit.
  -V, --version  Print the version and exit.
`

const shapePrompt = "shape (circle, rectangle, square, triangle; q to quit): "

func main() {
	os.Exit(run(os.Args[1:], os.Stdin, os.Stdout, os.Stderr))
}

// run executes the program and returns the exit status.
func run(args []string, stdin io.Reader, stdout, stderr io.Writer) int {
	if len(args) == 0 {
		return interactive(stdin, stdout, stderr)
	}
	switch args[0] {
	case "-h", "--help":
		fmt.Fprint(stdout, usage)
		return 0
	case "-V", "--version":
		fmt.Fprintf(stdout, "shapes-go %s\n", version)
		return 0
	}
	s, err := makeShape(args[0], args[1:])
	if err != nil {
		fmt.Fprintf(stderr, "error: %v\n", err)
		return 1
	}
	fmt.Fprint(stdout, describe(s))
	return 0
}

func describe(s shapes.Shape) string {
	return fmt.Sprintf("%s: area = %.6f, perimeter = %.6f\n", s.Name(), s.Area(), s.Perimeter())
}

// makeShape builds a shape from text arguments.
func makeShape(name string, args []string) (shapes.Shape, error) {
	names, ok := shapes.DimensionNames(name)
	if !ok {
		return shapes.New(name) // returns the unknown shape error
	}
	if len(args) != len(names) {
		return shapes.New(name, make([]float64, len(args))...) // returns the count error
	}
	dims := make([]float64, len(args))
	for i, arg := range args {
		v, err := strconv.ParseFloat(arg, 64)
		if err != nil {
			return nil, fmt.Errorf("'%s' is not a number", arg)
		}
		dims[i] = v
	}
	return shapes.New(name, dims...)
}

// ask prints the prompt and reads one line without the spaces at its ends.
// The second result is false at the end of the input.
func ask(prompt string, in *bufio.Reader, out io.Writer) (string, bool) {
	fmt.Fprint(out, prompt)
	line, err := in.ReadString('\n')
	if err != nil && (!errors.Is(err, io.EOF) || line == "") {
		return "", false
	}
	return strings.TrimSpace(line), true
}

func interactive(stdin io.Reader, stdout, stderr io.Writer) int {
	in := bufio.NewReader(stdin)
	for {
		name, ok := ask(shapePrompt, in, stdout)
		if !ok {
			fmt.Fprintln(stdout)
			return 0
		}
		if name == "" {
			continue
		}
		if name == "q" || name == "quit" {
			return 0
		}
		names, known := shapes.DimensionNames(name)
		if !known {
			fmt.Fprintf(stderr, "error: unknown shape '%s'\n", name)
			continue
		}
		answers := make([]string, 0, len(names))
		for _, dim := range names {
			answer, ok := ask("  "+dim+": ", in, stdout)
			if !ok {
				fmt.Fprintln(stdout)
				return 0
			}
			answers = append(answers, answer)
		}
		s, err := makeShape(name, answers)
		if err != nil {
			fmt.Fprintf(stderr, "error: %v\n", err)
			continue
		}
		fmt.Fprint(stdout, describe(s))
	}
}
