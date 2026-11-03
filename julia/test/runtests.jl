using Test
using Shapes

@testset "Shapes" begin
    @testset "values" begin
        @test area(Circle(2)) ≈ 4pi
        @test perimeter(Circle(2)) ≈ 4pi
        @test area(Rectangle(2, 3)) == 6
        @test perimeter(Rectangle(2, 3)) == 10
        @test area(Square(3)) == 9
        @test perimeter(Square(3)) == 12
        @test area(Triangle(3, 4, 5)) ≈ 6
        @test perimeter(Triangle(3, 4, 5)) == 12
    end

    @testset "bad dimensions" begin
        for bad in (0, -1, Inf, -Inf, NaN)
            @test_throws ShapeError Circle(bad)
            @test_throws ShapeError Rectangle(bad, 1)
            @test_throws ShapeError Rectangle(1, bad)
            @test_throws ShapeError Square(bad)
            @test_throws ShapeError Triangle(bad, 1, 1)
            e = try Circle(bad) catch err err end
            @test e.kind == :not_positive
            @test e.message == "dimensions must be positive numbers"
        end
    end

    @testset "triangle inequality" begin
        for sides in ((1, 1, 5), (1, 2, 3), (5, 1, 1), (1, 5, 1))
            e = try Triangle(sides...) catch err err end
            @test e isa ShapeError
            @test e.kind == :not_a_triangle
            @test e.message == "sides do not form a triangle"
        end
    end

    @testset "shape by name" begin
        @test shape("square", [3.0]) == Square(3)
        @test area(shape("triangle", [3, 4, 5])) ≈ 6
        e = try shape("hexagon", [1.0]) catch err err end
        @test e isa ShapeError
        @test e.kind == :unknown_shape
        @test e.message == "unknown shape 'hexagon'"
        e = try shape("rectangle", [1.0]) catch err err end
        @test e.message == "rectangle needs 2 dimension(s): width height"
    end

    @testset "command line" begin
        @test Shapes.compute("circle", ["2"]) ==
              "circle: area = 12.566371, perimeter = 12.566371"
        @test Shapes.compute("rectangle", ["2", "3"]) ==
              "rectangle: area = 6.000000, perimeter = 10.000000"
        e = try Shapes.compute("circle", ["abc"]) catch err err end
        @test e.message == "'abc' is not a number"
    end
end
