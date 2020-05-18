FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__distribute__parallel__do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    COMPLEX :: counter = (0,0)
!$OMP TARGET MAP(TOFROM:counter) 
!$OMP TEAMS REDUCTION(+: counter)
!$OMP DISTRIBUTE
    DO i = 1 , L
!$OMP PARALLEL REDUCTION(+: counter)
!$OMP DO
    DO j = 1 , M
counter = counter +  CMPLX(  1. , 0 ) 
    END DO
!$OMP END DO
!$OMP END PARALLEL
    END DO
!$OMP END DISTRIBUTE
!$OMP END TEAMS
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams__distribute__parallel__do
