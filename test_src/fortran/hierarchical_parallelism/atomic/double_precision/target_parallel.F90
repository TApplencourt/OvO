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
PROGRAM target_parallel
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    DOUBLE PRECISION :: counter = 0
    INTEGER :: num_threads
    !$OMP TARGET PARALLEL   MAP(TOFROM: counter) 
    num_threads = omp_get_num_threads()
!$OMP ATOMIC UPDATE
counter = counter + 1./num_threads
    !$OMP END TARGET PARALLEL
IF ( .NOT.almost_equal(counter, 1, 0.1) ) THEN
    write(*,*)  'Expected', 1,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_parallel
