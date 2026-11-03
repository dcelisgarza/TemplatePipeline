# Command-line program. It runs as the app `shapes-julia`.

const APP_NAME = "shapes-julia"
const APP_VERSION = string(pkgversion(@__MODULE__))

const HELP = """
Usage: $APP_NAME [SHAPE DIMENSION...]

Print the area and perimeter of a plane shape.

Shapes and their dimensions:
  circle     RADIUS
  rectangle  WIDTH HEIGHT
  square     SIDE
  triangle   A B C

Without arguments, $APP_NAME asks for the shape and its dimensions.

Options:
  -h, --help     Print this help and exit.
  -V, --version  Print the version and exit.
"""

function parse_number(s::AbstractString)
    x = tryparse(Float64, strip(s))
    x === nothing && throw(ShapeError(:not_a_number, "'$s' is not a number"))
    return x
end

# The output line for a shape name and dimension texts. Throws ShapeError.
function compute(name::AbstractString, args)
    names = dimension_names(name)
    length(args) == length(names) || throw(ShapeError(
        :wrong_count,
        "$name needs $(length(names)) dimension(s): $(join(names, ' '))",
    ))
    s = shape(name, map(parse_number, args))
    return "$name: area = $(fmt6(area(s))), perimeter = $(fmt6(perimeter(s)))"
end

fmt6(x::Float64) = @sprintf("%.6f", x)

function ask(prompt)
    print(prompt)
    flush(stdout)
    eof(stdin) && return nothing
    return strip(readline(stdin))
end

function interactive()
    prompt = "shape ($(join(SHAPE_NAMES, ", ")); q to quit): "
    while true
        name = ask(prompt)
        (name === nothing || name == "q" || name == "quit") && return 0
        isempty(name) && continue
        try
            names = dimension_names(name)
            dims = String[]
            for d in names
                a = ask("  $d: ")
                a === nothing && return 0
                push!(dims, a)
            end
            println(compute(name, dims))
        catch e
            e isa ShapeError || rethrow()
            println(stderr, "error: ", e.message)
        end
    end
end

"""
    main(args) -> Int

Run the command-line program with the argument vector `args`. Return the exit
status.
"""
function main(args::AbstractVector{<:AbstractString})
    isempty(args) && return interactive()
    first_arg = args[1]
    if first_arg in ("-h", "--help")
        print(HELP)
        return 0
    elseif first_arg in ("-V", "--version")
        println(APP_NAME, " ", APP_VERSION)
        return 0
    end
    try
        println(compute(first_arg, @view args[2:end]))
        return 0
    catch e
        e isa ShapeError || rethrow()
        println(stderr, "error: ", e.message)
        return 1
    end
end

function (@main)(args)
    return main(args)
end
