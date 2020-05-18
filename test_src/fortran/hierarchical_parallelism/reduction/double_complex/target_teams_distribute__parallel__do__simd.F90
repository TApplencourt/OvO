FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams_distribute__parallel__do__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 64
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: N = 64
    INTEGER :: k
    DOUBLE COMPLEX :: counter = (0,0)
!$OMP TARGET TEAMS DISTRIBUTE REDUCTION(+: counter) MAP(TOFROM: counter) 
    DO i = 1 , L
!$OMP PARALLEL REDUCTION(+: counter)
!$OMP DO
    DO j = 1 , M
!$OMP SIMD REDUCTION(+: counter)
    DO k = 1 , N
counter = counter +  CMPLX(  1. , 0 ) 
    END DO
!$OMP END SIMD
    END DO
!$OMP END DO
!$OMP END PARALLEL
    END DO
!$OMP END TARGET TEAMS DISTRIBUTE
IF ( .NOT.almost_equal(counter, L*M*N, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M*N,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams_distribute__parallel__do__simd
