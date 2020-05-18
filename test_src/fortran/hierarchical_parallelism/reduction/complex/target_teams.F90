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
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_teams
#endif
    LOGICAL :: almost_equal
    COMPLEX :: counter = (0,0)
    INTEGER :: num_teams
!$OMP TARGET TEAMS REDUCTION(+: counter) MAP(TOFROM: counter) 
    num_teams = omp_get_num_teams()
counter = counter +  CMPLX(  1./num_teams , 0 ) 
!$OMP END TARGET TEAMS
IF ( .NOT.almost_equal(counter, 1, 0.1) ) THEN
    WRITE(*,*)  'Expected', 1,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams
