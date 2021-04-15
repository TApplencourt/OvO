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
PROGRAM target__parallel
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
  counter_parallel = 0
  !$OMP TARGET map(tofrom: counter_parallel)
  !$OMP PARALLEL
    counter_parallel = counter_parallel + 1.  / omp_get_num_threads() ;
  !$OMP END PARALLEL
  !$OMP END TARGET
  IF ( .NOT.almost_equal(counter_parallel,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_parallel
    STOP 112
  ENDIF
END PROGRAM target__parallel
