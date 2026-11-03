#include <shapes/shapes.hpp>

#include <cmath>
#include <map>
#include <utility>

namespace shapes {

namespace {

constexpr double kPi = 3.14159265358979323846;

void require_positive(double value) {
    if (!(value > 0.0) || !std::isfinite(value)) {
        throw std::invalid_argument("dimensions must be positive numbers");
    }
}

}  // namespace

UnknownShapeError::UnknownShapeError(const std::string& name)
    : std::invalid_argument("unknown shape '" + name + "'") {}

Circle::Circle(double radius) : radius_(radius) { require_positive(radius); }
double Circle::area() const { return kPi * radius_ * radius_; }
double Circle::perimeter() const { return 2.0 * kPi * radius_; }
std::string Circle::name() const { return "circle"; }

Rectangle::Rectangle(double width, double height) : width_(width), height_(height) {
    require_positive(width);
    require_positive(height);
}
double Rectangle::area() const { return width_ * height_; }
double Rectangle::perimeter() const { return 2.0 * (width_ + height_); }
std::string Rectangle::name() const { return "rectangle"; }

Square::Square(double side) : side_(side) { require_positive(side); }
double Square::area() const { return side_ * side_; }
double Square::perimeter() const { return 4.0 * side_; }
std::string Square::name() const { return "square"; }

Triangle::Triangle(double a, double b, double c) : a_(a), b_(b), c_(c) {
    require_positive(a);
    require_positive(b);
    require_positive(c);
    if (a + b <= c || a + c <= b || b + c <= a) {
        throw std::invalid_argument("sides do not form a triangle");
    }
}
double Triangle::area() const {
    const double p = (a_ + b_ + c_) / 2.0;
    return std::sqrt(p * (p - a_) * (p - b_) * (p - c_));
}
double Triangle::perimeter() const { return a_ + b_ + c_; }
std::string Triangle::name() const { return "triangle"; }

const std::vector<std::string>& shape_names() {
    static const std::vector<std::string> names{"circle", "rectangle", "square", "triangle"};
    return names;
}

const std::vector<std::string>& dimension_names(const std::string& shape) {
    static const std::map<std::string, std::vector<std::string>> table{
        {"circle", {"radius"}},
        {"rectangle", {"width", "height"}},
        {"square", {"side"}},
        {"triangle", {"a", "b", "c"}},
    };
    const auto it = table.find(shape);
    if (it == table.end()) {
        throw UnknownShapeError(shape);
    }
    return it->second;
}

std::unique_ptr<Shape> make_shape(const std::string& shape, const std::vector<double>& dims) {
    const auto& names = dimension_names(shape);
    if (dims.size() != names.size()) {
        std::string message = shape + " needs " + std::to_string(names.size()) + " dimension(s):";
        for (const auto& n : names) {
            message += " " + n;
        }
        throw std::invalid_argument(message);
    }
    if (shape == "circle") return std::make_unique<Circle>(dims[0]);
    if (shape == "rectangle") return std::make_unique<Rectangle>(dims[0], dims[1]);
    if (shape == "square") return std::make_unique<Square>(dims[0]);
    return std::make_unique<Triangle>(dims[0], dims[1], dims[2]);
}

}  // namespace shapes
