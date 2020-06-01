FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams_distribute_parallel_do_simd
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    DOUBLE COMPLEX :: counter = (0,0)
!$OMP TARGET MAP(TOFROM: counter) 
!$OMP TEAMS DISTRIBUTE PARALLEL DO SIMD REDUCTION(+: counter)
    DO i = 1 , L
counter = counter +  CMPLX(  1. , 0 ) 
    END DO
#ifdef _END_PRAGMA
!$OMP END TEAMS DISTRIBUTE PARALLEL DO SIMD
#endif
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    WRITE(*,*)  'Expected', L,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams_distribute_parallel_do_simd
