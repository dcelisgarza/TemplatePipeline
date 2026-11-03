/* shapes-c: print the area and perimeter of a plane shape. See SPEC.md. */
#include <shapes.h>

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef SHAPES_VERSION
#define SHAPES_VERSION "unknown"
#endif

static const char USAGE[] =
    "Usage: shapes-c [SHAPE DIMENSION...]\n"
    "\n"
    "Print the area and perimeter of a plane shape.\n"
    "\n"
    "Shapes and their dimensions:\n"
    "  circle     RADIUS\n"
    "  rectangle  WIDTH HEIGHT\n"
    "  square     SIDE\n"
    "  triangle   A B C\n"
    "\n"
    "Without arguments, shapes-c asks for the shape and its dimensions.\n"
    "\n"
    "Options:\n"
    "  -h, --help     Print this help and exit.\n"
    "  -V, --version  Print the version and exit.\n";

static const char SHAPE_PROMPT[] = "shape (circle, rectangle, square, triangle; q to quit): ";

static int parse_number(const char *text, double *out) {
    char *end;
    errno = 0;
    const double value = strtod(text, &end);
    if (end == text || *end != '\0' || errno == ERANGE) {
        return 0;
    }
    *out = value;
    return 1;
}

/* Makes a shape from text arguments. Prints the error and returns 0 on failure. */
static int make_shape(const char *name, char *const *args, size_t nargs, shape *out) {
    shape_kind kind;
    if (shape_kind_parse(name, &kind) != SHAPE_OK) {
        fprintf(stderr, "error: unknown shape '%s'\n", name);
        return 0;
    }
    const size_t n = shape_kind_ndims(kind);
    if (nargs != n) {
        fprintf(stderr, "error: %s needs %zu dimension(s):", name, n);
        for (size_t i = 0; i < n; ++i) {
            fprintf(stderr, " %s", shape_kind_dim_name(kind, i));
        }
        fputc('\n', stderr);
        return 0;
    }
    double dims[SHAPES_MAX_DIMS];
    for (size_t i = 0; i < n; ++i) {
        if (!parse_number(args[i], &dims[i])) {
            fprintf(stderr, "error: '%s' is not a number\n", args[i]);
            return 0;
        }
    }
    const shape_status status = shape_init(out, kind, dims, n);
    if (status != SHAPE_OK) {
        fprintf(stderr, "error: %s\n", shape_status_message(status));
        return 0;
    }
    return 1;
}

static void print_shape(const shape *s) {
    printf("%s: area = %.6f, perimeter = %.6f\n", shape_kind_name(s->kind), shape_area(s),
           shape_perimeter(s));
}

/* Prints the prompt and reads one line without the spaces at its ends. Returns 0 at end of input. */
static int ask(const char *prompt, char *buf, size_t size) {
    fputs(prompt, stdout);
    fflush(stdout);
    if (fgets(buf, (int)size, stdin) == NULL) {
        return 0;
    }
    size_t end = strlen(buf);
    while (end > 0 && isspace((unsigned char)buf[end - 1])) {
        buf[--end] = '\0';
    }
    size_t start = 0;
    while (isspace((unsigned char)buf[start])) {
        ++start;
    }
    memmove(buf, buf + start, end - start + 1);
    return 1;
}

static int interactive(void) {
    char name[128];
    char answers[SHAPES_MAX_DIMS][128];
    char *args[SHAPES_MAX_DIMS];
    char prompt[64];
    for (;;) {
        if (!ask(SHAPE_PROMPT, name, sizeof name)) {
            putchar('\n');
            return 0;
        }
        if (name[0] == '\0') {
            continue;
        }
        if (strcmp(name, "q") == 0 || strcmp(name, "quit") == 0) {
            return 0;
        }
        shape_kind kind;
        if (shape_kind_parse(name, &kind) != SHAPE_OK) {
            fprintf(stderr, "error: unknown shape '%s'\n", name);
            continue;
        }
        const size_t n = shape_kind_ndims(kind);
        for (size_t i = 0; i < n; ++i) {
            snprintf(prompt, sizeof prompt, "  %s: ", shape_kind_dim_name(kind, i));
            if (!ask(prompt, answers[i], sizeof answers[i])) {
                putchar('\n');
                return 0;
            }
            args[i] = answers[i];
        }
        shape s;
        if (make_shape(name, args, n, &s)) {
            print_shape(&s);
        }
    }
}

int main(int argc, char **argv) {
    if (argc == 1) {
        return interactive();
    }
    if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0) {
        fputs(USAGE, stdout);
        return 0;
    }
    if (strcmp(argv[1], "-V") == 0 || strcmp(argv[1], "--version") == 0) {
        printf("shapes-c %s\n", SHAPES_VERSION);
        return 0;
    }
    shape s;
    if (!make_shape(argv[1], argv + 2, (size_t)(argc - 2), &s)) {
        return 1;
    }
    print_shape(&s);
    return 0;
}
