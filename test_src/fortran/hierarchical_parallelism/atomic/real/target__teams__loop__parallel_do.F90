FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__loop__parallel_do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter = 0
!$OMP TARGET MAP(TOFROM: counter) 
!$OMP TEAMS
!$OMP LOOP
    DO i = 1 , L
!$OMP PARALLEL DO
    DO j = 1 , M
!$OMP ATOMIC UPDATE
counter = counter +  1.
    END DO
#ifdef _END_PRAGMA
!$OMP END PARALLEL DO
#endif
    END DO
#ifdef _END_PRAGMA
!$OMP END LOOP
#endif
!$OMP END TEAMS
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams__loop__parallel_do
