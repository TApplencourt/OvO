FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__teams_distribute_parallel_do__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    COMPLEX :: counter =  (    0   ,0) 
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
    !$OMP TEAMS DISTRIBUTE PARALLEL DO   REDUCTION(+:COUNTER)  
    DO i = 1 , L 
    !$OMP SIMD   REDUCTION(+:COUNTER)  
    DO j = 1 , M 
counter = counter +  CMPLX(   1.  ,0)  
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END TEAMS DISTRIBUTE PARALLEL DO
    !$OMP END TARGET
IF  ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    write(*,*)  'Expected', L*M,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target__teams_distribute_parallel_do__simd
