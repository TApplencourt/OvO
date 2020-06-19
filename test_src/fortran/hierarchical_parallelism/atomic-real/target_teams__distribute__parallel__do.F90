FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams__distribute__parallel__do
  INTEGER :: N0 = 512
  INTEGER :: i0
  INTEGER :: N1 = 512
  INTEGER :: i1
  LOGICAL :: almost_equal
  REAL :: counter_N0
  INTEGER :: expected_value
  expected_value = N0*N1
  counter_N0 = 0
  !$OMP target teams map(tofrom: counter_N0)
  !$OMP distribute
  DO i0 = 1, N0
    !$OMP parallel
    !$OMP for
    DO i1 = 1, N1
      !$OMP omp atomic update
      counter_N0 = counter_N0 + 1.
    END DO
    !$OMP END parallel
  END DO
  !$OMP END target teams
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target_teams__distribute__parallel__do
