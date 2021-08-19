#ifndef _OPENMP
FUNCTION omp_get_num_threads() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_threads
SUBROUTINE omp_set_teams_thread_limit(i)
    integer, intent(in) :: i
END SUBROUTINE omp_set_teams_thread_limit
#endif
FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_parallel
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_threads
#endif
  LOGICAL :: almost_equal
  REAL :: counter_parallel
  INTEGER :: expected_value
  expected_value = 1
  CALL omp_set_teams_thread_limit(32768);
  counter_parallel = 0
  !$OMP TARGET PARALLEL map(tofrom: counter_parallel)
    !$OMP atomic update
    counter_parallel = counter_parallel + 1.  / omp_get_num_threads() ;
  !$OMP END TARGET PARALLEL
  IF ( .NOT.almost_equal(counter_parallel,expected_value, 0.01) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_parallel
    STOP 112
  ENDIF
END PROGRAM target_parallel
