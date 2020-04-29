FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__parallel__do
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    COMPLEX :: counter = (0,0)
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  
    !$OMP DO   
    DO i = 1 , L 
counter = counter + 1.
    END DO
    !$OMP END DO
    !$OMP END PARALLEL
    !$OMP END TARGET
IF ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    write(*,*)  'Expected', L,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__parallel__do
