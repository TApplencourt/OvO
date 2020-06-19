#ifndef _OPENMP
FUNCTION omp_get_num_teams() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_teams
#endif
FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__parallel_do
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_teams
#endif
  INTEGER :: N0 = 262144
  INTEGER :: i0
  LOGICAL :: almost_equal
  REAL :: counter_teams
  REAL :: counter_N0
  INTEGER :: expected_value
  expected_value = N0
  counter_teams = 0
  !$OMP target map(tofrom: counter_teams)
  !$OMP teams
    counter_N0 = 0
    !$OMP parallel for
    DO i0 = 1, N0
      !$OMP omp atomic update
      counter_N0 = counter_N0 + 1.
    END DO
    !$OMP omp atomic update
    counter_teams = counter_teams + counter_N0  / omp_get_num_teams() ;
  !$OMP END teams
  !$OMP END target
  IF ( .NOT.almost_equal(counter_teams,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_teams
    STOP 112
  ENDIF
END PROGRAM target__teams__parallel_do
