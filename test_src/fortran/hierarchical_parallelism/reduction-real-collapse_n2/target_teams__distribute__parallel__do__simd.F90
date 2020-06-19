FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams__distribute__parallel__do__simd
  INTEGER :: N0 = 8
  INTEGER :: i0
  INTEGER :: N1 = 8
  INTEGER :: i1
  INTEGER :: N2 = 8
  INTEGER :: i2
  INTEGER :: N3 = 8
  INTEGER :: i3
  INTEGER :: N4 = 8
  INTEGER :: i4
  INTEGER :: N5 = 8
  INTEGER :: i5
  LOGICAL :: almost_equal
  REAL :: counter_N0
  INTEGER :: expected_value
  expected_value = N0*N1*N2*N3*N4*N5
  counter_N0 = 0
  !$OMP target teams map(tofrom: counter_N0) reduction(+: counter_N0)
  !$OMP distribute collapse(2)
  DO i0 = 1, N0
  DO i1 = 1, N1
    !$OMP parallel reduction(+: counter_N0)
    !$OMP for collapse(2)
    DO i2 = 1, N2
    DO i3 = 1, N3
      !$OMP simd reduction(+: counter_N0) collapse(2)
      DO i4 = 1, N4
      DO i5 = 1, N5
        counter_N0 = counter_N0 + 1.
      END DO
      END DO
    END DO
    END DO
    !$OMP END parallel
  END DO
  END DO
  !$OMP END target teams
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target_teams__distribute__parallel__do__simd
