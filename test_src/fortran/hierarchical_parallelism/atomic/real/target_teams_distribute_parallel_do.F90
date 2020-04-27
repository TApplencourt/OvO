FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams_distribute_parallel_do
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    REAL :: counter = 0
    !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO   MAP(TOFROM: counter) 
    DO i = 1 , L 
!$OMP ATOMIC UPDATE
counter = counter + 1.
    END DO
    !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO
IF ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    write(*,*)  'Expected', L,  'Got', counter
    call exit(112)
ENDIF
END PROGRAM target_teams_distribute_parallel_do
