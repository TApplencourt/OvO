#ifndef _OPENMP
FUNCTION omp_get_num_teams() RESULT(i)
    INTEGER :: i
    i = 1
END FUNCTION omp_get_num_teams
FUNCTION omp_get_num_threads() RESULT(i)
    INTEGER :: i
    i = 1
END FUNCTION omp_get_num_threads
#endif
FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams__parallel
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_teams
    INTEGER :: omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    DOUBLE PRECISION :: counter = 0
    INTEGER :: num_teams
    INTEGER :: num_threads
  DOUBLE PRECISION partial_counter
!$OMP TARGET TEAMS MAP(TOFROM: counter) 
    num_teams = omp_get_num_teams()
  partial_counter = 0.
!$OMP PARALLEL REDUCTION(+: partial_counter)
    num_threads = omp_get_num_threads()
partial_counter = partial_counter +  1./(num_teams*num_threads)
!$OMP END PARALLEL
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
!$OMP END TARGET TEAMS
IF ( .NOT.almost_equal(counter, 1, 0.1) ) THEN
    WRITE(*,*)  'Expected', 1,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams__parallel
