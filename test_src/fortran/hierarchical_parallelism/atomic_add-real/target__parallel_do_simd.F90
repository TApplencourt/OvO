FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER, intent(in) :: gold
  REAL, intent(in) :: tol
  LOGICAL :: b
  b = ( gold * (1 - tol) <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__parallel_do_simd
  implicit none
  INTEGER :: N0 = 32768
  INTEGER :: i0
  LOGICAL :: almost_equal
  REAL :: counter_N0
  INTEGER :: expected_value
  expected_value = N0
  counter_N0 = 0
  !$OMP TARGET map(tofrom: counter_N0)
  !$OMP PARALLEL DO SIMD
  DO i0 = 1, N0
    !$OMP atomic update
    counter_N0 = counter_N0 + 1.
  END DO
  !$OMP END TARGET
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.01) ) THEN
    WRITE(*,*) 'Expected', expected_value, 'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target__parallel_do_simd
