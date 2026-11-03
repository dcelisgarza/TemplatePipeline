/* Unit tests for the shapes library. CTest runs this program; a non-zero exit is a failure. */
#include <shapes.h>

#include <math.h>
#include <stdio.h>

static int failures = 0;

#define CHECK(cond)                                                                    \
    do {                                                                               \
        if (!(cond)) {                                                                 \
            fprintf(stderr, "%s:%d: CHECK failed: %s\n", __FILE__, __LINE__, #cond); \
            ++failures;                                                                \
        }                                                                              \
    } while (0)

#define CHECK_CLOSE(a, b) CHECK(fabs((a) - (b)) < 1e-9)

static void test_values(void) {
    shape s;
    CHECK(shape_init(&s, SHAPE_CIRCLE, (double[]){2.0}, 1) == SHAPE_OK);
    CHECK_CLOSE(shape_area(&s), 4.0 * 3.14159265358979323846);
    CHECK_CLOSE(shape_perimeter(&s), 4.0 * 3.14159265358979323846);

    CHECK(shape_init(&s, SHAPE_RECTANGLE, (double[]){2.0, 3.0}, 2) == SHAPE_OK);
    CHECK_CLOSE(shape_area(&s), 6.0);
    CHECK_CLOSE(shape_perimeter(&s), 10.0);

    CHECK(shape_init(&s, SHAPE_SQUARE, (double[]){3.0}, 1) == SHAPE_OK);
    CHECK_CLOSE(shape_area(&s), 9.0);
    CHECK_CLOSE(shape_perimeter(&s), 12.0);

    CHECK(shape_init(&s, SHAPE_TRIANGLE, (double[]){3.0, 4.0, 5.0}, 3) == SHAPE_OK);
    CHECK_CLOSE(shape_area(&s), 6.0);
    CHECK_CLOSE(shape_perimeter(&s), 12.0);
}

static void test_errors(void) {
    shape s;
    CHECK(shape_init(&s, SHAPE_CIRCLE, (double[]){0.0}, 1) == SHAPE_ERR_NOT_POSITIVE);
    CHECK(shape_init(&s, SHAPE_SQUARE, (double[]){-1.0}, 1) == SHAPE_ERR_NOT_POSITIVE);
    CHECK(shape_init(&s, SHAPE_SQUARE, (double[]){INFINITY}, 1) == SHAPE_ERR_NOT_POSITIVE);
    CHECK(shape_init(&s, SHAPE_SQUARE, (double[]){NAN}, 1) == SHAPE_ERR_NOT_POSITIVE);
    CHECK(shape_init(&s, SHAPE_RECTANGLE, (double[]){1.0}, 1) == SHAPE_ERR_ARITY);
    CHECK(shape_init(&s, SHAPE_TRIANGLE, (double[]){1.0, 1.0, 5.0}, 3) == SHAPE_ERR_NOT_TRIANGLE);
    CHECK(shape_init(&s, SHAPE_TRIANGLE, (double[]){1.0, 2.0, 3.0}, 3) == SHAPE_ERR_NOT_TRIANGLE);
}

static void test_names(void) {
    shape_kind kind;
    CHECK(shape_kind_parse("triangle", &kind) == SHAPE_OK && kind == SHAPE_TRIANGLE);
    CHECK(shape_kind_parse("hexagon", &kind) == SHAPE_ERR_UNKNOWN);
    CHECK(shape_kind_ndims(SHAPE_RECTANGLE) == 2);
    CHECK(shape_kind_dim_name(SHAPE_RECTANGLE, 1) != NULL);
    CHECK(shape_kind_dim_name(SHAPE_RECTANGLE, 2) == NULL);
}

int main(void) {
    test_values();
    test_errors();
    test_names();
    if (failures == 0) {
        puts("all tests passed");
    }
    return failures == 0 ? 0 : 1;
}
