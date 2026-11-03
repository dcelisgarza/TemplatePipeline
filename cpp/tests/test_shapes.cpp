#include <shapes/shapes.hpp>

#include <gtest/gtest.h>

#include <cmath>
#include <limits>

using namespace shapes;

namespace {
constexpr double kPi = 3.14159265358979323846;
}

TEST(Values, Circle) {
    Circle c(2.0);
    EXPECT_NEAR(c.area(), 4.0 * kPi, 1e-9);
    EXPECT_NEAR(c.perimeter(), 4.0 * kPi, 1e-9);
    EXPECT_EQ(c.name(), "circle");
}

TEST(Values, Rectangle) {
    Rectangle r(2.0, 3.0);
    EXPECT_NEAR(r.area(), 6.0, 1e-9);
    EXPECT_NEAR(r.perimeter(), 10.0, 1e-9);
    EXPECT_EQ(r.name(), "rectangle");
}

TEST(Values, Square) {
    Square s(3.0);
    EXPECT_NEAR(s.area(), 9.0, 1e-9);
    EXPECT_NEAR(s.perimeter(), 12.0, 1e-9);
    EXPECT_EQ(s.name(), "square");
}

TEST(Values, Triangle) {
    Triangle t(3.0, 4.0, 5.0);
    EXPECT_NEAR(t.area(), 6.0, 1e-9);
    EXPECT_NEAR(t.perimeter(), 12.0, 1e-9);
    EXPECT_EQ(t.name(), "triangle");
}

TEST(Validation, RejectsNonPositive) {
    EXPECT_THROW((Circle{0.0}), std::invalid_argument);
    EXPECT_THROW((Circle{-1.0}), std::invalid_argument);
    EXPECT_THROW((Rectangle{2.0, 0.0}), std::invalid_argument);
    EXPECT_THROW((Square{-3.0}), std::invalid_argument);
    EXPECT_THROW((Triangle{3.0, 4.0, -5.0}), std::invalid_argument);
}

TEST(Validation, RejectsInfAndNan) {
    const double inf = std::numeric_limits<double>::infinity();
    const double nan = std::numeric_limits<double>::quiet_NaN();
    EXPECT_THROW((Circle{inf}), std::invalid_argument);
    EXPECT_THROW((Circle{nan}), std::invalid_argument);
    EXPECT_THROW((Rectangle{1.0, inf}), std::invalid_argument);
    EXPECT_THROW((Square{nan}), std::invalid_argument);
    EXPECT_THROW((Triangle{3.0, 4.0, nan}), std::invalid_argument);
}

TEST(Validation, MessageForNonPositive) {
    try {
        Circle c(-1.0);
        FAIL() << "no exception";
    } catch (const std::invalid_argument& e) {
        EXPECT_STREQ(e.what(), "dimensions must be positive numbers");
    }
}

TEST(Validation, TriangleInequality) {
    EXPECT_THROW((Triangle{1.0, 1.0, 5.0}), std::invalid_argument);
    EXPECT_THROW((Triangle{1.0, 2.0, 3.0}), std::invalid_argument);  // strict: degenerate
    EXPECT_THROW((Triangle{5.0, 1.0, 1.0}), std::invalid_argument);
    EXPECT_NO_THROW((Triangle{2.0, 2.0, 3.0}));
    try {
        Triangle t(1.0, 1.0, 5.0);
        FAIL() << "no exception";
    } catch (const std::invalid_argument& e) {
        EXPECT_STREQ(e.what(), "sides do not form a triangle");
    }
}

TEST(Factory, MakesShapes) {
    EXPECT_EQ(make_shape("circle", {2.0})->name(), "circle");
    EXPECT_NEAR(make_shape("rectangle", {2.0, 3.0})->area(), 6.0, 1e-9);
    EXPECT_NEAR(make_shape("square", {3.0})->perimeter(), 12.0, 1e-9);
    EXPECT_NEAR(make_shape("triangle", {3.0, 4.0, 5.0})->area(), 6.0, 1e-9);
}

TEST(Factory, UnknownName) {
    EXPECT_THROW(make_shape("hexagon", {1.0}), UnknownShapeError);
    EXPECT_THROW(make_shape("hexagon", {1.0}), std::invalid_argument);
    try {
        make_shape("hexagon", {1.0});
        FAIL() << "no exception";
    } catch (const UnknownShapeError& e) {
        EXPECT_STREQ(e.what(), "unknown shape 'hexagon'");
    }
}

TEST(Factory, WrongArity) {
    try {
        make_shape("rectangle", {2.0});
        FAIL() << "no exception";
    } catch (const std::invalid_argument& e) {
        EXPECT_STREQ(e.what(), "rectangle needs 2 dimension(s): width height");
    }
}

TEST(Factory, DimensionNames) {
    EXPECT_EQ(dimension_names("triangle"), (std::vector<std::string>{"a", "b", "c"}));
    EXPECT_EQ(shape_names().size(), 4u);
}
