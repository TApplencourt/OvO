FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  DOUBLE COMPLEX, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams_distribute_parallel_do__simd
  implicit none
  INTEGER :: N0 = 182
  INTEGER :: i0
  INTEGER :: N1 = 182
  INTEGER :: i1
  LOGICAL :: almost_equal
  DOUBLE COMPLEX :: counter_N0
  INTEGER :: expected_value
  expected_value = N0*N1
  counter_N0 = 0
  !$OMP TARGET
  !$OMP TEAMS DISTRIBUTE PARALLEL DO reduction(+: counter_N0)
  DO i0 = 1, N0
    !$OMP SIMD reduction(+: counter_N0)
    DO i1 = 1, N1
      counter_N0 = counter_N0 + 1.
    END DO
  END DO
  !$OMP END TARGET
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target__teams_distribute_parallel_do__simd
