FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol)  )
END FUNCTION almost_equal
program target_teams_distribute_parallel_do__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    DOUBLE COMPLEX :: COUNTER =  (    0   ,0)  
    !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 
    DO i = 1 , L 
    !$OMP SIMD   REDUCTION(+:COUNTER)  
    DO j = 1 , M 
counter = counter +  CMPLX(   1.  ,0)  
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO
    IF  ( .NOT.almost_equal(COUNTER, L*M, 0.1) ) THEN
        write(*,*)  'Expected', L*M,  'Got', COUNTER
        call exit(1)
    ENDIF
end program target_teams_distribute_parallel_do__simd
