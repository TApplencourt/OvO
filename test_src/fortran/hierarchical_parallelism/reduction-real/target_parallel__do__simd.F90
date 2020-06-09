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
    INTEGER :: N0 = 512
    INTEGER :: i0
    INTEGER :: N1 = 512
    INTEGER :: i1
    REAL :: counter = 0
!$OMP TARGET PARALLEL REDUCTION(+: counter) MAP(TOFROM: counter)
!$OMP DO
       DO i0 = 1 , N0
!$OMP SIMD REDUCTION(+: counter)
       DO i0 = 1 , N0
counter = counter +  1.
    END DO
    END DO
!$OMP END TARGET PARALLEL
IF ( .NOT.almost_equal(counter, N0*N1, 0.1) ) THEN
    WRITE(*,*)  'Expected', N0*N1,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_parallel__do__simd
