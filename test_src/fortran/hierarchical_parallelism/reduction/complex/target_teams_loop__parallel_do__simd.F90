FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams_loop__parallel_do__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 64
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: N = 64
    INTEGER :: k
    COMPLEX :: counter = (0,0)
    !$OMP TARGET TEAMS LOOP   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 
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
    !$OMP END TARGET TEAMS LOOP
IF ( .NOT.almost_equal(counter, L*M*N, 0.1) ) THEN
    write(*,*)  'Expected', L*M*N,  'Got', counter
    call exit(112)
ENDIF
END PROGRAM target_teams_loop__parallel_do__simd
