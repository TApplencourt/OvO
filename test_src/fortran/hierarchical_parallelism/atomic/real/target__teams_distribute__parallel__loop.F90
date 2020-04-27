FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__teams_distribute__parallel__loop
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter =  0  
    !$OMP TARGET   MAP(TOFROM: counter) 
    !$OMP TEAMS DISTRIBUTE 
    DO i = 1 , L 
    !$OMP PARALLEL 
    !$OMP LOOP 
    DO j = 1 , M 
!$OMP ATOMIC UPDATE
counter = counter + 1.
    END DO
    !$OMP END LOOP
    !$OMP END PARALLEL
    END DO
    !$OMP END TEAMS DISTRIBUTE
    !$OMP END TARGET
IF  ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    write(*,*)  'Expected', L*M,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target__teams_distribute__parallel__loop
