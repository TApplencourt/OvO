#ifndef _OPENMP
FUNCTION omp_get_num_teams() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_teams
SUBROUTINE omp_set_num_teams(i)
    integer, intent(in) :: i
END SUBROUTINE omp_set_num_teams
#endif
FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  DOUBLE COMPLEX, intent(in) :: x
  INTEGER, intent(in) :: gold
  REAL, intent(in) :: tol
  LOGICAL :: b
  b = ( gold * (1 - tol) <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__parallel__do__simd
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_teams
#endif
  INTEGER :: N0 = 32
  INTEGER :: i0
  INTEGER :: N1 = 32
  INTEGER :: i1
  LOGICAL :: almost_equal
  DOUBLE COMPLEX :: counter_teams
  INTEGER :: expected_value
  expected_value = N0*N1
  CALL omp_set_num_teams(32);
  counter_teams = 0
  !$OMP TARGET map(tofrom: counter_teams)
  !$OMP TEAMS reduction(+: counter_teams)
    !$OMP PARALLEL reduction(+: counter_teams)
    !$OMP DO
    DO i0 = 1, N0
      !$OMP SIMD reduction(+: counter_teams)
      DO i1 = 1, N1
        counter_teams = counter_teams + 1. / omp_get_num_teams() ;
      END DO
    END DO
    !$OMP END PARALLEL
  !$OMP END TEAMS
  !$OMP END TARGET
  IF ( .NOT.almost_equal(counter_teams,expected_value, 0.01) ) THEN
    WRITE(*,*) 'Expected', expected_value, 'Got', counter_teams
    STOP 112
  ENDIF
END PROGRAM target__teams__parallel__do__simd
