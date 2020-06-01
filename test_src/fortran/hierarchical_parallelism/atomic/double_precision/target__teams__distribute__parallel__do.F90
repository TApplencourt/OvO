FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__distribute__parallel__do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    DOUBLE PRECISION :: counter = 0
!$OMP TARGET MAP(TOFROM: counter) 
!$OMP TEAMS
!$OMP DISTRIBUTE
    DO i = 1 , L
!$OMP PARALLEL
!$OMP DO
    DO j = 1 , M
!$OMP ATOMIC UPDATE
counter = counter +  1.
    END DO
#ifdef _END_PRAGMA
!$OMP END DO
#endif
!$OMP END PARALLEL
    END DO
#ifdef _END_PRAGMA
!$OMP END DISTRIBUTE
#endif
!$OMP END TEAMS
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams__distribute__parallel__do
