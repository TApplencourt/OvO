FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__teams__distribute__parallel_do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    DOUBLE COMPLEX :: counter =  (    0   ,0) 
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
    !$OMP TEAMS   REDUCTION(+:COUNTER)  
    !$OMP DISTRIBUTE   
    DO i = 1 , L 
    !$OMP PARALLEL DO   REDUCTION(+:COUNTER)  
    DO j = 1 , M 
counter = counter +  CMPLX(   1.  ,0)  
    END DO
    !$OMP END PARALLEL DO
    END DO
    !$OMP END DISTRIBUTE
    !$OMP END TEAMS
    !$OMP END TARGET
IF  ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    write(*,*)  'Expected', L*M,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target__teams__distribute__parallel_do
