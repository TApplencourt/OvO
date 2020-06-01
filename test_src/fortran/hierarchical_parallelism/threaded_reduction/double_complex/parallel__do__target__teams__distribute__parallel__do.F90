FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM parallel__do__target__teams__distribute__parallel__do
    LOGICAL :: almost_equal
    INTEGER :: L = 64
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: N = 64
    INTEGER :: k
    DOUBLE COMPLEX :: counter = (0,0)
!$OMP PARALLEL REDUCTION(+: counter)
!$OMP DO
    DO i = 1 , L
!$OMP TARGET MAP(TOFROM: counter) 
!$OMP TEAMS
!$OMP DISTRIBUTE
    DO j = 1 , M
!$OMP PARALLEL
!$OMP DO
    DO k = 1 , N
counter = counter +  CMPLX(  1. , 0 ) 
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
    END DO
#ifdef _END_PRAGMA
!$OMP END DO
#endif
!$OMP END PARALLEL
IF ( .NOT.almost_equal(counter, L*M*N, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M*N,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM parallel__do__target__teams__distribute__parallel__do
