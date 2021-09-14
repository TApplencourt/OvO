FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  DOUBLE COMPLEX, intent(in) :: x
  INTEGER, intent(in) :: gold
  REAL, intent(in) :: tol
  LOGICAL :: b
  b = ( gold * (1 - tol) <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__simd
  implicit none
  INTEGER :: N0 = 32768
  INTEGER :: i0
  LOGICAL :: almost_equal
  DOUBLE COMPLEX :: counter_N0
  INTEGER :: expected_value
  expected_value = N0
  counter_N0 = 0
  !$OMP TARGET map(tofrom: counter_N0)
  !$OMP SIMD reduction(+: counter_N0)
  DO i0 = 1, N0
    counter_N0 = counter_N0 + 1.
  END DO
  !$OMP END TARGET
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.01) ) THEN
    WRITE(*,*) 'Expected', expected_value, 'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target__simd
