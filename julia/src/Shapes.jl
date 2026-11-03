"""
    Shapes

Plane shapes with area and perimeter.

```julia
using Shapes

area(Triangle(3, 4, 5))    # 6.0
perimeter(Square(3))       # 12.0
shape("circle", [2.0])     # Circle(2.0)
```

Bad dimensions throw a [`ShapeError`](@ref).
"""
module Shapes

using Printf: @sprintf

export Shape, Circle, Rectangle, Square, Triangle, ShapeError
export area, perimeter, shape, SHAPE_NAMES, dimension_names

"""
    ShapeError(kind, message)

Thrown when a shape cannot be built. `kind` is one of `:unknown_shape`,
`:wrong_count`, `:not_positive` and `:not_a_triangle`.
"""
struct ShapeError <: Exception
    kind::Symbol
    message::String
end

Base.showerror(io::IO, e::ShapeError) = print(io, "ShapeError: ", e.message)

"""
    Shape

Abstract supertype of all shapes. Each shape has methods for [`area`](@ref)
and [`perimeter`](@ref).
"""
abstract type Shape end

function check(dims...)
    all(d -> isfinite(d) && d > 0, dims) ||
        throw(ShapeError(:not_positive, "dimensions must be positive numbers"))
    return nothing
end

"""
    Circle(radius)

A circle. The radius must be finite and more than zero.
"""
struct Circle <: Shape
    radius::Float64
    function Circle(radius::Real)
        check(radius)
        return new(radius)
    end
end

"""
    Rectangle(width, height)

A rectangle. Both sides must be finite and more than zero.
"""
struct Rectangle <: Shape
    width::Float64
    height::Float64
    function Rectangle(width::Real, height::Real)
        check(width, height)
        return new(width, height)
    end
end

"""
    Square(side)

A square. The side must be finite and more than zero.
"""
struct Square <: Shape
    side::Float64
    function Square(side::Real)
        check(side)
        return new(side)
    end
end

"""
    Triangle(a, b, c)

A triangle with sides `a`, `b` and `c`. The sides must be finite, more than
zero, and obey the strict triangle inequality.
"""
struct Triangle <: Shape
    a::Float64
    b::Float64
    c::Float64
    function Triangle(a::Real, b::Real, c::Real)
        check(a, b, c)
        (a + b > c && a + c > b && b + c > a) ||
            throw(ShapeError(:not_a_triangle, "sides do not form a triangle"))
        return new(a, b, c)
    end
end

"""
    area(shape)

The area of `shape`.

```jldoctest
julia> using Shapes

julia> area(Rectangle(2, 3))
6.0
```
"""
function area end

"""
    perimeter(shape)

The perimeter of `shape`.

```jldoctest
julia> using Shapes

julia> perimeter(Square(3))
12.0
```
"""
function perimeter end

area(s::Circle) = pi * s.radius^2
area(s::Rectangle) = s.width * s.height
area(s::Square) = s.side^2
function area(s::Triangle)
    p = perimeter(s) / 2
    return sqrt(p * (p - s.a) * (p - s.b) * (p - s.c))
end

perimeter(s::Circle) = 2pi * s.radius
perimeter(s::Rectangle) = 2 * (s.width + s.height)
perimeter(s::Square) = 4 * s.side
perimeter(s::Triangle) = s.a + s.b + s.c

"The names of all shapes, in the order used by the program."
const SHAPE_NAMES = ("circle", "rectangle", "square", "triangle")

const DIMENSIONS = Dict(
    "circle" => ("radius",),
    "rectangle" => ("width", "height"),
    "square" => ("side",),
    "triangle" => ("a", "b", "c"),
)

const CONSTRUCTORS = Dict(
    "circle" => Circle,
    "rectangle" => Rectangle,
    "square" => Square,
    "triangle" => Triangle,
)

"""
    dimension_names(name)

The dimension names of the shape `name`. Throws a [`ShapeError`](@ref) for an
unknown name.
"""
function dimension_names(name::AbstractString)
    haskey(DIMENSIONS, name) ||
        throw(ShapeError(:unknown_shape, "unknown shape '$name'"))
    return DIMENSIONS[name]
end

"""
    shape(name, dims)

Build the shape `name` from the collection `dims`.

```jldoctest
julia> using Shapes

julia> shape("square", [3.0])
Square(3.0)
```
"""
function shape(name::AbstractString, dims)
    names = dimension_names(name)
    length(dims) == length(names) || throw(ShapeError(
        :wrong_count,
        "$name needs $(length(names)) dimension(s): $(join(names, ' '))",
    ))
    return CONSTRUCTORS[name](dims...)
end

include("cli.jl")

end # module
