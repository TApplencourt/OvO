FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams_loop__parallel_do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter = 0
!$OMP TARGET TEAMS LOOP REDUCTION(+: counter) MAP(TOFROM:counter) 
    DO i = 1 , L
!$OMP PARALLEL DO REDUCTION(+: counter)
    DO j = 1 , M
counter = counter +  1.
    END DO
!$OMP END PARALLEL DO
    END DO
!$OMP END TARGET TEAMS LOOP
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams_loop__parallel_do
