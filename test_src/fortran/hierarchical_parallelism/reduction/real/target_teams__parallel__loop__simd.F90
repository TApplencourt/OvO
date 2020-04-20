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
program target_teams__parallel__loop__simd
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER:: omp_get_num_teams, omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    REAL :: COUNTER =  0   
    INTEGER :: num_teams
    !$OMP TARGET TEAMS   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 
    num_teams = omp_get_num_teams()
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  
    !$OMP LOOP   REDUCTION(+:COUNTER)  
    DO i = 1 , L 
    !$OMP SIMD   REDUCTION(+:COUNTER)  
    DO j = 1 , M 
counter = counter +  1./num_teams  
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END LOOP
    !$OMP END PARALLEL
    !$OMP END TARGET TEAMS
    IF  ( .NOT.almost_equal(COUNTER, L*M, 0.1) ) THEN
        write(*,*)  'Expected', L*M,  'Got', COUNTER
        call exit(1)
    ENDIF
end program target_teams__parallel__loop__simd
