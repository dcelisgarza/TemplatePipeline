!> shapes-fortran: print the area and perimeter of a plane shape.
program shapes_fortran
  use, intrinsic :: iso_fortran_env, only: input_unit, output_unit, error_unit
  use, intrinsic :: ieee_arithmetic, only: ieee_value, ieee_positive_inf, ieee_quiet_nan
  use shapes
  implicit none

  character(len=*), parameter :: shape_prompt = &
    "shape (circle, rectangle, square, triangle; q to quit): "
  character(len=1), parameter :: tab = achar(9), cr = achar(13)
  integer, parameter :: max_arg = 4096

  character(len=max_arg) :: arg
  character(len=:), allocatable :: first
  character(len=max_arg), allocatable :: args(:)
  integer, allocatable :: lens(:)
  integer :: argc, i, alen

  argc = command_argument_count()
  if (argc == 0) then
    call interactive()
    stop
  end if

  call get_command_argument(1, arg, length=alen)
  first = arg(1:min(alen, max_arg))
  if (first == "-h" .or. first == "--help") then
    call print_usage()
    stop
  end if
  if (first == "-V" .or. first == "--version") then
    write (output_unit, "(a)") "shapes-fortran " // shapes_version
    stop
  end if

  allocate (args(max(argc - 1, 0)), lens(max(argc - 1, 0)))
  do i = 2, argc
    call get_command_argument(i, args(i - 1), length=alen)
    lens(i - 1) = min(alen, max_arg)
  end do
  if (.not. run(first, args, lens)) call exit(1)

