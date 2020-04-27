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
FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__teams
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER:: omp_get_num_teams, omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    DOUBLE COMPLEX :: counter =  (    0   ,0) 
    INTEGER :: num_teams
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
    !$OMP TEAMS   REDUCTION(+:COUNTER)  
    num_teams = omp_get_num_teams()
counter = counter +  CMPLX(   1./num_teams   ,0) 
    !$OMP END TEAMS
    !$OMP END TARGET
IF  ( .NOT.almost_equal(counter, 1, 0.1) ) THEN
    write(*,*)  'Expected', 1,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target__teams
