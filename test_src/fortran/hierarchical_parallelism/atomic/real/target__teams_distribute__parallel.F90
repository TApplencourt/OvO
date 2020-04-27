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
    REAL, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__teams_distribute__parallel
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER:: omp_get_num_teams, omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    REAL :: counter =  0  
    INTEGER :: num_threads
    !$OMP TARGET   MAP(TOFROM: counter) 
    !$OMP TEAMS DISTRIBUTE 
    DO i = 1 , L 
    !$OMP PARALLEL 
    num_threads = omp_get_num_threads()
!$OMP ATOMIC UPDATE
counter =  counter +1./num_threads
    !$OMP END PARALLEL
    END DO
    !$OMP END TEAMS DISTRIBUTE
    !$OMP END TARGET
IF  ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    write(*,*)  'Expected', L,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target__teams_distribute__parallel
