FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_parallel_do_simd
    LOGICAL :: almost_equal
    INTEGER :: N_i = 64
    INTEGER :: i
    REAL :: counter = 0
!$OMP TARGET PARALLEL DO SIMD REDUCTION(+: counter) MAP(TOFROM: counter) 
    DO i = 1 , N_i
counter = counter +  1.
    END DO
IF ( .NOT.almost_equal(counter, N_i, 0.1) ) THEN
    WRITE(*,*)  'Expected', N_i,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_parallel_do_simd
