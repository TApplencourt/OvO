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
PROGRAM target__teams_distribute__parallel__simd
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_threads
#endif
  INTEGER :: N0 = 23
  INTEGER :: i0
  INTEGER :: N1 = 23
  INTEGER :: i1
  INTEGER :: N2 = 23
  INTEGER :: i2
  INTEGER :: N3 = 23
  INTEGER :: i3
  LOGICAL :: almost_equal
  DOUBLE COMPLEX :: counter_N0
  DOUBLE COMPLEX :: counter_parallel
  DOUBLE COMPLEX :: counter_N2
  INTEGER :: expected_value
  expected_value = N0*N1*N2*N3
  counter_N0 = 0
  !$OMP target map(tofrom: counter_N0)
  !$OMP teams distribute reduction(+: counter_N0) collapse(2)
  DO i0 = 1, N0
  DO i1 = 1, N1
    counter_parallel = 0
    !$OMP parallel reduction(+: counter_parallel)
      counter_N2 = 0
      !$OMP simd reduction(+: counter_N2) collapse(2)
      DO i2 = 1, N2
      DO i3 = 1, N3
        counter_N2 = counter_N2 + 1.
      END DO
      END DO
      counter_parallel = counter_parallel + counter_N2  / omp_get_num_threads() ;
    !$OMP END parallel
    counter_N0 = counter_N0 + counter_parallel
  END DO
  END DO
  !$OMP END target
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target__teams_distribute__parallel__simd
