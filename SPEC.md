# The `shapes` program

Each language directory contains the same small program. Each program has two parts:

1. A **library** with the shapes and two operations: area and perimeter.
2. A **command-line program** `shapes-<lang>` that uses the library.

The behaviour below is the same for all languages. The shared smoke test in
`scripts/lib.sh` checks it after each install.

## Library

| Shape       | Dimensions          | Area                       | Perimeter     |
| ----------- | ------------------- | -------------------------- | ------------- |
| `circle`    | `radius`            | π r²                       | 2 π r         |
| `rectangle` | `width`, `height`   | w h                        | 2 (w + h)     |
| `square`    | `side`              | s²                         | 4 s           |
| `triangle`  | `a`, `b`, `c`       | Heron: √(p(p−a)(p−b)(p−c)) | a + b + c     |

Rules for the dimensions:

- Each dimension must be a finite number that is more than zero.
- The sides of a triangle must obey the strict triangle inequality.

The library rejects bad dimensions with the error type that is usual for the language
(a status code, an exception, a `Result`, and so on).

## Command line

```text
Usage: shapes-<lang> [SHAPE DIMENSION...]

Print the area and perimeter of a plane shape.

Shapes and their dimensions:
  circle     RADIUS
  rectangle  WIDTH HEIGHT
  square     SIDE
  triangle   A B C

Without arguments, shapes-<lang> asks for the shape and its dimensions.

Options:
  -h, --help     Print this help and exit.
  -V, --version  Print the version and exit.
```

### Output

One line on standard output, with six decimals:

```text
$ shapes-<lang> circle 2
circle: area = 12.566371, perimeter = 12.566371
```

`--version` prints `shapes-<lang> <version>`, for example `shapes-c 0.1.0`.

### Errors

Errors go to standard error with the prefix `error: `. The exit status is 1.

| Condition                     | Message                                          |
| ----------------------------- | ------------------------------------------------ |
| Unknown shape                 | `error: unknown shape 'hexagon'`                 |
| Wrong number of dimensions    | `error: rectangle needs 2 dimension(s): width height` |
| A dimension is not a number   | `error: 'abc' is not a number`                   |
| A dimension is not positive   | `error: dimensions must be positive numbers`     |
| Not a triangle                | `error: sides do not form a triangle`            |

A number that is too large for a 64-bit float, for example `1e400`, gives one of two
messages: `is not a number` or `dimensions must be positive numbers`. The message depends
on the number parser of the language. The exit status is 1 in both cases.

### Interactive mode

Without arguments, the program asks for a shape, then for each dimension:

```text
shape (circle, rectangle, square, triangle; q to quit): rectangle
  width: 2
  height: 3
rectangle: area = 6.000000, perimeter = 10.000000
shape (circle, rectangle, square, triangle; q to quit): q
```

- The prompts go to standard output without a newline.
- The program removes the spaces at the start and the end of each answer.
- An empty answer to the shape prompt shows the prompt again.
- `q`, `quit` or the end of the input (Ctrl-D) stops the program with exit status 0.
- After an error, the program writes the error message and asks for a new shape.
