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
PROGRAM target__teams__distribute__parallel__simd
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_threads
#endif
  INTEGER :: N0 = 32
  INTEGER :: i0
  INTEGER :: N1 = 32
  INTEGER :: i1
  LOGICAL :: almost_equal
  REAL :: counter_N0
  INTEGER :: expected_value
  expected_value = N0*N1
  counter_N0 = 0
  !$OMP TARGET map(tofrom: counter_N0)
  !$OMP TEAMS
  !$OMP DISTRIBUTE
  DO i0 = 1, N0
    !$OMP PARALLEL num_threads(32)
      !$OMP SIMD
      DO i1 = 1, N1
        !$OMP atomic update
        counter_N0 = counter_N0 + 1.  / omp_get_num_threads() ;
      END DO
    !$OMP END PARALLEL
  END DO
  !$OMP END TEAMS
  !$OMP END TARGET
  IF ( .NOT.almost_equal(counter_N0,expected_value, 0.01) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_N0
    STOP 112
  ENDIF
END PROGRAM target__teams__distribute__parallel__simd
