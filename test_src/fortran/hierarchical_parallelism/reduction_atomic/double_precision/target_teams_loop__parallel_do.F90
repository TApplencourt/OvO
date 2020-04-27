FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target_teams_loop__parallel_do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    DOUBLE PRECISION :: counter =  0  
    !$OMP TARGET TEAMS LOOP  MAP(TOFROM: counter) 
    DO i = 1 , L 
    partial_counter = 0.
    !$OMP PARALLEL DO  REDUCTION(+:partial_counter)  
    DO j = 1 , M 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END PARALLEL DO
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    END DO
    !$OMP END TARGET TEAMS LOOP
IF  ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    write(*,*)  'Expected', L*M,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target_teams_loop__parallel_do
