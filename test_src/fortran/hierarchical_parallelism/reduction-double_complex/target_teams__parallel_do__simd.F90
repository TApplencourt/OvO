#ifndef _OPENMP
FUNCTION omp_get_num_teams() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_teams
#endif
FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  DOUBLE COMPLEX, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams__parallel_do__simd
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_teams
#endif
  INTEGER :: N0 = 182
  INTEGER :: i0
  INTEGER :: N1 = 182
  INTEGER :: i1
  LOGICAL :: almost_equal
  DOUBLE COMPLEX :: counter_teams
  INTEGER :: expected_value
  expected_value = N0*N1
  counter_teams = 0
  !$OMP TARGET TEAMS map(tofrom: counter_teams) reduction(+: counter_teams)
    !$OMP PARALLEL DO reduction(+: counter_teams)
    DO i0 = 1, N0
      !$OMP SIMD reduction(+: counter_teams)
      DO i1 = 1, N1
        counter_teams = counter_teams + 1.  / omp_get_num_teams() ;
      END DO
    END DO
  !$OMP END TARGET TEAMS
  IF ( .NOT.almost_equal(counter_teams,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_teams
    STOP 112
  ENDIF
END PROGRAM target_teams__parallel_do__simd
