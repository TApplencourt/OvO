FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM parallel_do__target_teams_distribute_parallel_do
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    DOUBLE COMPLEX :: counter = (0,0)
!$OMP PARALLEL DO REDUCTION(+: counter)
    DO i = 1 , L
!$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO MAP(TOFROM: counter) 
    DO j = 1 , M
!$OMP ATOMIC UPDATE
counter = counter +  CMPLX(  1. , 0 ) 
    END DO
!$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO
    END DO
!$OMP END PARALLEL DO
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM parallel_do__target_teams_distribute_parallel_do
