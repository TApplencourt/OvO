FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_parallel_loop
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    DOUBLE COMPLEX :: counter = (0,0)
    !$OMP TARGET PARALLEL LOOP   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 
    DO i = 1 , L 
counter = counter +  CMPLX(   1.  ,0)  
    END DO
    !$OMP END TARGET PARALLEL LOOP
IF ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    write(*,*)  'Expected', L,  'Got', counter
    call exit(112)
ENDIF
END PROGRAM target_parallel_loop
