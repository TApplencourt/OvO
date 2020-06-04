FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_parallel__do__simd
    LOGICAL :: almost_equal
    INTEGER :: N_i = 64
    INTEGER :: i
    INTEGER :: N_j = 64
    INTEGER :: j
    DOUBLE COMPLEX :: counter = (0,0)
!$OMP TARGET PARALLEL REDUCTION(+: counter) MAP(TOFROM: counter) 
!$OMP DO
    DO i = 1 , N_i
!$OMP SIMD REDUCTION(+: counter)
    DO j = 1 , N_j
counter = counter +  CMPLX(  1. , 0 ) 
    END DO
    END DO
!$OMP END TARGET PARALLEL
IF ( .NOT.almost_equal(counter, N_i*N_j, 0.1) ) THEN
    WRITE(*,*)  'Expected', N_i*N_j,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_parallel__do__simd
