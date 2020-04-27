FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams_loop__parallel__do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter = 0
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
    !$OMP TEAMS LOOP   REDUCTION(+:COUNTER)  
    DO i = 1 , L 
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  
    !$OMP DO   
    DO j = 1 , M 
counter = counter +  1.  
    END DO
    !$OMP END DO
    !$OMP END PARALLEL
    END DO
    !$OMP END TEAMS LOOP
    !$OMP END TARGET
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    write(*,*)  'Expected', L*M,  'Got', counter
    call exit(112)
ENDIF
END PROGRAM target__teams_loop__parallel__do
