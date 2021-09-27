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
PROGRAM target_teams__parallel_do__simd
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
  REAL :: counter_teams
  INTEGER :: expected_value
  expected_value = N0*N1
  CALL omp_set_num_teams(32)
  counter_teams = 0
  !$OMP TARGET TEAMS map(tofrom: counter_teams)
    !$OMP PARALLEL DO
    DO i0 = 1, N0
      !$OMP SIMD
      DO i1 = 1, N1
        !$OMP atomic update
        counter_teams = counter_teams + 1. / omp_get_num_teams()
      END DO
    END DO
  !$OMP END TARGET TEAMS
  IF ( .NOT.almost_equal(counter_teams,expected_value, 0.01) ) THEN
    WRITE(*,*) 'Expected', expected_value, 'Got', counter_teams
    STOP 112
  ENDIF
END PROGRAM target_teams__parallel_do__simd
