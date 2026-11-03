#include "shapes.h"

#include <math.h>
#include <string.h>

static const double PI = 3.14159265358979323846;

typedef struct kind_info {
    const char *name;
    size_t ndims;
    const char *dim_names[SHAPES_MAX_DIMS];
} kind_info;

static const kind_info KINDS[SHAPE_KIND_COUNT] = {
    [SHAPE_CIRCLE] = {"circle", 1, {"radius"}},
    [SHAPE_RECTANGLE] = {"rectangle", 2, {"width", "height"}},
    [SHAPE_SQUARE] = {"square", 1, {"side"}},
    [SHAPE_TRIANGLE] = {"triangle", 3, {"a", "b", "c"}},
};

static int valid_kind(shape_kind kind) {
    return (unsigned)kind < SHAPE_KIND_COUNT;
}

shape_status shape_kind_parse(const char *name, shape_kind *kind) {
    for (int k = 0; k < SHAPE_KIND_COUNT; ++k) {
        if (strcmp(name, KINDS[k].name) == 0) {
            *kind = (shape_kind)k;
            return SHAPE_OK;
        }
    }
    return SHAPE_ERR_UNKNOWN;
}

const char *shape_kind_name(shape_kind kind) {
    return valid_kind(kind) ? KINDS[kind].name : NULL;
}

size_t shape_kind_ndims(shape_kind kind) {
    return valid_kind(kind) ? KINDS[kind].ndims : 0;
}

const char *shape_kind_dim_name(shape_kind kind, size_t i) {
    return valid_kind(kind) && i < KINDS[kind].ndims ? KINDS[kind].dim_names[i] : NULL;
}

shape_status shape_init(shape *s, shape_kind kind, const double *dims, size_t ndims) {
    if (!valid_kind(kind)) {
        return SHAPE_ERR_UNKNOWN;
    }
    if (ndims != KINDS[kind].ndims) {
        return SHAPE_ERR_ARITY;
    }
    for (size_t i = 0; i < ndims; ++i) {
        if (!(dims[i] > 0.0) || !isfinite(dims[i])) {
            return SHAPE_ERR_NOT_POSITIVE;
        }
    }
    if (kind == SHAPE_TRIANGLE) {
        const double a = dims[0], b = dims[1], c = dims[2];
        if (a + b <= c || a + c <= b || b + c <= a) {
            return SHAPE_ERR_NOT_TRIANGLE;
        }
    }
    s->kind = kind;
    memset(s->dims, 0, sizeof s->dims);
    memcpy(s->dims, dims, ndims * sizeof *dims);
    return SHAPE_OK;
}

double shape_area(const shape *s) {
    const double *d = s->dims;
    switch (s->kind) {
    case SHAPE_CIRCLE:
        return PI * d[0] * d[0];
    case SHAPE_RECTANGLE:
        return d[0] * d[1];
    case SHAPE_SQUARE:
        return d[0] * d[0];
    case SHAPE_TRIANGLE: {
        const double p = (d[0] + d[1] + d[2]) / 2.0;
        return sqrt(p * (p - d[0]) * (p - d[1]) * (p - d[2]));
    }
    default:
        return NAN;
    }
}

double shape_perimeter(const shape *s) {
    const double *d = s->dims;
    switch (s->kind) {
    case SHAPE_CIRCLE:
        return 2.0 * PI * d[0];
    case SHAPE_RECTANGLE:
        return 2.0 * (d[0] + d[1]);
    case SHAPE_SQUARE:
        return 4.0 * d[0];
    case SHAPE_TRIANGLE:
        return d[0] + d[1] + d[2];
    default:
        return NAN;
    }
}

const char *shape_status_message(shape_status status) {
    switch (status) {
    case SHAPE_OK:
        return "no error";
    case SHAPE_ERR_UNKNOWN:
        return "unknown shape";
    case SHAPE_ERR_ARITY:
        return "wrong number of dimensions";
    case SHAPE_ERR_NOT_POSITIVE:
        return "dimensions must be positive numbers";
    case SHAPE_ERR_NOT_TRIANGLE:
        return "sides do not form a triangle";
    }
    return "unknown error";
}