contains

  subroutine print_usage()
    write (output_unit, "(a)") "Usage: shapes-fortran [SHAPE DIMENSION...]"
    write (output_unit, "(a)") ""
    write (output_unit, "(a)") "Print the area and perimeter of a plane shape."
    write (output_unit, "(a)") ""
    write (output_unit, "(a)") "Shapes and their dimensions:"
    write (output_unit, "(a)") "  circle     RADIUS"
    write (output_unit, "(a)") "  rectangle  WIDTH HEIGHT"
    write (output_unit, "(a)") "  square     SIDE"
    write (output_unit, "(a)") "  triangle   A B C"
    write (output_unit, "(a)") ""
    write (output_unit, "(a)") "Without arguments, shapes-fortran asks for the shape and its dimensions."
    write (output_unit, "(a)") ""
    write (output_unit, "(a)") "Options:"
    write (output_unit, "(a)") "  -h, --help     Print this help and exit."
    write (output_unit, "(a)") "  -V, --version  Print the version and exit."
  end subroutine print_usage

  !> Write an error message to standard error.
  subroutine report(msg)
    character(len=*), intent(in) :: msg
    flush (output_unit)
    write (error_unit, "(a)") "error: " // msg
  end subroutine report

  !> Format a number with six decimals and no leading spaces.
  function fmt6(x) result(text)
    real(dp), intent(in) :: x
    character(len=:), allocatable :: text
    character(len=400) :: buf
    write (buf, "(f340.6)") x
    text = trim(adjustl(buf))
  end function fmt6

  function int_text(n) result(text)
    integer, intent(in) :: n
    character(len=:), allocatable :: text
    character(len=16) :: buf
    write (buf, "(i0)") n
    text = trim(buf)
  end function int_text

  !> Remove spaces, tabs and carriage returns at both ends.
  function strip(text) result(s)
    character(len=*), intent(in) :: text
    character(len=:), allocatable :: s
    integer :: first_ch, last_ch
    first_ch = verify(text, " " // tab // cr)
    if (first_ch == 0) then
      s = ""
    else
      last_ch = verify(text, " " // tab // cr, back=.true.)
      s = text(first_ch:last_ch)
    end if
  end function strip

  function lower(text) result(s)
    character(len=*), intent(in) :: text
    character(len=len(text)) :: s
    integer :: k, code
    s = text
    do k = 1, len(text)
      code = iachar(text(k:k))
      if (code >= iachar("A") .and. code <= iachar("Z")) s(k:k) = achar(code + 32)
    end do
  end function lower

  !> Character at position `k`, or a space if `k` is out of range.
  pure function ch(text, k) result(c)
    character(len=*), intent(in) :: text
    integer, intent(in) :: k
    character(len=1) :: c
    if (k >= 1 .and. k <= len(text)) then
      c = text(k:k)
    else
      c = " "
    end if
  end function ch

  pure function is_digit(c) result(yes)
    character(len=1), intent(in) :: c
    logical :: yes
    yes = (c >= "0" .and. c <= "9")
  end function is_digit

  !> Read a decimal number. Returns false if the text is not a number.
  function parse_number(text, x) result(ok)
    character(len=*), intent(in) :: text
    real(dp), intent(out) :: x
    logical :: ok
    integer :: k, n, ios, ndigits
    logical :: neg

    ok = .false.
    x = 0.0_dp
    n = len(text)
    if (n == 0) return
    k = 1
    neg = .false.
    if (ch(text, 1) == "+" .or. ch(text, 1) == "-") then
      neg = (ch(text, 1) == "-")
      k = 2
    end if
    select case (lower(text(k:)))
    case ("inf", "infinity")
      x = ieee_value(x, ieee_positive_inf)
      if (neg) x = -x
      ok = .true.
      return
    case ("nan")
      x = ieee_value(x, ieee_quiet_nan)
      ok = .true.
      return
    end select

    ndigits = 0
    do while (is_digit(ch(text, k)) .and. k <= n)
      k = k + 1
      ndigits = ndigits + 1
    end do
    if (ch(text, k) == "." .and. k <= n) then
      k = k + 1
      do while (is_digit(ch(text, k)) .and. k <= n)
        k = k + 1
        ndigits = ndigits + 1
      end do
    end if
    if (ndigits == 0) return
    if (k <= n) then
      if (index("eEdD", text(k:k)) > 0) then
        k = k + 1
        if (ch(text, k) == "+" .or. ch(text, k) == "-") k = k + 1
        ndigits = 0
        do while (is_digit(ch(text, k)) .and. k <= n)
          k = k + 1
          ndigits = ndigits + 1
        end do
        if (ndigits == 0) return
      end if
    end if
    if (k /= n + 1) return
    read (text, *, iostat=ios) x
    ok = (ios == 0)
  end function parse_number

  !> Make the shape from text arguments and print it. Returns false after an error.
  function run(name, texts, lens) result(ok)
    character(len=*), intent(in) :: name
    character(len=*), intent(in) :: texts(:)
    integer, intent(in) :: lens(:)
    logical :: ok
    class(shape_t), allocatable :: s
    real(dp), allocatable :: dims(:)
    character(len=:), allocatable :: line
    integer :: n, i, stat

    ok = .false.
    n = shape_ndims(name)
    if (n < 0) then
      call report("unknown shape '" // name // "'")
      return
    end if
    if (size(texts) /= n) then
      line = name // " needs " // int_text(n) // " dimension(s):"
      do i = 1, n
        line = line // " " // shape_dim_name(name, i)
      end do
      call report(line)
      return
    end if
    allocate (dims(n))
    do i = 1, n
      if (.not. parse_number(texts(i)(1:lens(i)), dims(i))) then
        call report("'" // texts(i)(1:lens(i)) // "' is not a number")
        return
      end if
    end do
    call make_shape(name, dims, s, stat)
    if (stat /= SHAPE_OK) then
      call report(shape_message(stat))
      return
    end if
    write (output_unit, "(a)") s%name() // ": area = " // fmt6(s%area()) // &
      ", perimeter = " // fmt6(s%perimeter())
    ok = .true.
  end function run

  !> Print the prompt and read one stripped line. Returns false at end of input.
  function ask(prompt, answer) result(ok)
    character(len=*), intent(in) :: prompt
    character(len=:), allocatable, intent(out) :: answer
    logical :: ok
    character(len=max_arg) :: buf
    integer :: ios

    write (output_unit, "(a)", advance="no") prompt
    flush (output_unit)
    read (input_unit, "(a)", iostat=ios) buf
    if (ios /= 0) then
      ok = .false.
      answer = ""
      write (output_unit, "(a)") ""
      return
    end if
    answer = strip(buf)
    ok = .true.
  end function ask

  subroutine interactive()
    character(len=:), allocatable :: name, answer
    character(len=max_arg) :: texts(max_dims)
    integer :: lens(max_dims)
    integer :: n, i
    logical :: ok

    do
      if (.not. ask(shape_prompt, name)) return
      if (len(name) == 0) cycle
      if (name == "q" .or. name == "quit") return
      n = shape_ndims(name)
      if (n < 0) then
        call report("unknown shape '" // name // "'")
        cycle
      end if
      do i = 1, n
        if (.not. ask("  " // shape_dim_name(name, i) // ": ", answer)) return
        texts(i) = answer
        lens(i) = len(answer)
      end do
      ok = run(name, texts(1:n), lens(1:n))
    end do
  end subroutine interactive

end program shapes_fortran
