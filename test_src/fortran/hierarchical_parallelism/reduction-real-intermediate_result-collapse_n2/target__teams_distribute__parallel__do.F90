FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams_distribute__parallel__do
  INTEGER :: N0 = 23
  INTEGER :: i0
  INTEGER :: N1 = 23
  INTEGER :: i1
  INTEGER :: N2 = 23
  INTEGER :: i2
  INTEGER :: N3 = 23
  INTEGER :: i3
  LOGICAL :: almost_equal
  REAL :: counter_N0
  REAL :: counter_N2
  INTEGER :: expected_value
  expected_value = N0*N1*N2*N3
  counter_N0 = 0
  !$OMP target map(tofrom: counter_N0)
  !$OMP teams distribute reduction(+: counter_N0) collapse(2)
  DO i0 = 1, N0
  DO i1 = 1, N1
    counter_N2 = 0
    !$OMP parallel reduction(+: counter_N2)
    !$OMP for collapse(2)
    DO i2 = 1, N2
    DO i3 = 1, N3
      counter_N2 = counter_N2 + 1.
    END DO
    END DO
    !$OMP END parallel
    counter_N0 = counter_N0 + counter_N2
  END DO
  END DO
  !$OMP END target
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target__teams_distribute__parallel__do
