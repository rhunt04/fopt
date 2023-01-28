MODULE lbfgsb
  USE utils
  ! Call (repeatedly) setulb() from lbfgsb, with some options set.
  IMPLICIT NONE

  ! Read the lbsfgb.f source file for info on these.
  INTEGER, PARAMETER :: lbfgsb_m = 5
  INTEGER, PARAMETER :: lbfgsb_iprint = 101
  REAL(dp), PARAMETER :: lbfgsb_pgtol = 0.d0
  REAL(dp), PARAMETER :: lbfgsb_factr = 1.d+4

  PRIVATE
  PUBLIC opt

  CONTAINS

  SUBROUTINE opt(x, f, g, uu, ul, unbd)
    IMPLICIT NONE

    ! Input vector.
    REAL(dp), INTENT(inout) :: x(:)

    ! Input vector bounds, and their types.
    INTEGER, OPTIONAL, INTENT(in) :: unbd(size(x))
    REAL(dp), OPTIONAL, INTENT(in) :: ul(size(x)), uu(size(x))

    ! Allocatables for setulb calls and working.
    REAL(dp), ALLOCATABLE :: wa(:), u(:), l(:)
    INTEGER, ALLOCATABLE :: iwa(:), nbd(:)

    ! Statics for setulb calls and working.
    LOGICAL lsave(4)
    INTEGER isave(44)
    REAL(dp) dsave(29)
    CHARACTER(60) task, csave

    ! Convenience
    INTEGER n
    LOGICAL :: ubounding = .false.
    REAL(dp) :: fx, gx(size(x))

    INTERFACE
      FUNCTION f(y)
        USE utils, ONLY : dp
        REAL(dp), INTENT(in) :: y(:)
        REAL(dp) f
      END FUNCTION f
    END INTERFACE ! function value

    INTERFACE
      FUNCTION g(y)
        USE utils, ONLY : dp
        REAL(dp), INTENT(in) :: y(:)
        REAL(dp) g(size(y))
      END FUNCTION g
    END INTERFACE ! gradient value

    write(*, *) "Placeholder routine which will call setulb()."
    write(*, *) "x -> ", x
    write(*, *) "f -> ", f(x)
    write(*, *) "g -> ", g(x)

    ! Check bounds compatible.
    if (present(uu).and.present(ul).and.present(unbd)) then
      write(*, *) "Bounding parameters."
      ubounding = .true.
    else
      if (present(uu).or.present(ul).or.present(unbd)) then
        write(*, *) "Need u, l AND nbd to bound parameters!"
        stop 2
      else
        write(*, *) "Not bounding parameters."
      endif
    endif

    n = size(x)

    ! Allocate dynamic workspace arrays.
    allocate ( iwa(3*n), nbd(n) ) ! ints
    allocate ( wa(2*lbfgsb_m*n + 5*n + 11*lbfgsb_m*lbfgsb_m + 8*lbfgsb_m) )
    allocate ( u(n), l(n) )
    if ( ubounding ) then
      u = uu; l = ul; nbd = unbd
    else
      ! dummy : make our own.
      u = 0.d0; l = 0.d0; nbd = 0
    endif

    task = 'START'

    fx = f(x); gx = g(x)

    do while (looping(task))
      ! Call LBFGSB code.
      call setulb(n, lbfgsb_m, x, l, u, nbd, fx, gx, lbfgsb_factr, &
        &lbfgsb_pgtol, wa, iwa, task, lbfgsb_iprint, csave, lsave, isave, dsave)

      if ( task(1:2).eq.'FG' ) then
        fx = f(x)
        gx = g(x)
      endif

    enddo

    CONTAINS

    LOGICAL FUNCTION looping(t)
      IMPLICIT NONE
      CHARACTER(60), INTENT(inout) :: t
      looping = (t(1:2).eq.'FG').or.(t.eq.'NEW_X').or.(t.eq.'START')
    END FUNCTION looping

  END SUBROUTINE opt


END MODULE lbfgsb

PROGRAM main
  USE utils
  USE lbfgsb
  USE functions
  IMPLICIT NONE
  REAL(dp) :: x(2)

  write(*, *) "This is main."
  x = (/1.d0, -2.d0/)
  write(*, *) "x_i = ", x
  call opt(x, ftest, gtest)
  write(*, *) "x_f = ", x

END PROGRAM main
