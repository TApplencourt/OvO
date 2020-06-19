#ifndef _OPENMP
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
PROGRAM target_teams_distribute__parallel__simd
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_threads
#endif
  INTEGER :: N0 = 512
  INTEGER :: i0
  INTEGER :: N1 = 512
  INTEGER :: i1
  LOGICAL :: almost_equal
  DOUBLE COMPLEX :: counter_N0
  DOUBLE COMPLEX :: counter_parallel
  DOUBLE COMPLEX :: counter_N1
  INTEGER :: expected_value
  expected_value = N0*N1
  counter_N0 = 0
  !$OMP target teams distribute map(tofrom: counter_N0) reduction(+: counter_N0)
  DO i0 = 1, N0
    counter_parallel = 0
    !$OMP parallel reduction(+: counter_parallel)
      counter_N1 = 0
      !$OMP simd reduction(+: counter_N1)
      DO i1 = 1, N1
        counter_N1 = counter_N1 + 1.
      END DO
      counter_parallel = counter_parallel + counter_N1  / omp_get_num_threads() ;
    !$OMP END parallel
    counter_N0 = counter_N0 + counter_parallel
  END DO
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target_teams_distribute__parallel__simd
