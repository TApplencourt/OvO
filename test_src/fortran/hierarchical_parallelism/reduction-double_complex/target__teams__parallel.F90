#ifndef _OPENMP
FUNCTION omp_get_num_teams() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_teams
FUNCTION omp_get_num_threads() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_threads
#endif
FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  DOUBLE COMPLEX, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__parallel
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_teams
  INTEGER :: omp_get_num_threads
#endif
  LOGICAL :: almost_equal
  DOUBLE COMPLEX :: counter_teams
  INTEGER :: expected_value
  expected_value = 1
  counter_teams = 0
  !$OMP target map(tofrom: counter_teams)
  !$OMP teams reduction(+: counter_teams)
    !$OMP parallel reduction(+: counter_teams)
      counter_teams = counter_teams + 1.  / ( omp_get_num_teams() * omp_get_num_threads() ) ;
    !$OMP END parallel
  !$OMP END teams
  !$OMP END target
  IF ( .NOT.almost_equal(counter_teams,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_teams
    STOP 112
  ENDIF
END PROGRAM target__teams__parallel
