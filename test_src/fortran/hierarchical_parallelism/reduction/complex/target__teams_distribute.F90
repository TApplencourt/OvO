FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol)  )
END FUNCTION almost_equal
program target__teams_distribute
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    COMPLEX :: COUNTER =  (    0   ,0)  
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
    !$OMP TEAMS DISTRIBUTE   REDUCTION(+:COUNTER)  
    DO i = 1 , L 
counter = counter +  CMPLX(   1.  ,0)  
    END DO
    !$OMP END TEAMS DISTRIBUTE
    !$OMP END TARGET
    IF  ( .NOT.almost_equal(COUNTER, L, 0.1) ) THEN
        write(*,*)  'Expected', L,  'Got', COUNTER
        call exit(1)
    ENDIF
end program target__teams_distribute
