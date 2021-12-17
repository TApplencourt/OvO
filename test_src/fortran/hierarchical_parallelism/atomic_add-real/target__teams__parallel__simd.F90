#ifndef _OPENMP
FUNCTION omp_get_num_teams() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_teams
SUBROUTINE omp_set_num_teams(i)
    integer, intent(in) :: i
    IF (i /= 0) CONTINUE
END SUBROUTINE omp_set_num_teams
FUNCTION omp_get_num_threads() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_threads
#endif
FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER, intent(in) :: gold
  REAL, intent(in) :: tol
  LOGICAL :: b
  b = ( gold * (1 - tol) <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__parallel__simd
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_teams
  INTEGER :: omp_get_num_threads
#endif
  INTEGER :: N0 = 32
  INTEGER :: i0
  LOGICAL :: almost_equal
  REAL :: counter_teams
  INTEGER :: expected_value
  expected_value = N0
  CALL omp_set_num_teams(32)
  counter_teams = 0
  !$OMP TARGET map(tofrom: counter_teams)
  !$OMP TEAMS
    !$OMP PARALLEL num_threads(32)
      !$OMP SIMD
      DO i0 = 1, N0
        !$OMP atomic update
        counter_teams = counter_teams + 1. / ( omp_get_num_teams() * omp_get_num_threads() )
      END DO
    !$OMP END PARALLEL
  !$OMP END TEAMS
  !$OMP END TARGET
  IF ( .NOT.almost_equal(counter_teams,expected_value, 0.01) ) THEN
    WRITE(*,*) 'Expected', expected_value, 'Got', counter_teams
    STOP 112
  ENDIF
END PROGRAM target__teams__parallel__simd
