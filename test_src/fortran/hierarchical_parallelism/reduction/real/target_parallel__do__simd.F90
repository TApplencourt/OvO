FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_parallel__do__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter = 0
!$OMP TARGET PARALLEL REDUCTION(+:counter) map(tofrom:counter) 
!$OMP DO
    DO i = 1 , L
!$OMP SIMD REDUCTION(+:counter)
    DO j = 1 , M
counter = counter +  1.
    END DO
!$OMP END SIMD
    END DO
!$OMP END DO
!$OMP END TARGET PARALLEL
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_parallel__do__simd
