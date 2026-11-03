/**
 * @file shapes.h
 * @brief Area and perimeter of simple plane shapes.
 *
 * Make a shape with shape_init(), then ask for its area with shape_area()
 * and its perimeter with shape_perimeter().
 *
 * @code
 * shape s;
 * const double dims[] = {2.0};
 * if (shape_init(&s, SHAPE_CIRCLE, dims, 1) == SHAPE_OK) {
 *     printf("%f\n", shape_area(&s));
 * }
 * @endcode
 */
#ifndef SHAPES_H
#define SHAPES_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/** @brief The largest number of dimensions that a shape has. */
#define SHAPES_MAX_DIMS 3

/** @brief The kinds of shape. */
typedef enum shape_kind {
    SHAPE_CIRCLE,    /**< One dimension: radius. */
    SHAPE_RECTANGLE, /**< Two dimensions: width, height. */
    SHAPE_SQUARE,    /**< One dimension: side. */
    SHAPE_TRIANGLE,  /**< Three dimensions: the sides a, b, c. */
    SHAPE_KIND_COUNT /**< The number of kinds. Not a shape. */
} shape_kind;

/** @brief The result of a library call. */
typedef enum shape_status {
    SHAPE_OK = 0,           /**< No error. */
    SHAPE_ERR_UNKNOWN,      /**< The name or the kind is not a known shape. */
    SHAPE_ERR_ARITY,        /**< The number of dimensions is wrong. */
    SHAPE_ERR_NOT_POSITIVE, /**< A dimension is not a positive finite number. */
    SHAPE_ERR_NOT_TRIANGLE  /**< The sides do not form a triangle. */
} shape_status;

/** @brief A shape and its dimensions. Make it with shape_init(). */
typedef struct shape {
    shape_kind kind;               /**< The kind of shape. */
    double dims[SHAPES_MAX_DIMS];  /**< The dimensions. Unused entries are 0. */
} shape;

/**
 * @brief Finds the kind of shape that has the name @p name.
 * @param name  A shape name, for example "circle".
 * @param kind  On success, receives the kind.
 * @return SHAPE_OK, or SHAPE_ERR_UNKNOWN if the name is not known.
 */
shape_status shape_kind_parse(const char *name, shape_kind *kind);

/** @brief Returns the name of @p kind, or NULL if the kind is not valid. */
const char *shape_kind_name(shape_kind kind);

/** @brief Returns the number of dimensions of @p kind, or 0 if the kind is not valid. */
size_t shape_kind_ndims(shape_kind kind);

/** @brief Returns the name of dimension @p i of @p kind, or NULL if it does not exist. */
const char *shape_kind_dim_name(shape_kind kind, size_t i);

/**
 * @brief Makes a shape and checks its dimensions.
 * @param s      The shape to fill.
 * @param kind   The kind of shape.
 * @param dims   The dimensions, in the order of shape_kind_dim_name().
 * @param ndims  The number of values in @p dims.
 * @return SHAPE_OK, or the error. On error, @p s does not change.
 */
shape_status shape_init(shape *s, shape_kind kind, const double *dims, size_t ndims);

/** @brief Returns the area of @p s. */
double shape_area(const shape *s);

/** @brief Returns the perimeter of @p s. */
double shape_perimeter(const shape *s);

/** @brief Returns a message in English for @p status. */
const char *shape_status_message(shape_status status);

#ifdef __cplusplus
}
#endif

#endif /* SHAPES_H */
