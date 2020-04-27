FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams_distribute__parallel__loop
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter = 0
    REAL :: partial_counter
    !$OMP TARGET TEAMS DISTRIBUTE  MAP(TOFROM: counter) 
    DO i = 1 , L 
    partial_counter = 0.
    !$OMP PARALLEL  REDUCTION(+:partial_counter)  
    !$OMP LOOP 
    DO j = 1 , M 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END LOOP
    !$OMP END PARALLEL
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    END DO
    !$OMP END TARGET TEAMS DISTRIBUTE
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    write(*,*)  'Expected', L*M,  'Got', counter
    call exit(112)
ENDIF
END PROGRAM target_teams_distribute__parallel__loop
