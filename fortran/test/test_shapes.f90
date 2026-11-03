!> Unit tests for the shapes library.
module test_shapes
  use, intrinsic :: ieee_arithmetic, only: ieee_value, ieee_positive_inf, ieee_quiet_nan
  use shapes
  use testdrive, only: new_unittest, unittest_type, error_type, check
  implicit none
  private
  public :: collect_shapes

  real(dp), parameter :: pi = 3.14159265358979323846_dp

contains

  !> Collect all tests.
  subroutine collect_shapes(testsuite)
    type(unittest_type), allocatable, intent(out) :: testsuite(:)
    testsuite = [ &
      new_unittest("circle", test_circle), &
      new_unittest("rectangle", test_rectangle), &
      new_unittest("square", test_square), &
      new_unittest("triangle", test_triangle), &
      new_unittest("non-positive", test_non_positive), &
      new_unittest("inf-and-nan", test_inf_nan), &
      new_unittest("triangle-inequality", test_triangle_inequality), &
      new_unittest("unknown-name", test_unknown), &
      new_unittest("wrong-arity", test_arity) &
      ]
  end subroutine collect_shapes

  logical function close_to(x, y)
    real(dp), intent(in) :: x, y
    close_to = abs(x - y) < 1.0e-9_dp
  end function close_to

  !> Make a shape and check the status code.
  subroutine build(error, name, dims, s, expected)
    type(error_type), allocatable, intent(out) :: error
    character(len=*), intent(in) :: name
    real(dp), intent(in) :: dims(:)
    class(shape_t), allocatable, intent(out) :: s
    integer, intent(in) :: expected
    integer :: stat
    call make_shape(name, dims, s, stat)
    call check(error, stat == expected, "wrong status for " // name)
  end subroutine build

  subroutine test_circle(error)
    type(error_type), allocatable, intent(out) :: error
    class(shape_t), allocatable :: s
    call build(error, "circle", [2.0_dp], s, SHAPE_OK)
    if (allocated(error)) return
    call check(error, close_to(s%area(), 4.0_dp * pi), "area of circle")
    if (allocated(error)) return
    call check(error, close_to(s%perimeter(), 4.0_dp * pi), "perimeter of circle")
    if (allocated(error)) return
    call check(error, s%name() == "circle", "name of circle")
  end subroutine test_circle

  subroutine test_rectangle(error)
    type(error_type), allocatable, intent(out) :: error
    class(shape_t), allocatable :: s
    call build(error, "rectangle", [2.0_dp, 3.0_dp], s, SHAPE_OK)
    if (allocated(error)) return
    call check(error, close_to(s%area(), 6.0_dp), "area of rectangle")
    if (allocated(error)) return
    call check(error, close_to(s%perimeter(), 10.0_dp), "perimeter of rectangle")
    if (allocated(error)) return
    call check(error, s%name() == "rectangle", "name of rectangle")
  end subroutine test_rectangle

  subroutine test_square(error)
    type(error_type), allocatable, intent(out) :: error
    class(shape_t), allocatable :: s
    call build(error, "square", [3.0_dp], s, SHAPE_OK)
    if (allocated(error)) return
    call check(error, close_to(s%area(), 9.0_dp), "area of square")
    if (allocated(error)) return
    call check(error, close_to(s%perimeter(), 12.0_dp), "perimeter of square")
    if (allocated(error)) return
    call check(error, s%name() == "square", "name of square")
  end subroutine test_square

  subroutine test_triangle(error)
    type(error_type), allocatable, intent(out) :: error
    class(shape_t), allocatable :: s
    call build(error, "triangle", [3.0_dp, 4.0_dp, 5.0_dp], s, SHAPE_OK)
    if (allocated(error)) return
    call check(error, close_to(s%area(), 6.0_dp), "area of triangle")
    if (allocated(error)) return
    call check(error, close_to(s%perimeter(), 12.0_dp), "perimeter of triangle")
    if (allocated(error)) return
    call check(error, s%name() == "triangle", "name of triangle")
  end subroutine test_triangle

  subroutine test_non_positive(error)
    type(error_type), allocatable, intent(out) :: error
    class(shape_t), allocatable :: s
    call build(error, "circle", [0.0_dp], s, SHAPE_ERR_NOT_POSITIVE)
    if (allocated(error)) return
    call build(error, "circle", [-1.0_dp], s, SHAPE_ERR_NOT_POSITIVE)
    if (allocated(error)) return
    call build(error, "rectangle", [2.0_dp, 0.0_dp], s, SHAPE_ERR_NOT_POSITIVE)
    if (allocated(error)) return
    call build(error, "square", [-3.0_dp], s, SHAPE_ERR_NOT_POSITIVE)
    if (allocated(error)) return
    call build(error, "triangle", [3.0_dp, 4.0_dp, -5.0_dp], s, SHAPE_ERR_NOT_POSITIVE)
    if (allocated(error)) return
    call check(error, .not. allocated(s), "no shape after an error")
    if (allocated(error)) return
    call check(error, shape_message(SHAPE_ERR_NOT_POSITIVE) == "dimensions must be positive numbers", &
      "message for non-positive")
  end subroutine test_non_positive

  subroutine test_inf_nan(error)
    type(error_type), allocatable, intent(out) :: error
    class(shape_t), allocatable :: s
    real(dp) :: inf, nan
    inf = ieee_value(inf, ieee_positive_inf)
    nan = ieee_value(nan, ieee_quiet_nan)
    call build(error, "circle", [inf], s, SHAPE_ERR_NOT_POSITIVE)
    if (allocated(error)) return
    call build(error, "circle", [nan], s, SHAPE_ERR_NOT_POSITIVE)
    if (allocated(error)) return
    call build(error, "rectangle", [1.0_dp, inf], s, SHAPE_ERR_NOT_POSITIVE)
    if (allocated(error)) return
    call build(error, "square", [nan], s, SHAPE_ERR_NOT_POSITIVE)
    if (allocated(error)) return
    call build(error, "triangle", [3.0_dp, 4.0_dp, nan], s, SHAPE_ERR_NOT_POSITIVE)
  end subroutine test_inf_nan

  subroutine test_triangle_inequality(error)
    type(error_type), allocatable, intent(out) :: error
    class(shape_t), allocatable :: s
    call build(error, "triangle", [1.0_dp, 1.0_dp, 5.0_dp], s, SHAPE_ERR_NOT_TRIANGLE)
    if (allocated(error)) return
    call build(error, "triangle", [1.0_dp, 2.0_dp, 3.0_dp], s, SHAPE_ERR_NOT_TRIANGLE)
    if (allocated(error)) return
    call build(error, "triangle", [5.0_dp, 1.0_dp, 1.0_dp], s, SHAPE_ERR_NOT_TRIANGLE)
    if (allocated(error)) return
    call build(error, "triangle", [2.0_dp, 2.0_dp, 3.0_dp], s, SHAPE_OK)
    if (allocated(error)) return
    call check(error, shape_message(SHAPE_ERR_NOT_TRIANGLE) == "sides do not form a triangle", &
      "message for triangle")
  end subroutine test_triangle_inequality

  subroutine test_unknown(error)
    type(error_type), allocatable, intent(out) :: error
    class(shape_t), allocatable :: s
    call build(error, "hexagon", [1.0_dp], s, SHAPE_ERR_UNKNOWN)
    if (allocated(error)) return
    call check(error, shape_ndims("hexagon") == -1, "ndims of unknown shape")
  end subroutine test_unknown

  subroutine test_arity(error)
    type(error_type), allocatable, intent(out) :: error
    class(shape_t), allocatable :: s
    call build(error, "rectangle", [2.0_dp], s, SHAPE_ERR_ARITY)
    if (allocated(error)) return
    call check(error, shape_ndims("rectangle") == 2, "ndims of rectangle")
    if (allocated(error)) return
    call check(error, shape_dim_name("rectangle", 2) == "height", "dimension name")
  end subroutine test_arity

end module test_shapes
