FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER, intent(in) :: gold
  REAL, intent(in) :: tol
  LOGICAL :: b
  b = ( gold * (1 - tol) <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams_distribute_parallel_do_simd
  implicit none
  INTEGER :: N0 = 32768
  INTEGER :: i0
  LOGICAL :: almost_equal
  REAL :: counter_N0
  INTEGER :: expected_value
  expected_value = N0
  counter_N0 = 0
  !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO SIMD map(tofrom: counter_N0)
  DO i0 = 1, N0
    !$OMP atomic update
    counter_N0 = counter_N0 + 1.
  END DO
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.01) ) THEN
    WRITE(*,*) 'Expected', expected_value, 'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target_teams_distribute_parallel_do_simd
