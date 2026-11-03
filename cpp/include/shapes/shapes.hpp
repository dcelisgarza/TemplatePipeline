/**
 * @file shapes.hpp
 * @brief Plane shapes with area and perimeter.
 */
#pragma once

#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

/// Plane shapes with area and perimeter.
namespace shapes {

/// Thrown when a shape name is not known.
class UnknownShapeError : public std::invalid_argument {
public:
    /// Makes the error for the given shape name.
    explicit UnknownShapeError(const std::string& name);
};

/// Abstract base class of all shapes.
class Shape {
public:
    virtual ~Shape() = default;

    /// Area of the shape.
    virtual double area() const = 0;
    /// Perimeter of the shape.
    virtual double perimeter() const = 0;
    /// Name of the shape, for example "circle".
    virtual std::string name() const = 0;
};

/// A circle with a radius.
class Circle : public Shape {
public:
    /// @throws std::invalid_argument if the radius is not a finite number above zero.
    explicit Circle(double radius);
    double area() const override;
    double perimeter() const override;
    std::string name() const override;

private:
    double radius_;
};

/// A rectangle with a width and a height.
class Rectangle : public Shape {
public:
    /// @throws std::invalid_argument if a side is not a finite number above zero.
    Rectangle(double width, double height);
    double area() const override;
    double perimeter() const override;
    std::string name() const override;

private:
    double width_;
    double height_;
};

/// A square with one side.
class Square : public Shape {
public:
    /// @throws std::invalid_argument if the side is not a finite number above zero.
    explicit Square(double side);
    double area() const override;
    double perimeter() const override;
    std::string name() const override;

private:
    double side_;
};

/// A triangle with three sides.
class Triangle : public Shape {
public:
    /// @throws std::invalid_argument if a side is not a finite number above zero,
    ///         or if the sides break the strict triangle inequality.
    Triangle(double a, double b, double c);
    double area() const override;
    double perimeter() const override;
    std::string name() const override;

private:
    double a_;
    double b_;
    double c_;
};

/// Names of all shapes, in a fixed order.
const std::vector<std::string>& shape_names();

/// Names of the dimensions of a shape, for example {"width", "height"}.
/// @throws UnknownShapeError if the shape is not known.
const std::vector<std::string>& dimension_names(const std::string& shape);

/// Makes a shape from its name and its dimensions.
/// @throws UnknownShapeError if the shape is not known.
/// @throws std::invalid_argument if the number of dimensions is wrong or a dimension is bad.
std::unique_ptr<Shape> make_shape(const std::string& shape, const std::vector<double>& dims);

}  // namespace shapes
