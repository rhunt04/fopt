MODULE functions
  USE utils, ONLY : dp, sqrt2
  IMPLICIT NONE

  PRIVATE
  PUBLIC ftest, gtest

  CONTAINS

  REAL(dp) FUNCTION ftest(x)
    IMPLICIT NONE
    REAL(dp), INTENT(in) :: x(:)

    ftest = ( x(1) - 2.d0 )**2 + ( x(2) + 3.d0 )**2

  END FUNCTION ftest

  FUNCTION gtest(x) RESULT(g)
    IMPLICIT NONE
    REAL(dp), INTENT(in) :: x(:)
    REAL(dp), DIMENSION(size(x)) :: g

    g(1) = 2.d0 * ( x(1) - 2.d0 )
    g(2) = 2.d0 * ( x(2) + 3.d0 )

  END FUNCTION gtest


  REAL(dp) FUNCTION fthom(x)
    ! Thomson problem potential evaluation.
    ! 'x' is an array of length 2*n (n the number of charges).
    ! The first n elements are theta variables [0, pi).
    ! The final n elements are phi variables [0, 2pi].
    IMPLICIT NONE
    REAL(dp), INTENT(in) :: x(:)
    INTEGER i, j, n

    fthom = 0.d0

    ! Check size(x) even.
    if ( mod(size(x), 2) == 0 ) then
      n = size(x) / 2
      ! Loop over pairs...
      do i = 1, n
        do j = i + 1, n
          fthom = fthom + 1.d0 / circle_distance(x(i), x(j), x(i + n), x(j + n))
        enddo
      enddo
    endif

  END FUNCTION fthom

  FUNCTION gthom(x) RESULT(g)
    ! Thomson problem gradient evaluation.
    ! On output, g is the gradient of fthom, taken with respect to the
    ! parameters in order. See fthom comment for more info.
    IMPLICIT NONE
    REAL(dp), INTENT(in) :: x(:)
    REAL(dp), DIMENSION(size(x)) :: g

    ! TODO: evaluate...

  END FUNCTION gthom

  REAL(dp) FUNCTION circle_distance(t1, t2, p1, p2, ur)
    ! Distance between two points (t(heta)1, p(hi)1) and (t(heta)2, p(hi)2) on
    ! a circle of radius r.
    IMPLICIT NONE
    REAL(dp), INTENT(in) :: t1, t2, p1, p2
    REAL(dp), OPTIONAL, INTENT(in) :: ur
    REAL(dp) :: r = 1.d0

    if ( present(ur) ) r = abs(ur)
    ! |r_1 - r_2| = ... in spherical polars, but with |r_1|=|r_2|.
    circle_distance = 1.d0 - cos(t1 - t2) - 2.d0 * sin(t1) * sin(t2) * &
      &(cos(p1 - p2) - 1.d0)
    circle_distance = sqrt2 * r * sqrt(circle_distance)

  END FUNCTION circle_distance

END MODULE functions
