FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams_distribute__parallel_do
    LOGICAL :: almost_equal
    INTEGER :: N0 = 512
    INTEGER :: i0
    INTEGER :: N1 = 512
    INTEGER :: i1
    DOUBLE COMPLEX :: counter = (0,0)
!$OMP TARGET MAP(TOFROM: counter)
!$OMP TEAMS DISTRIBUTE REDUCTION(+: counter)
       DO i0 = 1 , N0
!$OMP PARALLEL DO REDUCTION(+: counter)
       DO i1 = 1 , N1
counter = counter +  CMPLX(  1. , 0 )
    END DO
    END DO
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, N0*N1, 0.1) ) THEN
    WRITE(*,*)  'Expected', N0*N1,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams_distribute__parallel_do
