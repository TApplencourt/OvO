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
  REAL, intent(in) :: x
  INTEGER, intent(in) :: gold
  REAL, intent(in) :: tol
  LOGICAL :: b
  b = ( gold * (1 - tol) <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__parallel_do_simd
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_teams
#endif
  INTEGER :: N0 = 182
  INTEGER :: i0
  LOGICAL :: almost_equal
  REAL :: counter_teams
  INTEGER :: expected_value
  expected_value = N0
  CALL omp_set_num_teams(182)
  counter_teams = 0
  !$OMP TARGET map(tofrom: counter_teams)
  !$OMP TEAMS
    !$OMP PARALLEL DO SIMD
    DO i0 = 1, N0
      !$OMP atomic update
      counter_teams = counter_teams + 1. / omp_get_num_teams()
    END DO
  !$OMP END TEAMS
  !$OMP END TARGET
  IF ( .NOT.almost_equal(counter_teams,expected_value, 0.01) ) THEN
    WRITE(*,*) 'Expected', expected_value, 'Got', counter_teams
    STOP 112
  ENDIF
END PROGRAM target__teams__parallel_do_simd
