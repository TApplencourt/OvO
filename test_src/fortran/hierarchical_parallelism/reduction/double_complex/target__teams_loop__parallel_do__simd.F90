FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol)  )
END FUNCTION almost_equal
program target__teams_loop__parallel_do__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    INTEGER :: N = 7
    INTEGER :: k
    DOUBLE COMPLEX :: COUNTER =  (    0   ,0)  
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
    !$OMP TEAMS LOOP   REDUCTION(+:COUNTER)  
    DO i = 1 , L 
    !$OMP PARALLEL DO   REDUCTION(+:COUNTER)  
    DO j = 1 , M 
    !$OMP SIMD   REDUCTION(+:COUNTER)  
    DO k = 1 , N 
counter = counter +  CMPLX(   1.  ,0)  
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END PARALLEL DO
    END DO
    !$OMP END TEAMS LOOP
    !$OMP END TARGET
    IF  ( .NOT.almost_equal(COUNTER, L*M*N, 0.1) ) THEN
        write(*,*)  'Expected', L*M*N,  'Got', COUNTER
        call exit(1)
    ENDIF
end program target__teams_loop__parallel_do__simd
