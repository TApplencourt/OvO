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
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  ) 
END FUNCTION almost_equal
program target__teams
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER:: omp_get_num_teams, omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    DOUBLE PRECISION :: COUNTER = 0
    INTEGER :: num_teams
    !$OMP TARGET   MAP(TOFROM: COUNTER) 
    !$OMP TEAMS 
    num_teams = omp_get_num_teams()
!$OMP ATOMIC UPDATE
counter = counter + 1./num_teams
    !$OMP END TEAMS
    !$OMP END TARGET
    IF  ( .NOT.almost_equal(COUNTER, 1, 0.1) ) THEN
        write(*,*)  'Expected', 1,  'Got', COUNTER
        call exit(1)
    ENDIF
end program target__teams
