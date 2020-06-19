#ifndef _OPENMP
FUNCTION omp_get_num_threads() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_threads
#endif
FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__parallel__simd
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_threads
#endif
  INTEGER :: N0 = 262144
  INTEGER :: i0
  LOGICAL :: almost_equal
  REAL :: counter_parallel
  REAL :: counter_N0
  INTEGER :: expected_value
  expected_value = N0
  counter_parallel = 0
  !$OMP target map(tofrom: counter_parallel)
  !$OMP parallel reduction(+: counter_parallel)
    counter_N0 = 0
    !$OMP simd reduction(+: counter_N0)
    DO i0 = 1, N0
      counter_N0 = counter_N0 + 1.
    END DO
    counter_parallel = counter_parallel + counter_N0  / omp_get_num_threads() ;
  !$OMP END parallel
  !$OMP END target
  IF ( .NOT.almost_equal(counter_parallel,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_parallel
    STOP 112
  ENDIF
END PROGRAM target__parallel__simd
