!> Plane shapes with area and perimeter.
!>
!> The abstract type [[shape_t]] has the deferred procedures `area`,
!> `perimeter` and `name`. The types [[circle_t]], [[rectangle_t]],
!> [[square_t]] and [[triangle_t]] extend it. Use [[make_shape]] to make a
!> shape from its name and its dimensions. Errors come back as a status code.
module shapes
  use, intrinsic :: iso_fortran_env, only: real64
  implicit none
  private

  !> Version of the library. It must equal the VERSION file in the repository.
  character(len=*), parameter, public :: shapes_version = "0.1.0"

  !> Kind of the real numbers in this library.
  integer, parameter, public :: dp = real64
  !> Largest number of dimensions of any shape.
  integer, parameter, public :: max_dims = 3

  !> Status code: no error.
  integer, parameter, public :: SHAPE_OK = 0
  !> Status code: the shape name is not known.
  integer, parameter, public :: SHAPE_ERR_UNKNOWN = 1
  !> Status code: the number of dimensions is wrong.
  integer, parameter, public :: SHAPE_ERR_ARITY = 2
  !> Status code: a dimension is not a finite number above zero.
  integer, parameter, public :: SHAPE_ERR_NOT_POSITIVE = 3
  !> Status code: the sides do not form a triangle.
  integer, parameter, public :: SHAPE_ERR_NOT_TRIANGLE = 4

  real(dp), parameter :: pi = 3.14159265358979323846_dp

  !> Abstract base type of all shapes.
  type, abstract, public :: shape_t
  contains
    !> Area of the shape.
    procedure(area_iface), deferred :: area
    !> Perimeter of the shape.
    procedure(perimeter_iface), deferred :: perimeter
    !> Name of the shape, for example "circle".
    procedure(name_iface), deferred :: name
  end type shape_t

  abstract interface
    pure function area_iface(self) result(a)
      import :: shape_t, dp
      class(shape_t), intent(in) :: self
      real(dp) :: a
    end function area_iface

    pure function perimeter_iface(self) result(p)
      import :: shape_t, dp
      class(shape_t), intent(in) :: self
      real(dp) :: p
    end function perimeter_iface

    pure function name_iface(self) result(n)
      import :: shape_t
      class(shape_t), intent(in) :: self
      character(len=:), allocatable :: n
    end function name_iface
  end interface

  !> A circle with a radius.
  type, extends(shape_t), public :: circle_t
    real(dp) :: radius = 0.0_dp
  contains
    procedure :: area => circle_area
    procedure :: perimeter => circle_perimeter
    procedure :: name => circle_name
  end type circle_t

  !> A rectangle with a width and a height.
  type, extends(shape_t), public :: rectangle_t
    real(dp) :: width = 0.0_dp
    real(dp) :: height = 0.0_dp
  contains
    procedure :: area => rectangle_area
    procedure :: perimeter => rectangle_perimeter
    procedure :: name => rectangle_name
  end type rectangle_t

  !> A square with one side.
  type, extends(shape_t), public :: square_t
    real(dp) :: side = 0.0_dp
  contains
    procedure :: area => square_area
    procedure :: perimeter => square_perimeter
    procedure :: name => square_name
  end type square_t

  !> A triangle with three sides.
  type, extends(shape_t), public :: triangle_t
    real(dp) :: a = 0.0_dp
    real(dp) :: b = 0.0_dp
    real(dp) :: c = 0.0_dp
  contains
    procedure :: area => triangle_area
    procedure :: perimeter => triangle_perimeter
    procedure :: name => triangle_name
  end type triangle_t

  public :: make_shape, shape_ndims, shape_dim_name, shape_message

