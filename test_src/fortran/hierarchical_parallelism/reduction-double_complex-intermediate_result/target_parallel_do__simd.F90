FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  DOUBLE COMPLEX, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_parallel_do__simd
  INTEGER :: N0 = 512
  INTEGER :: i0
  INTEGER :: N1 = 512
  INTEGER :: i1
  LOGICAL :: almost_equal
  DOUBLE COMPLEX :: counter_N0
  DOUBLE COMPLEX :: counter_N1
  INTEGER :: expected_value
  expected_value = N0*N1
  counter_N0 = 0
  !$OMP target parallel for map(tofrom: counter_N0) reduction(+: counter_N0)
  DO i0 = 1, N0
    counter_N1 = 0
    !$OMP simd reduction(+: counter_N1)
    DO i1 = 1, N1
      counter_N1 = counter_N1 + 1.
    END DO
    counter_N0 = counter_N0 + counter_N1
  END DO
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target_parallel_do__simd
