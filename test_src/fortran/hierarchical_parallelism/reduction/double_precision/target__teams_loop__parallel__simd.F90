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
program target__teams_loop__parallel__simd
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
    DOUBLE PRECISION :: COUNTER =  0   
    INTEGER :: num_threads
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
    !$OMP TEAMS LOOP   REDUCTION(+:COUNTER)  
    DO i = 1 , L 
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  
    num_threads = omp_get_num_threads()
    !$OMP SIMD   REDUCTION(+:COUNTER)  
    DO j = 1 , M 
counter =  counter +  1./num_threads  
    END DO
    !$OMP END SIMD
    !$OMP END PARALLEL
    END DO
    !$OMP END TEAMS LOOP
    !$OMP END TARGET
    IF  ( .NOT.almost_equal(COUNTER, L*M, 0.1) ) THEN
        write(*,*)  'Expected', L*M,  'Got', COUNTER
        call exit(1)
    ENDIF
end program target__teams_loop__parallel__simd