contains

  pure function circle_area(self) result(a)
    class(circle_t), intent(in) :: self
    real(dp) :: a
    a = pi * self%radius * self%radius
  end function circle_area

  pure function circle_perimeter(self) result(p)
    class(circle_t), intent(in) :: self
    real(dp) :: p
    p = 2.0_dp * pi * self%radius
  end function circle_perimeter

  pure function circle_name(self) result(n)
    class(circle_t), intent(in) :: self
    character(len=:), allocatable :: n
    n = "circle"
  end function circle_name

  pure function rectangle_area(self) result(a)
    class(rectangle_t), intent(in) :: self
    real(dp) :: a
    a = self%width * self%height
  end function rectangle_area

  pure function rectangle_perimeter(self) result(p)
    class(rectangle_t), intent(in) :: self
    real(dp) :: p
    p = 2.0_dp * (self%width + self%height)
  end function rectangle_perimeter

  pure function rectangle_name(self) result(n)
    class(rectangle_t), intent(in) :: self
    character(len=:), allocatable :: n
    n = "rectangle"
  end function rectangle_name

  pure function square_area(self) result(a)
    class(square_t), intent(in) :: self
    real(dp) :: a
    a = self%side * self%side
  end function square_area

  pure function square_perimeter(self) result(p)
    class(square_t), intent(in) :: self
    real(dp) :: p
    p = 4.0_dp * self%side
  end function square_perimeter

  pure function square_name(self) result(n)
    class(square_t), intent(in) :: self
    character(len=:), allocatable :: n
    n = "square"
  end function square_name

  pure function triangle_area(self) result(a)
    class(triangle_t), intent(in) :: self
    real(dp) :: a
    real(dp) :: s
    s = (self%a + self%b + self%c) / 2.0_dp
    a = sqrt(max(0.0_dp, s * (s - self%a) * (s - self%b) * (s - self%c)))
  end function triangle_area

  pure function triangle_perimeter(self) result(p)
    class(triangle_t), intent(in) :: self
    real(dp) :: p
    p = self%a + self%b + self%c
  end function triangle_perimeter

  pure function triangle_name(self) result(n)
    class(triangle_t), intent(in) :: self
    character(len=:), allocatable :: n
    n = "triangle"
  end function triangle_name

  !> Number of dimensions of a shape, or -1 if the name is not known.
  pure function shape_ndims(name) result(n)
    character(len=*), intent(in) :: name
    integer :: n
    select case (name)
    case ("circle", "square")
      n = 1
    case ("rectangle")
      n = 2
    case ("triangle")
      n = 3
    case default
      n = -1
    end select
  end function shape_ndims

  !> Name of dimension `i` (counted from 1) of a shape, or an empty string.
  pure function shape_dim_name(name, i) result(d)
    character(len=*), intent(in) :: name
    integer, intent(in) :: i
    character(len=:), allocatable :: d
    d = ""
    select case (name)
    case ("circle")
      if (i == 1) d = "radius"
    case ("square")
      if (i == 1) d = "side"
    case ("rectangle")
      if (i == 1) d = "width"
      if (i == 2) d = "height"
    case ("triangle")
      if (i == 1) d = "a"
      if (i == 2) d = "b"
      if (i == 3) d = "c"
    end select
  end function shape_dim_name

  !> Text for a status code. The text is empty for `SHAPE_OK`.
  !> The text for `SHAPE_ERR_UNKNOWN` and `SHAPE_ERR_ARITY` needs the shape
  !> name, so the caller writes these two.
  pure function shape_message(stat) result(msg)
    integer, intent(in) :: stat
    character(len=:), allocatable :: msg
    select case (stat)
    case (SHAPE_ERR_NOT_POSITIVE)
      msg = "dimensions must be positive numbers"
    case (SHAPE_ERR_NOT_TRIANGLE)
      msg = "sides do not form a triangle"
    case (SHAPE_ERR_UNKNOWN)
      msg = "unknown shape"
    case (SHAPE_ERR_ARITY)
      msg = "wrong number of dimensions"
    case default
      msg = ""
    end select
  end function shape_message

  !> Make a shape from its name and its dimensions.
  !>
  !> `stat` is `SHAPE_OK` on success. On failure, `s` is not allocated.
  subroutine make_shape(name, dims, s, stat)
    !> One of circle, rectangle, square, triangle.
    character(len=*), intent(in) :: name
    !> The dimensions, in the order of `shape_dim_name`.
    real(dp), intent(in) :: dims(:)
    !> The new shape.
    class(shape_t), allocatable, intent(out) :: s
    !> Status code.
    integer, intent(out) :: stat
    integer :: n

    n = shape_ndims(name)
    if (n < 0) then
      stat = SHAPE_ERR_UNKNOWN
      return
    end if
    if (size(dims) /= n) then
      stat = SHAPE_ERR_ARITY
      return
    end if
    if (.not. all(dims > 0.0_dp .and. dims <= huge(1.0_dp))) then
      stat = SHAPE_ERR_NOT_POSITIVE
      return
    end if
    stat = SHAPE_OK
    select case (name)
    case ("circle")
      allocate (s, source=circle_t(radius=dims(1)))
    case ("rectangle")
      allocate (s, source=rectangle_t(width=dims(1), height=dims(2)))
    case ("square")
      allocate (s, source=square_t(side=dims(1)))
    case ("triangle")
      if (dims(1) + dims(2) <= dims(3) .or. dims(1) + dims(3) <= dims(2) &
          .or. dims(2) + dims(3) <= dims(1)) then
        stat = SHAPE_ERR_NOT_TRIANGLE
        return
      end if
      allocate (s, source=triangle_t(a=dims(1), b=dims(2), c=dims(3)))
    end select
  end subroutine make_shape

end module shapes
