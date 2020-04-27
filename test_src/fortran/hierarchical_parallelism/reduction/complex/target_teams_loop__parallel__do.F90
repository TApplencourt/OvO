FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target_teams_loop__parallel__do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    COMPLEX :: counter =  (    0   ,0) 
    !$OMP TARGET TEAMS LOOP   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 
    DO i = 1 , L 
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  
    !$OMP DO   
    DO j = 1 , M 
counter = counter +  CMPLX(   1.  ,0)  
    END DO
    !$OMP END DO
    !$OMP END PARALLEL
    END DO
    !$OMP END TARGET TEAMS LOOP
IF  ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    write(*,*)  'Expected', L*M,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target_teams_loop__parallel__do
