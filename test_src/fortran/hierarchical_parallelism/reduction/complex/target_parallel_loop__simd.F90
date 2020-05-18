FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_parallel_loop__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    COMPLEX :: counter = (0,0)
!$OMP TARGET PARALLEL LOOP REDUCTION(+: counter) MAP(TOFROM:counter) 
    DO i = 1 , L
!$OMP SIMD REDUCTION(+: counter)
    DO j = 1 , M
counter = counter +  CMPLX(  1. , 0 ) 
    END DO
!$OMP END SIMD
    END DO
!$OMP END TARGET PARALLEL LOOP
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_parallel_loop__simd
