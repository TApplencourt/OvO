FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams__distribute__parallel_do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter = 0
  REAL partial_counter
!$OMP TARGET TEAMS MAP(TOFROM: counter) 
!$OMP DISTRIBUTE
    DO i = 1 , L
  partial_counter = 0.
!$OMP PARALLEL DO REDUCTION(+: partial_counter)
    DO j = 1 , M
partial_counter = partial_counter +  1.
    END DO
!$OMP END PARALLEL DO
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    END DO
!$OMP END DISTRIBUTE
!$OMP END TARGET TEAMS
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams__distribute__parallel_do
